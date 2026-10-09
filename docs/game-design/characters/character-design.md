# Character Design

Für jeden Charakter wird eine eigene YAML-Datei im Asset- beziehungsweise
Content-Bereich angelegt. Die Datei beschreibt die festen Eigenschaften des
Charakters und verweist auf die benötigten visuellen Assets. Der aktuelle
Spielzustand, zum Beispiel die verbleibende Gesundheit oder ein laufender
Cooldown, gehört nicht in diese Datei.

### Character File Format

Die Charakterdateien liegen unter:

```text
assets/data/characters/<character-id>.yaml
```

#### Character Defaults Example

Die globalen Standardwerte liegen separat unter:

```text
assets/data/configs/character-defaults.yaml
```
Die Standarddatei enthält die gemeinsame Ausgangsstruktur. Eine Charakterdatei
muss nur Pflichtfelder und Werte enthalten, die vom Standard abweichen.

```yaml
stats:
  movement_speed: 180
  health: 100
  health_regeneration: 0
  armor:
    physical: 0
    magic: 0
  damage_modifiers:
    melee:
      physical: 1.0
      magic: 1.0
    range:
      physical: 1.0
      magic: 1.0
    explosive:
      physical: 1.0
      magic: 1.0
abilities:
  passive: []

equipment:
  starting_items: []
```

Jede Charakterdatei muss mindestens folgende Bereiche enthalten:

| Bereich | Inhalt |
| --- | --- |
| id | Stabile ID |
| display_name | Anzeigename |
| description | kurze Beschreibung |
| role_id | Stabile Referenz auf eine eigene Rollendatei |
| Stats | Initiale Bewegungsgeschwindigkeit, Gesundheit, Gesundheitsregeneration, Rüstung und Schadensmodifikatoren |
| Abilities | Referenzen auf aktive und optionale passive Fähigkeiten |
| Equipment | Optionale Start-Items und Regeln für besondere Ausrüstung |
| Collision | Körpergröße, Collider und Duck-Höhe |
| Assets | Sprite-Sheet, Animationen, UI-Icon, Porträt und Audio-Referenzen |

### Character File Example

```yaml
id: character_id
display_name: Character Name
description: Short description of the character concept.
role_id: role_bruiser

stats:
  movement_speed: 180
  health: 100
  health_regeneration: 0
  armor:
    physical: 0
    magic: 0
  damage_modifiers:
    melee:
      physical: 1.0
      magic: 1.0
    range:
      physical: 1.0
      magic: 1.0
    explosive:
      physical: 1.0
      magic: 1.0
abilities:
  active:
    id: ability_id
  passive: []

equipment:
  starting_items: []

collision:
  width: 32
  height: 64
  crouch_height: 40
  pivot: [16, 64]

assets:
  sprite_sheet: sprites/characters/character_id.png
  frame_size: [32, 64]
  scale: 1.0
  pivot: [16, 64]
  icon: ui/characters/character_id-icon.png
  portrait: ui/characters/character_id-portrait.png
  animations:
    idle: idle
    run: run
    jump: jump
    fall: fall
    crouch: crouch
    hurt: hurt
    death: death
  audio:
    footsteps: sounds/characters/character_id-footsteps.wav
    hurt: sounds/characters/character_id-hurt.wav
    death: sounds/characters/character_id-death.wav
```

Die Werte unter `stats` bilden die initialen Charakterwerte für das Spiel:

- `movement_speed` definiert die grundlegende Bewegungsgeschwindigkeit.
- `health` definiert die maximale Gesundheit und den Ausgangswert zu
  Rundenbeginn, sofern der Charakter keine abweichende Regel besitzt.
- `health_regeneration` definiert die passive Gesundheitsregeneration.
- `stats.armor` definiert getrennte Rüstungswerte für physische und magische
  Schadensarten.
- `stats.damage_modifiers` verändert den verursachten Schaden je nach
  Kombination aus Waffentyp und Schadensart.
  Der Wert `1.0` entspricht 100 Prozent des normalen Schadens,
  `2.0` entspricht 200 Prozent und `0.5` entspricht 50 Prozent.

Die äußeren Kategorien in `stats.damage_modifiers` entsprechen den zentral
definierten Waffentypen. Die inneren Kategorien entsprechen den zentral
definierten Schadensarten. Dadurch können Charaktere gezielt bestimmte
Kombinationen verstärken:

```yaml
# Ritter: spezialisiert auf physische Nahkampfangriffe
damage_modifiers:
  melee:
    physical: 2.0
    magic: 1.0

# Kampfmagier: spezialisiert auf magische Nahkampfangriffe
damage_modifiers:
  melee:
    physical: 1.0
    magic: 2.0

# Sprengmeister: spezialisiert auf explosive Angriffe
damage_modifiers:
  explosive:
    physical: 2.0
    magic: 1.0
```

Ein Bonus für `melee.physical` gilt nur für eine Waffe, deren Werte
`type: melee` und `damage_type: physical` enthalten. Eine magische
Nahkampfwaffe verwendet stattdessen `melee.magic`.
Eine physische Explosivwaffe verwendet `explosive.physical`, eine magische
Explosivwaffe `explosive.magic`. Es gibt keinen separaten
Fallback vom kombinierten Wert auf den Waffentyp; nicht spezifizierte
Kombinationen werden beim Erzeugen der vollständigen Charakterdaten mit dem
Standardwert `1.0` ergänzt.

Jeder Charakter besitzt einen eigenen Rüstungswert für jede der zwei Schadensarten:

- `physical` für stumpfen und spitzen Schaden,
- `magic` für magischen Schaden.

Die Rüstungswerte des Charakters werden mit den Rüstungswerten der angelegten
Gegenstände in derselben Schadensart addiert. Eine separate Resistenz-Eigenschaft gibt es
nicht; die Schadensreduktion wird ausschließlich aus der passenden
Rüstungskategorie berechnet.

Die Schadensreduktion verwendet zunächst folgende Formel:

```text
tatsächlicher Schaden = Eingangsschaden × 100 / (100 + armor)
```

Dabei ist `stats.armor` die Summe aus der Charakterrüstung und der Rüstung der
angelegten Gegenstände in der jeweiligen Schadensart. Bei `0` Rüstung wird der
volle Schaden verursacht, bei `100` Rüstung die Hälfte. Die Formel erzeugt
eine abnehmende Wirkung zusätzlicher Rüstung; konkrete Grenzwerte können beim
Balancing festgelegt werden.

`stats.damage_modifiers` wird anhand der beiden Waffenwerte `type` und
`damage_type` auf den Grundschaden angewendet. Für jedes Projektil gilt:

```text
Eingangsschaden =
  stats.damage.base × damage_modifiers[type][damage_type]
```

Verursacht eine Waffe mehrere Projektile, besitzt jedes Projektil seinen
eigenen Grundschaden und wird separat berechnet. Erst danach wird beim Ziel die
passende Armor-Kategorie anhand von `damage_type` angewendet.

`health_regeneration` wird in Gesundheit pro Sekunde angegeben. Sie wirkt nur,
wenn sich der Spieler außerhalb des Kampfes befindet, und kann die maximale
Gesundheit nicht überschreiten. Die genaue Definition von „außerhalb des
Kampfes“ wird zusammen mit dem Schadens- und Kampfsystem festgelegt.

`role_id` verweist über eine stabile ID auf eine eigene Rollendatei. Der
sichtbare Rollenname wird ausschließlich über `display_name` der Rollendatei
definiert. Unter `abilities.active` wird die
verpflichtende aktive Fähigkeit referenziert. `abilities.passive` enthält
optionale Referenzen auf passive Fähigkeiten. Beide Fähigkeitstypen werden in
eigenen Dateien angelegt. `starting_items` ist optional und standardmäßig leer.

Beim Laden werden die globalen Standardwerte zuerst geladen und anschließend
mit den Werten der Charakterdatei überschrieben. Die erzeugte Player-Struktur
enthält danach immer alle benötigten Werte und muss während der Spielsitzung
keine fehlenden Felder behandeln. Die Standardwerte sind dadurch zentral
sichtbar und müssen nicht in jeder Charakterdatei wiederholt werden.

Pflichtfelder wie `id`, `display_name`, `description`, `role_id`,
`abilities.active.id` und die grundlegenden Asset-Referenzen müssen angegeben
werden. Fehlen sie, ist die
Charakterdatei ungültig und darf nicht als spielbarer Charakter geladen werden.

Jeder Charakter besitzt genau eine aktive Fähigkeit. `starting_items` ist optional und
kann leer bleiben, wenn ein Charakter ohne Startausrüstung beginnen soll.

Die grundlegenden Bewegungsaktionen wie Laufen, Springen und Ducken sind für
alle Charaktere gleich. Nur die Bewegungsgeschwindigkeit kann sich zwischen
Charakteren unterscheiden. Die konkreten Werte für Gesundheit und Fähigkeiten werden erst bei
der Ausarbeitung des jeweiligen Charakters festgelegt. Neue Charaktere sollen
dieselbe Dateistruktur verwenden, damit sie ohne Sonderformat in die
Spielauswahl aufgenommen werden können.

### Role File Example

Rollendateien liegen separat unter:

```text
assets/roles/<role-id>.yaml
```

Eine Rolle beschreibt gemeinsame Design- und Content-Gewichtungen, ohne die
individuellen Charakterwerte zu ersetzen. Eine Rolle kann beispielsweise
festlegen, dass ein `bruiser` bei Lootboxen häufiger Nahkampfwaffen angeboten
bekommt.

```yaml
id: role_001
display_name: Bruiser
description: Close-range focused role.

loot_preferences:
  weapons:
    melee: 2.0
    range: 1.0
    explosive: 1.0
  armor:
    physical: 1.0
    magic: 1.0
  potions: 1.0
```

Die Werte unter `loot_preferences` sind Gewichtungen und keine direkten
Garantien. Die konkrete Lootbox entscheidet anhand dieser Gewichtungen und
ihres eigenen Inhalts, welcher Gegenstand angeboten werden kann.

### Character Sprite and Equipment Layers

Der Charakter und seine Ausrüstung werden als getrennte visuelle Ebenen
gerendert. Dadurch müssen nicht für jede Kombination aus Charakter, Helm,
Körperrüstung, Schuhen und Waffe eigene Sprite-Sheets erstellt werden.

Die Ebenen verwenden dasselbe Koordinatensystem, dieselbe Frame-Größe und
denselben Fußpunkt:

1. Charakter-Sprite als Basis,
2. angelegte Rüstung als passende Overlay-Ebenen,
3. gehaltener Gegenstand oder Waffe an einem definierten Hand- beziehungsweise
   Waffen-Ankerpunkt,
4. optionale Effekte über den übrigen Ebenen.

Rüstung und Waffen benötigen daher eigene Sprite-Referenzen und können
Animationszustände oder Richtungsvarianten bereitstellen. Die Charakterdatei
referenziert die Basis-Assets; die Item-Dateien referenzieren die jeweiligen
Overlay- und Hand-Assets. Eine Ausrüstung kann dadurch beim Aufnehmen,
Anlegen, Fallenlassen und Wechseln sichtbar ein- und ausgeblendet werden.

Der sichtbare Sprite und der physische Collider sind getrennt. Der Collider
bestimmt Kollisionen und verwendet den Fußpunkt als stabile Position. Das
Sprite darf über den Collider hinausragen, ohne die Kollisionsfläche zu
verändern.

### Character Collision

Der stehende Collider beschreibt die normale Körperfläche. Beim Ducken wird
seine Höhe auf `crouch_height` reduziert, während der Fußpunkt an derselben
Stelle bleibt. Ein Spieler kann nur wieder aufstehen, wenn oberhalb des
reduzierten Colliders ausreichend Platz für den stehenden Collider vorhanden
ist. Die verwendeten Maßeinheiten werden global für das Spiel festgelegt.
