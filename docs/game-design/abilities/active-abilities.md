# Active Abilities

Dieses Dokument beschreibt die aktiven Fähigkeiten in B.O.N.K.

## Active Ability Types

| Name           | Beschreibung                                                         |
| -------------- | -------------------------------------------------------------------- |
| `regeneration` | Erhöht die Lebensregeneration für eine bestimmte Dauer.              |
| `dash`         | Bewegt den Spieler um eine bestimmte Distanz in Bewegungsrichtung.   |
| `sniper`       | Erhöht den verursachten physischen Schaden für eine bestimmte Dauer. |
| `mental_focus` | Erhöht den verursachten magischen Schaden für eine bestimmte Dauer.  |
| `tinkerer`     | Gewährt dem Spieler eine explosive Waffe.                            |

## Active Ability File Format

Jede aktive Fähigkeit wird in einer eigenen YAML-Datei beschrieben:

`assets/data/abilities/<ability-id>.yaml`

Fähigkeiten definieren ihre Wirkung, ihren Cooldown und die zugehörigen Parameter. Effekte können über ihre ID referenziert und bei Bedarf mit `overrides` angepasst werden.

## Active Ability Examples

### Regeneration

```yaml
id: regeneration
name: Regeneration

cooldown: 10.0

effects:
  - id: heal_over_time
    overrides:
      duration: 5.0
```

### Dash

```yaml
id: dash
name: Dash

cooldown: 3.0

distance: 64
```

### Sniper

```yaml
id: sniper
name: Sniper

cooldown: 12.0

effects:
  - id: physical_damage_boost
    overrides:
      multiplier: 1.5
      duration: 5.0
```

### Mentale Fokussierung

```yaml
id: mental_focus
name: Mentale Fokussierung

cooldown: 12.0

effects:
  - id: magic_damage_boost
    overrides:
      multiplier: 1.5
      duration: 5.0
```

### Bastler

```yaml
id: tinkerer
name: Bastler

cooldown: 15.0

weapon: explosive_weapon
```

## Active Ability Definition

Eine Fähigkeitsdefinition enthält:

* `id`: Eindeutige ID der Fähigkeit.
* `name`: Anzeigename der Fähigkeit.
* `cooldown`: Zeit bis zur erneuten Verwendung in Sekunden.
* `effects`: Optionale Liste von Effekt-Referenzen.
* `distance`: Bewegungsdistanz, beispielsweise für `dash`.
* `weapon`: ID der gewährten Waffe, beispielsweise für `tinkerer`.

Alle Zeitangaben werden in Sekunden und Distanzen in World Units angegeben.

Die konkreten Werte für Cooldowns und Effekte werden im Rahmen des Game-Balancings festgelegt.
