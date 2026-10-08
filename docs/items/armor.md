# Armor

Dieses Dokument beschreibt die technischen Definitionen für Rüstung in B.O.N.K.
und wird von [game-design.md](../game-design.md) referenziert.

Die Schadensreduktion verwendet zunächst folgende Formel:

```text
tatsächlicher Schaden = Eingangsschaden × 100 / (100 + armor)
```

## Armor Types

- `head`
- `body`
- `feet`

## Armor File Format

Jedes Rüstungsteil wird in einer eigenen YAML-Datei beschrieben:

```text
assets/items/armor/<armor-id>.yaml
```

`type` bestimmt den kompatiblen Rüstungsslot. Die zentralen Typen sind
zunächst `head`, `body` und `feet`.

```yaml
id: iron_helmet
display_name: Iron Helmet
description: A sturdy helmet that protects against physical damage.

type: head

stats:
  armor:
    physical: 25
    magic: 0

assets:
  world_sprite: sprites/items/armor/iron-helmet.png
  equipped_sprite: sprites/items/armor/iron-helmet-equipped.png
```

Die zwei Werte unter `stats.armor` sind für jedes Rüstungsteil erforderlich:

- `physical` schützt vor physischem Schaden.
- `magic` schützt vor magischem Schaden.

Die Werte werden beim Anlegen zur Charakterrüstung in derselben Schadensart
addiert. Ein Rüstungsteil kann dadurch gegen eine Schadensart stark und gegen
andere Schadensarten schwach oder wirkungslos sein. `type` ist keine
Schadensart und bestimmt ausschließlich den kompatiblen Ausrüstungsslot.
