# Potions

Dieses Dokument beschreibt die technischen Definitionen für Potions in B.O.N.K.
und wird von [game-design.md](../game-design.md) referenziert.

## Potion Types

- `drink`
- `throw`

## Potion File Format

Jeder Trank wird in einer eigenen YAML-Datei beschrieben:

`assets/data/items/potions/<potion-id>.yaml`

Das Feld `type` definiert die Nutzungsform:

- `drink`: Der Trank wird getrunken und wirkt auf den Träger.
- `throw`: Der Trank wird als Projektil geworfen und wirkt beim Aufprall.

Die Wirkung wird über Referenzen auf Definitionen aus `assets/effects/` festgelegt. 
Ein Trank kann einen oder mehrere Effekte anwenden und deren Standardwerte bei Bedarf überschreiben.

Tränke verursachen keinen direkten Schaden und besitzen keine eigenen Schadenswerte. Ihre Wirkung besteht ausschließlich aus Effekten.

Geworfene Tränke verwenden dieselben technischen Grundstrukturen für Projektilbewegung und Hitboxen wie andere Projektile. Waffen-Schadensmodifikatoren gelten nicht für Tränke.

## Drinking Potion Example

```yaml
id: healing_potion
display_name: Healing Potion
description: Restores health when consumed.
type: drink

stats:
  use_time: 1.0
  target: self
  effects:
    - id: heal
      overrides:
        amount: 40

assets:
  sprite: sprites/items/potions/healing_potion.png
  animation:
    use: sprites/items/potions/healing_potion_use.png
  audio:
    use: sounds/potions/healing_potion_use.wav
```

## Throwing Potion Example

```yaml
id: slow_flask
display_name: Slow Flask
description: Applies a slowing effect on impact.
type: throw

stats:
  use_time: 0.3
  target: area

  projectile:
    speed: 450
    lifetime: 1.5
    hitbox:
      type: circle
      radius: 8
    trajectory: ballistic

  effects:
    - id: slow
      overrides:
        multiplier: 0.5
        duration: 4.0
      area:
        type: circle
        radius: 60

assets:
  sprite: sprites/items/potions/slow-flask.png
  animation:
    use: sprites/items/potions/slow_flask_use.png
    animation:
    flying:
      sprite_sheet: sprites/items/potions/slow_flask_flying.png
      states:
        flying:
          frames: [0, 1, 2]
          frame_duration: 0.1
          loop: true
        hit:
          frames: [3, 4, 5]
          frame_duration: 0.08
          loop: false
  audio:
    use: sounds/potions/slow-flask-use.wav
    impact: sounds/potions/slow-flask-impact.wav
```

## Potion Stats and Runtime State

`stats.use_time` definiert die Aktivierungsdauer. `stats.target` legt das Zielmodell fest, beispielsweise `self`, `target` oder `area`.

`stats.effects` enthält eine Liste von Effekt-Referenzen. Jeder Eintrag benötigt eine `id`, die auf eine Definition in `assets/effects/` verweist. Optionale `overrides` überschreiben die konfigurierbaren Standardwerte des Effekts. Eine optionale `area` definiert den Wirkungsbereich für diese Verwendung.

Bei `type: throw` ist `stats.projectile` erforderlich:

- `speed`: Geschwindigkeit des Projektils.
- `lifetime`: Maximale Flugzeit.
- `hitbox`: Hitbox-Definition.
- `trajectory`: Flugbahn, zunächst `straight` oder `ballistic`.

`straight` bewegt das Projektil ohne Fallbewegung. `ballistic` berücksichtigt die globale beziehungsweise konfigurierte Schwerkraft. Das Projektil endet bei einem gültigen Aufprall oder wenn es die Karte verlässt.

Die Dauer eines Effekts ist unabhängig von der Flugzeit des Projektils.

## Potion Assets

Jeder Trank definiert seine eigenen Item-Assets:

- `assets.sprite`: Sprite in der Spielwelt.
- `assets.animation.use`: Verwendungsanimation, ein Trinken beim type drink, ein Wurf bei type throw.
- `assets.animation.flying`: Animation nach dem Abwurf beim type throw.
- `assets.audio.use`: Sound bei der Benutzung, für alle Tränke erforderlich.
- `assets.audio.impact`: Sound beim Aufprall, erforderlich für `throw`.

Effektbezogene Sprites, Animationen und Sounds werden in der jeweiligen Effektdefinition verwaltet und müssen nicht im Trank dupliziert werden.

## Runtime State

Nach erfolgreicher Anwendung wird der Trank verbraucht. Aktive Effekte, verbleibende Dauer und angewendete Werte gehören zum Laufzeitstatus und nicht in die Item-Datei.