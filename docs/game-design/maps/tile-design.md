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
  - trigger: hit_from_below
    action: drop_item
    event_sprite: sprites/tiles/lootbox_block_open.png
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
* `event_sprite`: Optionaler relativer Pfad zu einem Sprite, das im Zusammenhang mit dem Event angezeigt wird. Das Sprite kann beispielsweise einen veränderten visuellen Zustand des Tiles darstellen, nachdem das Event ausgelöst wurde. Wenn kein `event_sprite` definiert ist, bleibt die Darstellung des Tiles unverändert.

Die Game-Engine verwaltet, wann das Event ausgelöst wird und wie lange das zugehörige Sprite angezeigt wird. Ob die Darstellung dauerhaft wechselt, nur während der Ausführung des Events gilt oder nach einer bestimmten Zeit zurückgesetzt wird, hängt von der Implementierung des jeweiligen Events ab.

## Tile Events

Ein Tile-Event besteht aus einem `trigger` und einer `action`. Der Trigger bestimmt, wann das Event ausgelöst wird; die Action definiert, was daraufhin passiert.
Es kann ein extra sprite dafür hinterlegt werden.

### Unterstützte Trigger

* `hit_from_below`: Wird ausgelöst, wenn der Spieler von unten gegen das Tile springt.
* `destroy`: Wird ausgelöst, wenn das Tile zerstört wird.

### Unterstützte Actions

* `drop_item`: Wählt ein Item aus dem globalen Item-Pool aus und erzeugt es in der Spielwelt.

### Cooldown

Der optionale `cooldown` definiert die Zeit in Sekunden, die nach einer erfolgreichen Ausführung vergehen muss, bevor dasselbe Event erneut ausgelöst werden kann.

Ohne `cooldown` kann das Event bei jedem gültigen Trigger ausgelöst werden. Ein Cooldown von `0` entspricht keinem Cooldown.

Die Auswahl des Items aus dem globalen Item-Pool sowie die Ausführung und Verwaltung der Events werden durch die Game-Engine implementiert.
