# Effects

Dieses Dokument beschreibt die wiederverwendbaren Effektdefinitionen in B.O.N.K.

## Effect Types

| Action            | Beschreibung                                                     | Parameter                                            |
| ----------------- | ---------------------------------------------------------------- | ---------------------------------------------------- |
| `heal`            | Stellt Gesundheit wieder her.                                    | `amount`                                             |
| `armor`           | Verändert die Rüstung für eine bestimmte Dauer.                  | `amount`, `duration`, optional `damage_types`        |
| `movement_speed`  | Verändert die Bewegungsgeschwindigkeit für eine bestimmte Dauer. | `multiplier`, `duration`                             |
| `damage_modifier`  | Verändert den verursachten Schaden für eine bestimmte Dauer.     | `multiplier`, `duration`, optional `damage_types`    |
| `poison`          | Verursacht über einen bestimmten Zeitraum regelmäßig Schaden.    | `damage`, `damage_type`, `duration`, `tick_interval` |


`damage_types` ist eine Liste und kann beispielsweise `physical` und `magic` enthalten.

Multiplikatoren beziehen sich auf den normalen Wert. `1.25` entspricht 125 %, `0.5` entspricht 50 %.

## Effect File Format

Jeder Effekt wird in einer eigenen YAML-Datei beschrieben:

`assets/data/effects/<effect-id>.yaml`

Effekte definieren ihre Wirkungsart, Standardwerte und optional zugehörige Assets. Items, Fähigkeiten, Fallen und andere Spielsysteme können Effekte über ihre ID referenzieren.

## Effect Examples

### Slow

```yaml
id: slow
type: movement_speed

defaults:
  multiplier: 0.5
  duration: 4.0

assets:
  status_sprite: sprites/effects/slow-status.png
  audio:
    apply: sounds/effects/slow-apply.wav
    expire: sounds/effects/slow-expire.wav
````

### Poison

```yaml
id: poison
type: poison

defaults:
  damage: 5
  damage_type: magic
  duration: 6.0
  tick_interval: 1.0

assets:
  status_sprite: sprites/effects/poison-status.png
  audio:
    apply: sounds/effects/poison-apply.wav
    expire: sounds/effects/poison-expire.wav
```

Bei `poison` beschreibt `damage` den Schaden pro Tick. `tick_interval` bestimmt den Abstand zwischen den einzelnen Schadensanwendungen.

Bei einer `duration` von `6.0` Sekunden und einem `tick_interval` von `1.0` Sekunden wird der Schaden beispielsweise sechs Mal angewendet. Mit `damage: 5` entstehen dadurch insgesamt 30 Schaden, sofern jeder Tick erfolgreich angewendet wird.

`damage_type` bestimmt die Schadensart des periodischen Schadens. Im Beispiel ist der Giftschaden zunächst `magic`.

## Effect Definition

Eine Effektdefinition enthält:

* `id`: Eindeutige ID des Effekts.
* `type`: Art der Wirkung, beispielsweise `heal`, `armor`, `movement_speed`, `damage_modifier` oder `poison`.
* `defaults`: Standardwerte für konfigurierbare Parameter wie `amount`, `damage`, `multiplier`, `duration` und `tick_interval`.
* `assets`: Optionale visuelle und akustische Ressourcen.

Unterstützte Assets:

* `assets.status_sprite`: Sprite für die Darstellung eines aktiven Status.
* `assets.audio.apply`: Sound beim Anwenden.
* `assets.audio.expire`: Sound beim Ablauf.

Alle Asset-Felder sind optional.

## Effect References and Overrides

Spielobjekte referenzieren Effekte über deren `id`. Optionale `overrides` überschreiben einzelne konfigurierbare Standardwerte, ohne die ursprüngliche Effektdefinition zu verändern.

Beispiel für eine Effekt-Referenz in einem Item:

```yaml
effects:
  - id: poison
    overrides:
      damage: 8
      duration: 10.0
      tick_interval: 0.5
```

Nicht angegebene Werte werden aus `defaults` übernommen. `id`, `type` und die grundlegende Wirkungslogik können nicht überschrieben werden.

Der Effekt kann dadurch in unterschiedlichen Spielsystemen mit verschiedenen Stärken und Dauern verwendet werden.

## Effect Parameters

### `heal`

* `amount`: Einmalig wiederherzustellende Gesundheit.

### `armor`

* `amount`: Veränderung der Rüstung.
* `duration`: Dauer des Effekts.
* `damage_types`: Optional betroffene Schadensarten.

### `movement_speed`

* `multiplier`: Multiplikator auf die normale Bewegungsgeschwindigkeit.
* `duration`: Dauer des Effekts.

### `damage_modifier`

* `multiplier`: Multiplikator auf den verursachten Schaden.
* `duration`: Dauer des Effekts.
* `damage_types`: Optional betroffene Schadensarten.

### `poison`

* `damage`: Schaden, der pro Tick verursacht wird.
* `damage_type`: Schadensart des periodischen Schadens, beispielsweise `magic` oder `physical`.
* `duration`: Gesamtdauer des Effekts.
* `tick_interval`: Zeit zwischen zwei Schadensanwendungen.


## Runtime State

Die Effektdatei definiert nur die wiederverwendbare Konfiguration. Aktive Effekte, betroffene Ziele, verbleibende Dauer, angewendete Werte, Tick-Timer und Stapelzustände werden zur Laufzeit verwaltet.

Bei periodischen Effekten wie `poison` wird insbesondere der aktuelle Tick-Zeitpunkt beziehungsweise die verbleibende Zeit bis zur nächsten Schadensanwendung im Runtime State verwaltet.

Regeln für das Stapeln, Erneuern und Ersetzen aktiver Effekte werden separat durch das Effektsystem festgelegt.
