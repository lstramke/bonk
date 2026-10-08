# Map Design

Dieses Dokument beschreibt die technischen Definitionen für Maps in B.O.N.K. und wird von [game-design.md](../game-design.md) referenziert.

## Map File Format

Jede Map enthält folgende Metadaten:

* `id`: Eindeutige ID der Map.
* `name`: Anzeigename der Map.
* `description`: Beschreibung der Map.
* `tile_size`: Größe eines Tiles in Weltkoordinaten.
* `background`: Pfad zum Hintergrund-Sprite.
* `tile_mapping`: Zuordnung numerischer Tile-IDs zu Tile-Assets.
* `layers`: Definition der Tile-Layer.
* `spawn_points`: Definition möglicher Spawnpositionen.
* `events`: Map-spezifische Events.

YAML wird für die lesbare Map-Definition und deren Metadaten verwendet.

Die Tile-Layer werden zunächst ebenfalls als zweidimensionale Zahlenlisten in YAML dargestellt. Dadurch bleibt das Format einfach und kann direkt mit den vorhandenen Asset-Pfaden verwendet werden.

Da Maps große Raster mit mehreren Tausend Tile-Positionen enthalten können, soll die Tile-Anordnung nicht dauerhaft manuell gepflegt werden müssen.

Langfristig ist ein eigener Map-Editor vorgesehen, der Tile-Layer visuell bearbeiten und die Map-Dateien automatisch erzeugen oder aktualisieren kann.

Das Dateiformat soll so gestaltet werden, dass später eine kompaktere interne Darstellung oder ein binäres Laufzeitformat möglich ist, ohne die grundlegende Map-Struktur ändern zu müssen.

### Map Definition

Beispiel einer Map-Definition:

```yaml
id: arena_01
name: The First Arena

description: Eine Arena für Platformer-Kämpfe.

tile_size: [16, 16]

background: sprites/backgrounds/arena.png

tile_mapping:
  0: null
  1: sprites/tiles/grass_block.png
  2: sprites/tiles/stone_block.png
  3: sprites/tiles/lootbox_block.png

layers:
  - id: terrain
    tiles:
      - [0, 0, 0, 0, 0, 0]
      - [0, 1, 1, 1, 0, 0]
      - [1, 1, 3, 1, 2, 2]
      - [2, 2, 2, 2, 2, 2]

spawn_points:
  - id: player_1
    position: [32, 48]
  - id: player_2
    position: [16, 16]

events: []
```

## Asset Organization

Map-Assets werden zentral unter `assets/` organisiert.

* `assets/maps/`: Map-Definitionen und zugehörige Map-Dateien.
* `assets/sprites/tiles/`: Sprites für Tiles und Blöcke.
* `assets/sprites/characters/`: Sprites für Charaktere.
* `assets/sprites/items/`: Sprites für Items.
* `assets/sounds/`: Soundeffekte.
* `assets/music/`: Musik.

Maps referenzieren Assets über ihre relativen Asset-Pfade. Sprite-Dateien werden nicht in Map-Dateien eingebettet oder dupliziert.

Der Hintergrund ist eine eigenständige visuelle Ebene. Die eigentliche Spielfläche wird durch die Tile-Layer definiert und vor dem Hintergrund dargestellt.

## Tile Mapping

Das `tile_mapping` ordnet numerischen IDs die jeweiligen Tile-Sprites zu.

Beispiel:

```yaml
tile_mapping:
  0: null
  1: sprites/tiles/grass_block.png
  2: sprites/tiles/stone_block.png
  3: sprites/tiles/lootbox_block.png
```

Die Bedeutung der IDs ist damit zum Beispiel:

* `0`: Kein Tile an dieser Position.
* `1`: Grasblock.
* `2`: Steinblock.
* `3`: Lootbox-Block.

Die numerischen IDs werden innerhalb der Map verwendet, um die Tile-Layer kompakt darzustellen.

Eine Lootbox, ein Grasblock oder ein Steinblock ist jeweils ein eigenständiger Tile-Typ. Ein Tile kann neben seinem Sprite eigene Gameplay-Eigenschaften besitzen, beispielsweise Kollisionsverhalten, Zerstörbarkeit oder Interaktionslogik.

Die Gameplay-Eigenschaften sollen nicht allein aus dem Sprite-Pfad oder dem Namen einer Datei abgeleitet werden. Sie werden separat durch die jeweilige Tile-Definition festgelegt.

Die IDs müssen innerhalb einer Map eindeutig sein. Die konkrete Zuordnung darf zwischen unterschiedlichen Maps variieren.

## Tile Layers

Die Spielfläche wird als zweidimensionales Raster definiert.

Jede Tile-Layer besitzt eine eindeutige ID und eine zweidimensionale Anordnung numerischer Tile-IDs.

* Jede innere Liste entspricht einer Zeile entlang der Y-Achse.
* Jeder Eintrag entspricht einer Position entlang der X-Achse.
* `0` kennzeichnet eine leere Position ohne Tile.
* Andere Werte verweisen auf Einträge in `tile_mapping`.

Leere Positionen sind ausdrücklich erlaubt. Sie stellen kein unsichtbares Tile dar, sondern bedeuten, dass an dieser Position kein Tile platziert ist.

Mehrere Layer ermöglichen die getrennte Anordnung verschiedener Tile-Gruppen, beispielsweise Terrain, Dekoration und Vordergrund.

Die Tile-Layer definieren die tatsächliche Spielfläche. Der Hintergrund ist davon unabhängig und muss weder dieselben Abmessungen noch dieselbe Rasterstruktur besitzen.

## Tile Assets

Tile-Sprites werden zentral unter `assets/sprites/tiles/` gespeichert und von Maps referenziert.

Ein Sprite beschreibt die visuelle Darstellung eines Tiles. Es legt nicht automatisch dessen Gameplay-Verhalten fest.

Gameplay-Eigenschaften wie Kollision, Zerstörbarkeit und Interaktionen werden separat definiert, damit derselbe Tile-Typ in verschiedenen Maps wiederverwendet werden kann.

## Spawn Points

Spawnpoints definieren Positionen, an denen Spieler oder andere Entitäten erscheinen können.

Jeder Spawnpoint besitzt eine eindeutige ID und eine Position.

```yaml
spawn_points:
  - id: player_1
    position: [32, 48]

  - id: player_2
    position: [96, 48]
```

`position` verwendet das zweidimensionale Weltkoordinatensystem mit X- und Y-Koordinaten. Spawnpositionen sind nicht an eine bestimmte Tile-ID gebunden.

## Map Events

Maps können eigene Events definieren. Diese können später für map-spezifische Abläufe und Interaktionen verwendet werden.

Solange keine Events definiert sind, bleibt die Liste leer:

```yaml
events: []
```

Die Struktur und das Ausführungsverhalten von Map-Events werden separat festgelegt.

## Rendering

Das Rendering der Map ist von ihrer Definition und Gameplay-Logik getrennt. Die Map-Daten beschreiben die Anordnung der Tiles; die Engine ist für deren Darstellung und Optimierung verantwortlich.

### Rendering Layers

Die Map wird aus mehreren visuellen Ebenen zusammengesetzt:

Background: Eigenständiger Hintergrund, unabhängig von der Tile-Matrix.
Static Layers: Unveränderte Tile-Layer, beispielsweise Terrain und feste Plattformen.
Dynamic Elements: Veränderliche oder animierte Elemente, beispielsweise Spieler, Partikeleffekte und animierte Tiles.

Die Ebenen werden in der festgelegten Zeichenreihenfolge gerendert, damit Vordergrundelemente korrekt vor Hintergrundelementen liegen.

### Render Caching

Statische Tile-Layer sollen nicht in jedem Frame vollständig neu aufgebaut werden.

Die Engine kann statische Layer in Render-Texturen zwischenspeichern und diese Texturen in jedem Frame erneut zeichnen. Dadurch müssen die einzelnen Tiles nicht fortlaufend aus der Tile-Matrix gelesen und einzeln gerendert werden.

Wenn sich ein Tile verändert, beispielsweise durch Zerstörung oder eine Zustandsänderung, muss der betroffene Cache aktualisiert werden. Unveränderte Bereiche sollen dabei erhalten bleiben.

### Dynamic Elements

Animierte, interaktive oder anderweitig veränderliche Elemente können unabhängig von statischen Layern gerendert werden.

Ein interaktives Tile bleibt sichtbar, auch wenn seine Aktion nicht aktiv ist. Seine Gameplay-Logik wird unabhängig von seiner Darstellung verarbeitet. Änderungen an seiner visuellen Darstellung dürfen bei Bedarf den zugehörigen Render-Cache invalidieren.
