class_name MissionConfig
extends Resource

## Configuración data-driven de una misión.
## Todos los valores ajustables del juego viven aquí (regla "gameplay.md": sin números mágicos).

@export_group("Objetivo de misión")
## Duración de la misión en segundos. Sobrevivir este tiempo = victoria.
@export var mission_duration: float = 240.0
## Segundos que debe durar el estado BRIEFING antes de iniciar la mission activa.
@export var briefing_duration: float = 3.0

@export_group("Capacidades máximas")
@export var max_oxygen: float = 100.0
@export var max_energy: float = 100.0
@export var max_water: float = 100.0
@export var max_structure: float = 100.0

@export_group("Tasas de decaimiento (unidades por segundo)")
@export var oxygen_decay_rate: float = 0.5
@export var energy_decay_rate: float = 0.3
@export var water_decay_rate: float = 0.2
@export var structure_decay_rate: float = 0.1

@export_group("Emergencias")
## Segundos mínimos y máximos entre eventos de emergencia.
@export var emergency_interval_min: float = 25.0
@export var emergency_interval_max: float = 45.0
## Rango de severidad (0.0 = leve, 1.0 = catastrófico).
@export var emergency_severity_min: float = 0.3
@export var emergency_severity_max: float = 0.8

@export_group("Puntuación")
## Puntos por segundo survival durante la misión.
@export var score_per_second: float = 1.0
## Bonus de puntuación por cada punto de recurso restante al completar.
@export var score_per_remaining_resource: float = 2.0

@export_group("Umbrales")
## Porcentaje por debajo del cual un recurso se considera crítico.
@export_range(0.0, 100.0, 1.0) var critical_threshold: float = 20.0
## Cantidad restaurada por cada interacción con una consola.
@export var console_restore_amount: float = 25.0
