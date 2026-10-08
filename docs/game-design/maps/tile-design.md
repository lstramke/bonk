# Tile Design

Dieses Dokument beschreibt die technischen Definitionen für Tiles in B.O.N.K. und wird von [map-design.md](./map-design.md) referenziert.

## Tile File Format

Tile-Definitionen beschreiben die visuellen Eigenschaften und das Gameplay-Verhalten eines Tile-Typs. Sie werden zentral gespeichert, damit Tiles über mehrere Maps hinweg wiederverwendet werden können.

Beispiel einer Tile-Definition:

```yaml
id: lootbox
name: Lootbox Block

sprite: sprites/tiles/lootbox_block.png

destructible: false
walkable: true

events:
  - trigger: interact
    action: drop_item
    cooldown: 1.0
```

Die Felder haben folgende Bedeutung:

* `id`: Eindeutige ID des Tile-Typs.
* `name`: Anzeigename des Tile-Typs.
* `sprite`: Relativer Pfad zum Sprite-Asset.
* `destructible`: Gibt an, ob das Tile zerstört werden kann.
walkable: Gibt an, ob eine Entität auf dem Tile stehen beziehungsweise darüber laufen kann.
* `events`: Liste der Events, die das Verhalten des Tiles definieren.
* `trigger`: Legt fest, wodurch ein Event ausgelöst wird.
* `action`: Legt fest, welche Gameplay-Aktion ausgeführt wird.
* `cooldown`: Optionale Wartezeit in Sekunden, bevor das Event erneut ausgelöst werden kann.

## Tile Events

Ein Tile-Event besteht aus einem `trigger` und einer `action`. Der Trigger bestimmt, wann das Event ausgelöst wird; die Action definiert, was daraufhin passiert.

### Unterstützte Trigger

* `interact`: Wird ausgelöst, wenn der Spieler mit dem Tile interagiert.
* `destroy`: Wird ausgelöst, wenn das Tile zerstört wird.

### Unterstützte Actions

* `drop_item`: Wählt ein Item aus dem globalen Item-Pool aus und erzeugt es in der Spielwelt.

### Cooldown

Der optionale `cooldown` definiert die Zeit in Sekunden, die nach einer erfolgreichen Ausführung vergehen muss, bevor dasselbe Event erneut ausgelöst werden kann.

Ohne `cooldown` kann das Event bei jedem gültigen Trigger ausgelöst werden. Ein Cooldown von `0` entspricht keinem Cooldown.

Die Auswahl des Items aus dem globalen Item-Pool sowie die Ausführung und Verwaltung der Events werden durch die Game-Engine implementiert.
