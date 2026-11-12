# Leyes del Agente — Proyecto NaSA-GAME (Godot 4.7.2)

Este archivo contiene las reglas estrictas que rigen todo el desarrollo autónomo en este proyecto. Su incumplimiento no está permitido.

## 1. Motor objetivo
- **Godot 4.7.2** es la única versión soportada.
- **Prohibido** usar sintaxis deprecada o eliminada de versiones anteriores (Godot 3.x o 4.x anteriores).
- Toda la API usada debe ser vigente en Godot 4.7.2.

## 2. Tipado en GDScript
- **Tipado estricto obligatorio** en todos los archivos `.gd`.
- Cada script debe iniciar con `@tool` solo cuando sea necesario; de lo contrario usar `extends <Nodo>` con tipado explícito en variables, parámetros de funciones y valores de retorno.
- Ejemplo de cabecera válida:
  ```gdscript
  extends Node2D

  @export var velocidad: float = 300.0
  var vida_maxima: int = 100

  func _ready() -> void:
      pass

  func recibir_dano(cantidad: int) -> bool:
      pass
  ```

## 3. Prototipado visual (Greyboxing)
- Se debe usar obligatoriamente primitivas geométricas de Godot para el prototipado inicial:
  - `BoxMesh` para bloques, suelos, paredes y cajas.
  - `CapsuleMesh` para personajes y enemigos.
- **Prohibido** intentar renderizar o calcular geometría local pesada (mallas personalizadas, CSG complejo, procedural pesado) durante la fase de greyboxing.
- Los modelos finales sólo se integrarán una vez aprobados y ubicados en `res://ai_assets/`.

## 4. Recursos externos (texturas y modelos 3D)
- Cualquier textura o modelo 3D solicitado a APIs externas (IA generativa o bibliotecas de assets) debe:
  1. Descargarse o enlazarse dentro de la carpeta `res://ai_assets/`.
  2. Nunca guardarse fuera de esa ruta.
  3. Referenciarse desde el proyecto usando rutas `res://ai_assets/...`.

## 5. Estructura de directorios obligatoria
| Carpeta | Contenido esperado |
|---------|--------------------|
| `scenes/` | Escenas principales y de niveles (`.tscn`) |
| `scripts/` | Lógica de juego en GDScript (`.gd`) |
| `assets/` | Recursos visuales, audio y fuentes |
| `ai_assets/` | Texturas y modelos 3D generados por APIs externas |
| `resources/` | Recursos personalizados (`.tres`) |

## 6. Resolución y orientación
- Ventana estándar de alta definición: **1280x720**.
- Orientación: **horizontal (landscape)**.

## 7. Convenciones generales
- Nombres de archivos y nodos en `snake_case` o `PascalCase` según corresponda (nodos en `PascalCase`, scripts y escenas en `snake_case`).
- No se permite código sin comentarios que expliquen su intención cuando la lógica no sea trivial.
- Cada nueva funcionalidad debe incluir su escena correspondiente en `scenes/` y su script en `scripts/`.

# INTEGRACIÓN DE HERRAMIENTAS EXTERNAS Y APIS
Tienes acceso a servicios en la nube para generar recursos gráficos externos sin saturar el hardware local. Utiliza exclusivamente las siguientes variables de entorno del sistema operativo para autenticar tus peticiones:

1. Modelos 3D (Meshy API):
   - Variable de entorno de autenticación: `MESHY_API_KEY`
   - Uso: Invoca esta API cuando el diseño requiera un asset tridimensional específico que no pueda resolverse mediante primitivas geométricas (*greyboxing*). Exporta el resultado en formato `.glb` o `.obj` directamente dentro de la carpeta `res://ai_assets/`.

2. Texturas y Materiales PBR (Fal.ai u otras APIs configuradas):
   - Variable de entorno de autenticación: `FAL_KEY` (o `TEXTURE_API_KEY`)
   - Uso: Invoca la API para generar mapas de texturas (Albedo, Normal) cuando se requiera realismo en superficies concretas. Guarda los archivos descargados en la ruta `res://ai_assets/`.

# REGLA DE ORO PARA RECURSOS:
Antes de consumir créditos de las APIs externas, prioriza siempre el prototipado rápido mediante nodos nativos de Godot 4.7.2 (`BoxMesh`, `SphereMesh`, `StandardMaterial3D` con colores sólidos). Emplea las APIs de generación solo cuando el hito de desarrollo lo requiera explícitamente.

# 8. USO OBLIGATORIO DE SKILLS (.opencode/skills/)
- Antes de crear o modificar cualquier escena (`.tscn`), script (`.gd`) o recurso (`.tres`), **debes consultar y aplicar las habilidades almacenadas en `.opencode/skills/`**
- **Formato estricto de escenas:** Debes usar la sintaxis exacta especificada en la skill correspondiente para escribir archivos `.tscn` válidos en Godot 4.7.2. Queda estrictamente prohibido adivinar la sintaxis o escribir estructuras `.tscn` incompletas que corrompan el archivo.
- Si una tarea coincide con una habilidad registrada en `.opencode/skills/`, su cumplimiento es de máxima prioridad por encima de la generación estándar.

# 9. PROTOCOLO DE MEMORIA Y CONTEXTO ENTRE SESIONES (.opencode/CONTEXT.md)
Para garantizar la continuidad total del desarrollo si se cierra la sesión o se inicia una nueva, debes administrar activamente el archivo `.opencode/CONTEXT.md` siguiendo este protocolo:

### Lectura al inicio de sesión (MANDATORIO)
Al iniciar cualquier interacción o sesión nueva, lo **primero** que debes hacer es leer `.opencode/CONTEXT.md` para entender el estado actual del proyecto sin necesidad de recargar todo el historial.

### Estructura obligatoria de `.opencode/CONTEXT.md`
El archivo `.opencode/CONTEXT.md` debe mantener siempre la siguiente estructura actualizada:

1. **Resumen General del Proyecto:** Breve descripción del objetivo actual del juego (ej. *Junior Astronaut Mission Trainer*).
2. **¿Qué se hizo? (Historial de Avances):** Lista cronológica de escenas creadas, scripts funcionales, bugs corregidos y mecánicas terminadas.
3. **¿Cómo se hizo? (Arquitectura e Implementación):** Detalles técnicos clave (ej. cómo se comunican las señales, qué scripts manejan el `GameManager`, dependencias entre nodos).
4. **¿Qué hay que hacer? (Pendientes y Siguiente Hito):** Tareas inmediatas y secundarias por realizar en orden de prioridad.
5. **¿Cómo hay que hacerlo? (Directrices del siguiente hito):** Pasos concretos, patrones de diseño o decisiones de arquitectura acordadas para los siguientes componentes a programar.

### Actualización al finalizar tareas (MANDATORIO)
Cada vez que completes una tarea, hito o refactorización significativa, **debes actualizar el archivo `.opencode/CONTEXT.md`** reflejando los nuevos cambios en "¿Qué se hizo?" y actualizando la lista de "¿Qué hay que hacer?".
---
*Archivo generado automáticamente durante la inicialización del entorno. Modificar sólo con consenso del arquitecto.*