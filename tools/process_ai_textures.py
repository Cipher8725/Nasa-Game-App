#!/usr/bin/env python3
"""Procesa las texturas crudas generadas con IA para el juego.

Las imágenes crudas (1024x1024) se generan con la API de Layer y quedan en una
carpeta temporal. Este script las convierte en recursos ligeros y listos para
Godot:

  * ``sky_space.webp``  -> panorámica equirectangular 2:1 sin costura horizontal.
  * ``moon_regolith.webp`` / ``mars_regolith.webp``
        -> albedo 1024x1024 repetible sin costuras (fundido cruzado circular).
  * ``*_normal.webp``  -> mapas de normales derivados del albedo con Sobel
        circular (sin costuras) a 512x512.

Se guarda en WebP y no en JPEG: en un campo de estrellas sobre negro el JPEG
produce bloques de 8x8 px muy visibles al ampliar la textura en pantalla; WebP
conserva el grano sin bloques con un peso parecido.

Uso:
    python tools/process_ai_textures.py --raw <carpeta_cruda> [--out <carpeta>]

Las imágenes crudas NO se versionan; las procesadas sí (van a
``ai_assets/textures/``), porque son propias y ligeras (~1,5 MB en total).
"""

from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
from PIL import Image

# Tamaño máximo de las texturas finales: nunca 4K ni Full HD.
GROUND_SIZE = 1024
NORMAL_SIZE = 512
SKY_SIZE = (2048, 1024)

# Calidad WebP: suficiente para que no se vean artefactos en pantalla y
# mantiene los archivos ligeros (el cielo es el más pesado, ~0,9 MB).
QUALITY_ALBEDO = 90
QUALITY_NORMAL = 92
QUALITY_SKY = 95


def load_rgb(path: Path) -> Image.Image:
    """Carga una imagen y la normaliza a RGB."""
    with Image.open(path) as img:
        return img.convert("RGB")


def crop_border(img: Image.Image, pixels: int) -> Image.Image:
    """Recorta un borde para eliminar artefactos de generación en los extremos."""
    width, height = img.size
    return img.crop((pixels, pixels, width - pixels, height - pixels))


def seam_error(img: Image.Image) -> tuple[float, float, float]:
    """Mide la discontinuidad entre bordes opuestos.

    Devuelve ``(error_vertical, error_horizontal, referencia)``. La referencia
    es la diferencia media entre columnas contiguas del interior: si el error
    del borde no la supera, la imagen ya era repetible.
    """
    data = np.asarray(img, dtype=np.float32)
    reference = float(np.abs(np.diff(data[1:-1, 1:-1], axis=1)).mean())
    horizontal = float(np.abs(data[:, 0] - data[:, -1]).mean())
    vertical = float(np.abs(data[0, :] - data[-1, :]).mean())
    return vertical, horizontal, reference


def make_seamless(img: Image.Image, size: int, band: float = 0.20) -> Image.Image:
    """Convierte una textura en repetible mediante un fundido cruzado circular.

    El mosaico especular (reflejar la imagen) también es repetible, pero deja
    una simetría evidente: los cráteres forman rombos. Este método mezcla la
    imagen ``I`` con su copia desplazada media textura ``I'``:

        O = A * I + (1 - A) * I'

    donde ``A`` vale 1 en el centro y 0 en los cuatro bordes. En los bordes
    queda solo ``I'``, que es continua al envolver, de modo que la textura
    empalma sin costura y sin simetría; el fundido se limita a una banda
    estrecha (``band``) junto a los bordes.
    """
    base = img.resize((size, size), Image.Resampling.LANCZOS)
    data = np.asarray(base, dtype=np.float32) / 255.0
    shifted = np.roll(data, (size // 2, size // 2), axis=(0, 1))

    axis = np.linspace(0.0, 1.0, size, endpoint=False, dtype=np.float32)
    distance = np.clip(np.minimum(axis, 1.0 - axis) / band, 0.0, 1.0)
    window = np.sin(distance * np.pi / 2.0) ** 2
    weight = (window[:, None] * window[None, :])[:, :, None]

    blended = data * weight + shifted * (1.0 - weight)
    return Image.fromarray((np.clip(blended, 0.0, 1.0) * 255.0).astype(np.uint8), mode="RGB")


def make_sky_panorama(img: Image.Image, size: tuple[int, int]) -> Image.Image:
    """Construye una panorámica equirectangular 2:1 sin costura horizontal.

    La mitad izquierda es la imagen y la derecha su reflejo, así los dos bordes
    del panorama coinciden exactamente. Se añade una variación de brillo muy
    suave y periódica para que la simetría del reflejo no sea evidente, y un
    desvanecido en los polos (las filas superior e inferior se estiran sobre
    toda la esfera).
    """
    width, height = size
    half = img.resize((width // 2, height), Image.Resampling.LANCZOS)
    mirrored = half.transpose(Image.Transpose.FLIP_LEFT_RIGHT)

    panorama = Image.new("RGB", size)
    panorama.paste(half, (0, 0))
    panorama.paste(mirrored, (width // 2, 0))

    data = np.asarray(panorama, dtype=np.float32) / 255.0

    # Variación de brillo periódica (una sola onda por vuelta: continua en la
    # costura) para romper la simetría del reflejo.
    phase = np.linspace(0.0, 2.0 * np.pi, width, endpoint=False)
    gain = 1.0 + 0.07 * np.sin(phase)[None, :]
    data *= gain[:, :, None]

    # Desvanecido en los polos: evita que una estrella se convierta en una raya
    # al proyectarse sobre el cenit/nadir de la esfera.
    fade_rows = max(1, int(height * 0.09))
    ramp = np.cos(np.linspace(0.0, np.pi / 2.0, fade_rows)) ** 2
    weights = np.ones(height, dtype=np.float32)
    weights[:fade_rows] = 0.08 + 0.92 * ramp[::-1]
    weights[-fade_rows:] = 0.08 + 0.92 * ramp
    data *= weights[:, None, None]

    data = np.clip(data, 0.0, 1.0) * 255.0
    return Image.fromarray(data.astype(np.uint8), mode="RGB")


def _sobel_axis(gray: np.ndarray, axis: int) -> np.ndarray:
    """Sobel separable con envoltura circular (la textura es repetible).

    ``axis=1`` devuelve el gradiente horizontal y ``axis=0`` el vertical.
    """
    other = 1 - axis
    # Suavizado [1, 2, 1] / 4 a lo largo del eje perpendicular.
    smoothing = (np.roll(gray, 1, axis=other) + 2.0 * gray + np.roll(gray, -1, axis=other)) * 0.25
    # Derivada centrada [-1, 0, 1] / 2 a lo largo del eje pedido.
    derivative = (np.roll(gray, -1, axis=axis) - np.roll(gray, 1, axis=axis)) * 0.5
    return derivative * smoothing


def make_normal_map(albedo: Image.Image, size: int, strength: float = 2.4) -> Image.Image:
    """Deriva un mapa de normales tangencial (convención OpenGL, +Y arriba)."""
    gray = albedo.convert("L").resize((size, size), Image.Resampling.LANCZOS)
    height = np.asarray(gray, dtype=np.float32) / 255.0

    # Suavizado leve: el detalle de grano fino no debe generar normales ruidosas.
    height = (np.roll(height, 1, 0) + np.roll(height, -1, 0) +
              np.roll(height, 1, 1) + np.roll(height, -1, 1) + height * 4.0) / 8.0

    dx = _sobel_axis(height, axis=1) * strength
    dy = _sobel_axis(height, axis=0) * strength

    nx = -dx
    ny = dy
    nz = np.ones_like(nx)
    length = np.sqrt(nx * nx + ny * ny + nz * nz)
    nx /= length
    ny /= length
    nz /= length

    encoded = np.stack([(nx + 1.0) * 0.5, (ny + 1.0) * 0.5, (nz + 1.0) * 0.5], axis=-1)
    return Image.fromarray((np.clip(encoded, 0.0, 1.0) * 255.0).astype(np.uint8), mode="RGB")


def save_texture(img: Image.Image, path: Path, quality: int) -> None:
    """Guarda una textura en WebP con la calidad indicada."""
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path, format="WEBP", quality=quality, method=6)
    print(f"    {path.name:<28} {img.size[0]}x{img.size[1]}  {path.stat().st_size / 1024:.0f} KB")


def process_ground(raw: Path, out: Path, name: str, source: str) -> None:
    """Albedo + normales repetibles a partir de una textura de suelo."""
    base = load_rgb(raw / source)
    base = crop_border(base, 8)

    vertical, horizontal, reference = seam_error(base)
    print(f"  {name}: costura cruda V={vertical:.2f} H={horizontal:.2f} (referencia {reference:.2f})")

    albedo = make_seamless(base, GROUND_SIZE)
    vertical, horizontal, reference = seam_error(albedo)
    print(f"    costura final V={vertical:.2f} H={horizontal:.2f} (referencia {reference:.2f})")
    save_texture(albedo, out / f"{name}.webp", QUALITY_ALBEDO)

    normal = make_normal_map(albedo, NORMAL_SIZE)
    save_texture(normal, out / f"{name}_normal.webp", QUALITY_NORMAL)


def main() -> None:
    parser = argparse.ArgumentParser(description="Procesa texturas IA para NaSA-GAME.")
    parser.add_argument("--raw", required=True, type=Path, help="carpeta con sky.png, moon.png y mars.png")
    parser.add_argument("--out", type=Path, default=Path("ai_assets/textures"), help="carpeta de salida")
    args = parser.parse_args()

    raw: Path = args.raw
    out: Path = args.out

    print("  cielo:")
    sky = load_rgb(raw / "sky.png")
    sky = crop_border(sky, 8)
    panorama = make_sky_panorama(sky, SKY_SIZE)
    save_texture(panorama, out / "sky_space.webp", QUALITY_SKY)

    print("  suelos:")
    process_ground(raw, out, "moon_regolith", "moon.png")
    process_ground(raw, out, "mars_regolith", "mars.png")

    total = sum(f.stat().st_size for f in out.glob("*.webp"))
    print(f"  total: {total / 1024:.0f} KB en {out}")


if __name__ == "__main__":
    main()
