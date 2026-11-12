# Game Concept — NaSA-GAME

## Elevator Pitch
Simulador de supervivencia en un hábitat espacial: el jugador administra cuatro
recursos vitales (oxígeno, energía, agua y estructura) durante una misión de
180 segundos, reparando las consolas del hábitat mientras las colisiones
ambientales erosionan los sistemas.

## Design Pillars
1. **Presión legible** — Cada recurso baja de forma continua y visible; el
   jugador siempre sabe por qué está perdiendo y qué debe reparar.
2. **Reparar es la acción** — El núcleo no es "mirar barras", sino correr entre
   consolas bajo presión. La reparación es el verbo principal del juego.
3. **Fallo justo** — Se pierde por una causa clara (recurso agotado) y se
   anuncia con antelación (estado CRÍTICO + alerta en pantalla).

## Core Loop
1. **Action**: Moverse por el hábitat, localizar la consola del recurso crítico
   y repararla con la tecla `E`.
2. **Reward**: El recurso sube 30 unidades, el estado CRÍTICO se sale y la
   puntuación acumulada sigue creciendo.
3. **Progression**: La misión dura 180 s. Sobrevivirla completa la misión y
   suma al contador de misiones completadas. `R` reinicia la partida.

## Target Player
- **Experience Level**: Casual / educativo (reto "Junior Astronaut").
- **Time Commitment**: 3 minutos por partida.
- **Platform**: PC (escritorio, teclado + ratón).
- **What They Value**: aprender a gestionar recursos bajo presión de tiempo.

## Key Features
1. **Gestión de 4 recursos** — Oxígeno, energía, agua y estructura, cada uno con
   su tasa de decaimiento y su consola de reparación.
2. **Emergencias ambientales** — Micrometeorito, sobrecarga energética, caída de
   presión y fuga de agua, con severidad aleatoria.
3. **Estados de misión** — BRIEFING → ACTIVE → CRITICAL → COMPLETED / FAILED.
4. **HUD reactivo** — Barras, valores numéricos, cronómetro, puntuación y
   alertas; todo alimentado por señales, nunca por referencia directa.
5. **Persistencia** — Guardado y carga de partida en JSON con marca de tiempo.

## Scope
- **Size**: Jam / Small.
- **Timeline**: Hito 1 (bucle jugable completo) alcanzado.
- **Team**: Solo.

## Engine
- **Choice**: Godot 4.7.2.
- **Reasoning**: Renderizador 3D ligero (`gl_compatibility`) con Jolt Physics,
  GDScript tipado estricto y Autoload para el estado global. El binario nativo
  permite validar en headless sin tarjeta gráfica.

## Visual Style
- **Art Style**: Greyboxing 3D — `BoxMesh` para suelo/paredes/consolas,
  `CapsuleMesh` + `SphereMesh` para el astronauta. Colores sólidos planos que
  identifican cada recurso.
- **Color Palette**: Espacio oscuro con acentos por recurso:
  Oxígeno `#338FCC` · Energía `#F2BF33` · Agua `#33D9BF` · Estructura `#D95959`.
- **Camera**: Tercera persona con `SpringArm3D` (colisión con el entorno),
  campo de visión 75°.

## Audio Direction
- **Music Style**: Pendiente (ambiente tenso de estación espacial).
- **Sound Design**: Pendiente (alarmas de recurso crítico, impacto de
  micrometeorito, confirmación de reparación).

## Next Steps
1. [x] Configurar motor y estructura de carpetas
2. [x] Bucle jugable: jugador + consolas + HUD + emergencias
3. [x] Persistencia de partida
4. [ ] Audio (alarmas y efectos de consola)
5. [ ] Sustituir greyboxing por assets finales en `res://ai_assets/`
6. [ ] Segunda misión / niveles con distinta dificultad
