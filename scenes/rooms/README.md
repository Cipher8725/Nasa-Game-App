# Módulos de habitación (`scenes/rooms/`)

Habitaciones modulares construidas con piezas del pack **Molten Maps SciFi Asset
Pack** (que se usa in situ desde `res://assets/`). Cada módulo es una escena
autocontenida: no depende de `scenes/habitat*.tscn` ni del resto del juego, así
que se pueden colocar en el mapa cuando se amplíe.

## Módulos disponibles

| Escena | Habitación | Tamaño interior | Identidad |
|--------|------------|------------------|-----------|
| `room_cafeteria.tscn` | Comedor | 8 × 8 m | `Wall_Orange`, alfombra gris, mesa grande y 8 sillas |
| `room_quarters.tscn` | Cuartos de la tripulación | 8 × 4 m | `Wall_Blue`, alfombra azul, 3 literas + 1 litera doble |
| `room_generator.tscn` | Sala del generador | 8 × 8 m | `Wall_Grey`, rejilla metálica, generador, pila y 4 baterías |
| `room_control.tscn` | Sala de control | 8 × 8 m | `Command_Wall`, placa de mando, consola, 4 sillas y monitor |
| `room_hydroponics.tscn` | Hidroponía | 8 × 8 m | `Wall_Green` + cristal, cultivos, bancales y luminaria de cultivo |
| `room_medbay.tscn` | Enfermería / criotanque | 8 × 4 m | suelo médico, 2 criotanques, cápsula y biomonitores |
| `room_briefing.tscn` | Sala de reuniones | 8 × 8 m | `Wall_Orange`, alfombra naranja, mesa octogonal y 8 sillas |
| `room_storage.tscn` | Almacén / taller | 8 × 8 m | rejilla, pilas de energía, pasarela elevada y barandilla |
| `corridor_module.tscn` | Pasillo | 4 × 8 m | `Corridor_Boundary_4x8` con suelo de vía central |

`rooms_preview.tscn` coloca los 9 módulos en fila (espaciado 14 m) para
compararlos de un vistazo. **No forma parte del juego.**

## Módulos `IMG_*` (recreados desde `assets/IMG/`)

Segundo juego de módulos, recreado a partir de las **fotos de referencia** que
hay en `assets/IMG/` (renders del pack Molten Maps). Misma convención que los
anteriores, con el contenido y los colores que aparecen en cada foto:

| Escena | Referencia | Habitación identificada | Contenido |
|--------|------------|------------------------|-----------|
| `IMG_vestibulo.tscn` | `6bDelJ.jpg` | Vestíbulo / módulo de acceso | Pantalla grande en la pared oeste, puesto de control a escala, pila de 6 baterías verdes, ventanal de cristal y escalera de servicio (`Ramp_Grey`) al este |
| `IMG_sala_de_mando.tscn` | `pGXT9C.jpg` | Sala de mando | `Orrery` central con el holograma, suelo `Floor_Metal_Circles`, 3 puestos de trabajo con lámpara, `Command_Wall`, ventanas de cristal |
| `IMG_sala_del_generador.tscn` | `PjBOyt.jpg` | Sala del generador | Paredes `Wall_Red`, generador naranja, baterías verdes, franja de peligro, ventana verde, panel de estado, escalera de servicio |
| `IMG_enfermeria.tscn` | `9tMILo.jpg` | Enfermería | 4 camas `Bunk_Single_Green` + litera doble, paredes `Wall_Green`, biomonitor y alfombra verde |
| `IMG_criotanque.tscn` | `bK2PlK.jpg` | Criotanque | 3 cápsulas `Cryo_Tube_ON` encendidas y 1 apagada, paredes `Wall_Blue`, ventana azul, apliques y biomonitor rojo |
| `IMG_cuartos.tscn` | `DnG84u.jpg` | Cuartos | Litera doble y literas `Bunk_Single_Blue`, panel rojo de acento, tablero de ajedrez, silla y apliques |
| `IMG_sala_de_reuniones.tscn` | `S4lJ0w.jpg` | Sala de reuniones | Mesa octogonal con 8 sillas, 2 pantallas de briefing, pantallas de pared y ventanas azules |
| `IMG_sala_del_orrery.tscn` | `vnoCXw.jpg` | Sala del orrery | `Orrery` con holograma magenta, banco largo (`Meeting_Table`), monitor grande, displays y lámpara de pie |

Notas:

- Las **franjas de peligro** (`Hazard_Floor_1`) van en el nodo `Floor`, no en
  `Props`: son superficie de apoyo y los muebles se apoyan encima.
- Las **escaleras** (`Ramp_Grey`) son piezas de 4 × 4 m con paredes propias, así
  que van **fuera** del módulo (justo al otro lado del ventanal), como se ven
  en las fotos.

## Conción de montaje

Todos los módulos siguen las mismas reglas, para que encajen entre sí:

- **Origen**: el centro de la zona de suelo.
- **Suelo**: baldosas de 4 m, de `-4` a `+4` en X y en Z (módulos 8 × 8) o de
  `-4` a `+4` en X y `-2` a `+2` en Z (módulos 8 × 4).
- **Paredes**: van **por fuera** del suelo, centradas en `x/z = ±4.37`
  (módulos 8 × 8) o `±2.37` (8 × 4). Su cara interior queda en `±4.00` /
  `±2.00`. Los paneles son de 4 m de largo, así que van 2 por lado largo y 1
  por lado corto.
- **Puerta**: siempre en la pared **−Z**, en el panel situado en `x = -2`
  (`Wall_With_Door_Grey`). Para entrar en un módulo hay que situarlo al norte
  de otro (o dejar un pasillo entre medias).
- **Techo**: cierra a `y = 4` (las baldosas nativas ocupan 3.86..4.01). Las
  luminarias `Ceiling_Light` cuelgan en `y = 3.66` para no hacer z-fighting.
- **Luces**: un `OmniLight3D` por luminaria, en `y = 3.45`, con el tono de
  color de la sala (cálido en el comedor, frío en el generador, verde en la
  hidroponía…).
- **Colisión**: nodo `Collision` (`StaticBody3D`) con cajas invisibles: una
  para el suelo y una por cada panel de pared. La puerta se modela con **dos
  tramos** para dejar un hueco de 1,6 m.

Estructura de nodos de cada módulo:

```
RoomX (Node3D)
├── Floor (Node3D)     → baldosas de suelo
├── Ceiling (Node3D)   → baldosas de techo + luminarias
├── Lights (Node3D)    → OmniLight3D
├── Walls (Node3D)     → paneles de pared
├── Props (Node3D)     → mobiliario
└── Collision (StaticBody3D) → cajas invisibles
```

## Colocarlos en el mapa

Para una fila de módulos separados por pasillo, el módulo `n` va en
`z = n * 8.74` (8 m de interior + 0,74 de pared) y el pasillo entre ellos. Para
una cuadrícula, la separación es la misma en X.

## Añadir una habitación nueva

1. Copia un módulo existente como base.
2. Cambia el suelo, las paredes y el mobiliario.
3. Coloca el mueble con la AABB real del modelo: **muchas piezas del pack tienen
   el origen descentrado** (por ejemplo `Command_Console` va de `z = -1.73` a
   `z = 3.15`, y `Bunk_Double_Grey` de `x = -1.25` a `x = 0.75`).
4. Pásalo por el test de colocación (abajo) y revisa el resultado con una
   captura.

## Verificación

```powershell
$godot = "H:\Godot V4.7.2\Godot_v4.7.2-stable_win64_console.exe"
& $godot --headless --path . --quit-after 4000 "res://tests/room_collision_test.tscn"
```

El test instancia los 17 módulos, comprueba que tienen la estructura mínima
(suelo, paredes, props, luces y colisión) y que **ningún mueble se solapa con
otro** (AABB, ignorando copias del mismo asset y las superficies de apoyo).
Falla si algún solape supera 0,05 m³.
