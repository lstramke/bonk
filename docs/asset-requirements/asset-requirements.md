# Asset Requirements

Dieses Dokument definiert die grundlegende Ordnerstruktur und Organisation der Assets in B.O.N.K.

## Rules

- Jede YAML-Definition muss eine eindeutige `id` besitzen.
- IDs werden in `snake_case` geschrieben, beispielsweise `lootbox`, `health_potion` oder `arena_01`.
- Dateinamen werden ebenfalls in `snake_case` geschrieben.
- Jede Definition wird in einer eigenen korrekten YAML-Datei gespeichert.

## Asset Directory Structure

```text
assets/
├── maps/
│   └── <map-id>/
│       └── map.yaml
│
├── sprites/
│   ├── backgrounds/
│   ├── tiles/
│   ├── characters/
│   ├── items/
│   │   ├── weapons/
│   │   ├── potions/
│   │   └── armor/
│   └── effects/
│
├── sounds/
│
├── music/
│
└── data/
    ├── tiles/
    ├── characters/
    ├── items/
    ├── weapons/
    ├── potions/
    ├── armor/
    ├── effects/
    └── abilities/
```

## Directory Responsibilities

* `maps/`: Map-Definitionen und zugehörige Map-Daten.
* `sprites/`: Visuelle Assets wie Hintergründe, Tiles, Charaktere, Items und Effekte.
* `sounds/`: Soundeffekte.
* `music/`: Musikdateien.
* `data/`: YAML-Definitionen für Gameplay-Elemente und deren Eigenschaften.
