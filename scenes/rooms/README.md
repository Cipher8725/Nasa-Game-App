# Módulos de habitación (`scenes/rooms/`)

Habitaciones modulares construidas con piezas del pack **Molten Maps SciFi Asset
Pack** (que se usa in situ desde `res://assets/`). Cada módulo es una escena
autocontenida: no depende de `scenes/habitat*.tscn` ni del resto del juego, así
que se pueden colocar en el mapa cuando se amplíe.

## Tamaño: 20 × 20 m, como el módulo de habitat

Todos los módulos de habitación usan **exactamente la retícula de
`scenes/habitat_decor.tscn`**, para que encajen entre sí y con el módulo
principal sin costuras:

- **Suelo**: 5 × 5 baldosas de 4 m con centros en −8, −4, 0, 4, 8 → de −10 a
  +10 en X y Z (20 × 20 m).
- **Paredes**: 5 paneles de 4 m por lado, centrados en ±9,6 (la cara interior
  queda en ±9,23). El panel de la puerta (`Wall_With_Door_Grey`) va en la pared
  sur, en x = 0.
- **Techo**: 21 baldosas + 4 luminarias en (±4, ±4) (y 8 luminarias en las
  salas técnicas). Las luminarias cuelgan en y = 3,66 para no hacer z-fighting.
- **Luces**: un `OmniLight3D` por luminaria, en y = 3,45.
- **Colisión**: nodo `Collision` (`StaticBody3D`) con una caja de suelo
  (20 × 0,4 × 20) y una por cada panel de pared. La puerta se modela con
  **dos tramos** para dejar un hueco de 1,6 m.

Excepción: `corridor_module` es un pasillo de **8 × 8 m** (dos tramos de
`Corridor_Boundary_4x8` del pack), porque su función es conectar, no alojar.

Estructura de nodos de cada módulo:

```
RoomX (Node3D)
├── Floor (Node3D)     → baldosas de suelo (+ decals de suelo)
├── Ceiling (Node3D)   → baldosas de techo + luminarias
├── Lights (Node3D)    → OmniLight3D
├── Walls (Node3D)     → paneles de pared
├── Props (Node3D)     → mobiliario
├── Shell (Node3D)     → solo si el módulo usa piezas cerradas (el pasillo)
└── Collision (StaticBody3D) → cajas invisibles
```

- `scenes/rooms/rooms_preview.tscn` coloca los módulos en fila (22 m de
  separación) para compararlos. **No forma parte del juego.**

## Módulos disponibles

| Escena | Habitación | Identidad |
|--------|------------|-----------|
| `room_cafeteria.tscn` | Comedor | `Wall_Orange`, alfombra gris, mesa grande y sillas, mesas de cafetería, lámpara de pie, menú en la pared |
| `room_quarters.tscn` | Cuartos de la tripulación | `Wall_Blue`, alfombra azul, 5 literas + 2 dobles, mesitas, pantallas personales |
| `room_generator.tscn` | Sala del generador | `Wall_Grey`, rejilla metálica, generador, pila, 8 baterías, tuberías, panel de estado |
| `room_control.tscn` | Sala de control | placa de mando, consola, monitor gigante, 6 sillas, `Command_Wall` |
| `room_hydroponics.tscn` | Hidroponía | `Wall_Green` + cristal, cultivos, bancales, luminaria de cultivo |
| `room_medbay.tscn` | Enfermería / criotanque | suelo médico, 5 literas, criotanques, biomonitores, tablero |
| `room_briefing.tscn` | Sala de reuniones | `Wall_Orange`, alfombra naranja, mesa octogonal y 12 sillas, pantallas |
| `room_storage.tscn` | Almacén / taller | rejilla, pilas de energía, pasarela elevada, barandilla, baterías |
| `corridor_module.tscn` | Pasillo (8 × 8 m) | dos tramos de `Corridor_Boundary_4x8` con suelo de vía central |

## Módulos `IMG_*` (recreados desde `assets/IMG/`)

Segundo juego de módulos, recreado a partir de las **fotos de referencia** que
hay en `assets/IMG/` (renders del pack Molten Maps). También de **20 × 20 m** y
con el mismo mobiliario que las fotos, repartido en las 25 baldosas:

| Escena | Referencia | Habitación identificada | Contenido |
|--------|------------|------------------------|-----------|
| `IMG_vestibulo.tscn` | `6bDelJ.jpg` | Vestíbulo / módulo de acceso | Pantalla grande en la pared oeste, puesto de control a escala, 9 baterías verdes apiladas, ventanal de cristal, barandilla y escalera de servicio (`Ramp_Grey`) al este |
| `IMG_sala_de_mando.tscn` | `pGXT9C.jpg` | Sala de mando | `Orrery` central con el holograma, suelo `Floor_Metal_Circles`, 6 puestos de trabajo con lámpara, `Command_Wall`, ventanas de cristal |
| `IMG_sala_del_generador.tscn` | `PjBOyt.jpg` | Sala del generador | Paredes `Wall_Red`, generador naranja, 8 baterías, franja de peligro, panel de estado, escalera de servicio |
| `IMG_enfermeria.tscn` | `9tMILo.jpg` | Enfermería | 7 camas `Bunk_Single_Green` + litera doble, paredes `Wall_Green`, biomonitores y alfombra verde |
| `IMG_criotanque.tscn` | `bK2PlK.jpg` | Criotanque | 5 cápsulas `Cryo_Tube_ON` encendidas y 2 apagadas, paredes `Wall_Blue`, suelo médico, apliques y biomonitor rojo |
| `IMG_cuartos.tscn` | `DnG84u.jpg` | Cuartos | Litera doble y 5 literas `Bunk_Single_Blue`, panel rojo de acento, tablero de ajedrez, sillas y apliques |
| `IMG_sala_de_reuniones.tscn` | `S4lJ0w.jpg` | Sala de reuniones | Mesa octogonal con 12 sillas, 2 pantallas de briefing, pantallas de pared y ventanas azules |
| `IMG_sala_del_orrery.tscn` | `vnoCXw.jpg` | Sala del orrery | `Orrery` con holograma magenta, banco largo (`Meeting_Table`), monitor grande, displays y lámpara de pie |

Notas:

- Las **franjas de peligro** (`Hazard_Floor_1`) y las losas grandes de suelo
  (`Floor_Command_Large`, `Floor_Medbay_Large`) van en el nodo `Floor`: son
  superficie de apoyo y los muebles se apoyan encima.
- Las **escaleras** (`Ramp_Grey`) son piezas de 4 × 4 m con paredes propias, así
  que van **fuera** del módulo (justo al otro lado del ventanal), como se ven
  en las fotos.
- Las piezas **cerradas** (los tramos de pasillo) van en el nodo `Shell`: su
  AABB engloba el módulo entero y daría solapes falsos.

## Colocarlos en el mapa

Los módulos miden 20 × 20 m de suelo y sus paredes ocupan 0,74 m: el paso entre
módulos contiguos es de **20,74 m** (o 21 m si se deja holgura). El pasillo
(8 × 8 m) se coloca entre medias para unir filas.

```powershell
# módulo n de una fila
position = (0, 0, n * 21)
```

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
