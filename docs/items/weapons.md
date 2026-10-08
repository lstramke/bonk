# Weapons

Dieses Dokument beschreibt die technischen Definitionen für Waffen in B.O.N.K.
und wird von [game-design.md](../game-design.md) referenziert.

## Weapon File Format

Jede Waffe wird in einer eigenen YAML-Datei beschrieben:

```text
assets/items/weapons/<weapon-id>.yaml
```

| Bereich | Inhalt |
| --- | --- |
| Identity | Stabile ID, Anzeigename und Beschreibung |
| Classification | Waffentyp und Schadensart |
| Stats | Grundschaden, Schussverhalten, Munition, Projektil, Reichweite |
| Assets | Welt-Sprite, Hand-Sprite, Projektil und Audio |

## Weapon File Example

```yaml
id: weapon_001
display_name: Pistol
description: A reliable short-range weapon.

type: range
damage_type: physical

stats:
  damage:
    base: 20
    projectiles: 1
  firing:
    mode: single
    shots_per_second: 3
    spread: 0
  ammunition:
    magazine_size: 6
    reserve: 18
    reloadable: true
    reload_time: 1.2
  projectile:
    id: pistol_bullet
    speed: 600
    lifetime: 1.0
    radius: 2
  range: 600

assets:
  world_sprite: sprites/items/weapons/pistol.png
  hand_sprite: sprites/items/weapons/pistol-hand.png
  projectile_sprite: sprites/projectiles/pistol-bullet.png
  audio:
    shot: sounds/weapons/pistol-shot.wav
```

`type` beschreibt die Funktions- oder Waffenkategorie. Die zentralen
Waffentypen sind zunächst `melee`, `range` und `explosive`.

`damage_type` beschreibt die Schadensart und muss `physical`, `explosive` oder
`magic` verwenden. Beide Werte werden unabhängig voneinander gespeichert und
gemeinsam zur Bestimmung des Schadensmodifikators verwendet. Eine `range`-Waffe
kann beispielsweise physischen oder magischen Schaden verursachen. `magic` ist
kein Waffentyp, sondern ausschließlich eine Schadensart.

Der Charaktermodifikator wird anhand der Kombination aus `type` und
`damage_type` auf den Grundschaden angewendet. Eine magische Nahkampfwaffe
verwendet beispielsweise `type: melee` und `damage_type: magic`.

## Weapon Stats

`stats.damage`, `stats.firing` und `stats.ammunition` bilden den notwendigen
Kern jeder Waffe:

- `stats.damage.base` ist der Grundschaden eines einzelnen Treffers oder
  Projektils.
- `stats.damage.projectiles` gibt die Anzahl der Projektile pro Angriff an.
  Der Standardwert ist `1`.
- `stats.firing.mode` definiert mindestens `single`; später sind `automatic`
  oder `charge` möglich.
- `stats.firing.shots_per_second` ist für wiederholbare Angriffe erforderlich.
- `stats.firing.spread` definiert die Streuung und kann `0` sein.
- `stats.ammunition` ist nur für Waffen mit Munition erforderlich.

`stats.firing.charge_time` ist optional für aufladbare Angriffe.
`stats.ammunition.reserve` ist optional für unbegrenzte oder anders verwaltete
Reserven. `stats.projectile` wird benötigt, wenn ein eigenständiges Projektil
erzeugt wird; Geschwindigkeit, Lebensdauer und Radius sind dann erforderlich.
`stats.range` ist für alle Waffen erforderlich. `stats.effects` ist optional
für zusätzliche Trefferwirkungen wie Rückstoß.

`assets.audio.shot` verweist auf den erfolgreichen Schuss-Sound. Die aktuellen
Munitionswerte, der Magazininhalt und die verbleibende Nachladezeit gehören zum
Laufzeitstatus und nicht in die Waffendatei.

## Weapon Types

Die folgenden Waffentypen sind aktuell festgelegt:

- `melee`
- `range`
- `explosive`

Die technische Ausarbeitung der Subtypen und ihrer spezifischen Werte folgt in
diesem Dokument.
