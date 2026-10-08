# Potions

Dieses Dokument beschreibt die technischen Definitionen für Tränke in B.O.N.K.
und wird von [game-design.md](../game-design.md) referenziert.

## Potion File Format

Jeder Trank wird in einer eigenen YAML-Datei beschrieben:

```text
assets/items/potions/<potion-id>.yaml
```

`type` beschreibt die Nutzungsform:

- `drink`: Der Trank wird getrunken und wirkt auf den Träger.
- `throw`: Der Trank wird als Projektil geworfen und wirkt beim Aufprall.

Die Wirkung wird nicht aus dem Typ abgeleitet. Ein `drink`-Trank kann heilen
oder einen positiven Effekt verleihen. Ein `throw`-Trank kann Schaden
verursachen oder einen negativen Effekt anwenden.

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
    - type: heal
      amount: 40

assets:
  world_sprite: sprites/items/potions/healing-potion.png
  hand_sprite: sprites/items/potions/healing-potion-hand.png
  audio:
    use: sounds/potions/healing-potion-use.wav
```

## Throwing Potion Example

```yaml
id: poison_flask
display_name: Poison Flask
description: Applies a damage-over-time effect on impact.

type: throw

stats:
  use_time: 0.3
  target: area
  projectile:
    speed: 450
    lifetime: 1.5
    radius: 8
  effects:
    - type: damage_over_time
      damage_type: magic
      damage_per_second: 10
      duration: 4.0

assets:
  world_sprite: sprites/items/potions/poison-flask.png
  hand_sprite: sprites/items/potions/poison-flask-hand.png
  projectile_sprite: sprites/projectiles/poison-flask.png
  audio:
    impact: sounds/potions/poison-flask-impact.wav
```

## Potion Stats and Runtime State

`stats.use_time` ist die Aktivierungsdauer. `stats.target` definiert das
Zielmodell, zum Beispiel `self`, `target` oder `area`. `stats.effects` enthält
eine oder mehrere Wirkungen. Jede Wirkung benötigt mindestens einen `type`;
zusätzliche Werte wie `amount`, `duration`, `damage_type` oder
`damage_per_second` hängen von der Wirkung ab. Bei geworfenen Tränken ist
`stats.projectile` erforderlich.

`assets.audio.use` ist für jeden Trank erforderlich. Bei `type: throw` ist
zusätzlich `assets.audio.impact` erforderlich; bei `type: drink` wird `impact`
weggelassen.

Ein Trank ist nach erfolgreicher Anwendung verbraucht. Der laufende Effekt, die
verbleibende Dauer und die bereits angewendete Wirkung gehören zum
Laufzeitstatus und nicht in die Item-Datei.

## Potion Types

- `drink`
- `throw`

Die technische Ausarbeitung weiterer Subtypen und Effektdefinitionen folgt in
diesem Dokument.
