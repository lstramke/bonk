# Weapons

Dieses Dokument beschreibt die technischen Definitionen für Waffen in B.O.N.K.
und wird von [game-design.md](../game-design.md) referenziert.

## Damage Types

Waffen können zunächst eine der zwei zentralen Schadensarten verursachen:

- `physical`: Körperlicher Schaden durch direkte Treffer oder physische
  Projektile.
- `magic`: Magischer Schaden durch magische Angriffe und Projektile.

Eine Waffe kann mehrere Schadensarten gleichzeitig verursachen. Der Header
enthält dafür immer eine Liste. Für jeden Eintrag in `damage_type` muss unter
`stats.damage` ein eigener Schadenswert definiert werden.

## Weapon Types

Die folgenden Waffentypen sind aktuell festgelegt:

- `melee`: Direkte Angriffe im Nahbereich.
- `range`: Angriffe über Distanz, üblicherweise mit einem Projektil oder
  Wurfobjekt.
- `explosive`: Angriffe mit einer Explosion oder Flächenwirkung.

Der Waffentyp beschreibt das grundlegende Angriffskonzept und ist unabhängig
von der Schadensart. Eine `explosive`-Waffe kann daher beispielsweise
physischen oder magischen Schaden verursachen.

## First Weapon Draft

Die folgende Tabelle ist ein erster Entwurf für die geplanten Waffen.

| Waffe | Waffentyp | Schadensart | Angriffskonzept | Reichweite | Munition | Rolle |
| --- | --- | --- | --- | ---: | --- | --- |
| Pistole | `range` | `physical` | Einzelnes präzises Projektil, schnell wiederholbar | mittel | Magazin und Reserve | Verlässliche Allround-Waffe |
| Schwert | `melee` | `physical` | Nahkampfangriff mit Trefferbereich vor dem Spieler | sehr kurz | keine | Direkter Nahkampf |
| Zauberstab | `range` | `magic` | Magisches Projektil, optional aufladbar | mittel bis weit | keine oder unbegrenzt | Präziser magischer Fernkampf |
| Granate | `explosive` | `physical` | Wurfobjekt mit Flächenwirkung und Verzögerung | mittel | Einzelobjekt oder begrenzte Reserve | Flächenkontrolle |

Die konkrete Ausgestaltung von Schaden, Cooldowns, Trefferbereichen und
Projektilverhalten wird pro Waffe festgelegt.

## Weapon File Format

Jede Waffe wird in einer eigenen YAML-Datei beschrieben:

```text
assets/items/weapons/<weapon-id>.yaml
```

Alle Waffen verwenden denselben Header:

| Feld | Inhalt |
| --- | --- |
| `id` | Stabile eindeutige ID |
| `display_name` | Anzeigename |
| `description` | Kurze Beschreibung |
| `type` | `melee`, `range` oder `explosive` |
| `damage_type` | Liste aus `physical` und/oder `magic` |

Alle Waffen besitzen außerdem `stats` und `assets`. Die genaue Struktur dieser
beiden Bereiche hängt vom Waffentyp ab. Nicht benötigte Bereiche werden
weggelassen und nicht mit leeren Platzhaltern gefüllt.

## Assets

Der `assets`-Bereich enthält Referenzen für Darstellung und Audio. Die
Referenzen zeigen auf Dateien im Asset-Verzeichnis und werden beim Laden der
Waffe validiert.

```yaml
assets:
  world_sprite: sprites/items/weapons/weapon.png
  hand_sprite: sprites/items/weapons/weapon-hand.png
  audio:
    attack: sounds/weapons/weapon-attack.wav
```

| Asset | Bedeutung | Erforderlich |
| --- | --- | --- |
| `world_sprite` | Darstellung der Waffe auf der Karte | Ja |
| `hand_sprite` | Darstellung der gehaltenen Waffe | Ja |
| `audio.attack` | Sound bei der erfolgreichen Aktivierung des Angriffs | Ja |
| `projectile_sprite` | Darstellung eines erzeugten Projektils | Bei `projectile` |
| `ray_sprite` | Darstellung eines sichtbaren Rays | Bei sichtbarem `ray` |
| `attack_effect` | Visueller Effekt beim Angriff | Optional |
| `muzzle_effect` | Effekt am Ursprung eines Distanzangriffs | Optional |
| `audio.reload` | Sound beim Nachladen | Bei nachladbarer Munition |
| `audio.impact` | Sound beim Aufprall eines Wurfkörpers | Optional |
| `explosion_sprite` | Darstellung der Explosion | Bei sichtbarer Explosion |
| `audio.explosion` | Sound beim Auslösen der Explosion | Bei hörbarer Explosion |

Ein Asset ist nur erforderlich, wenn die zugehörige technische Struktur
verwendet wird. Eine Nahkampfwaffe benötigt beispielsweise kein
`projectile_sprite`; eine Pistole ohne `ray` benötigt kein `ray_sprite`.
Gameplay-relevante Werte wie Hitboxen oder Schaden gehören nicht in den
`assets`-Bereich.

Die aktuellen Munitionswerte, aktive Cooldowns, Flugzeiten und verbleibende
Ausführungszeiten gehören zum Laufzeitstatus und nicht in die Waffendatei.

## Schadens- und Angriffsparameter

Jede Waffe besitzt in `stats` einen Schadens- und Angriffsbereich:

```yaml
damage_type:
  - physical

stats:
  damage:
    physical: 20
  attack:
    mode: single
    cooldown: 0.33
    use_time: 0
```

`stats.damage.<damage_type>` ist der Grundschaden einer Schadensinstanz für
die jeweilige Schadensart.
`stats.attack.mode` definiert die Angriffsform. Die zulässigen Werte hängen vom
Waffentyp ab. `cooldown` definiert die Zeit bis zum
nächsten Angriff. `use_time` definiert die Ausführungs- oder Ladezeit.

### Mehrere Schadensarten

Bei mehreren Einträgen in `damage_type` wird für jede Schadensart ein eigener
Wert unter `stats.damage` angegeben:

```yaml
damage_type:
  - physical
  - magic

stats:
  damage:
    physical: 24
    magic: 16
```

Jeder Schadensanteil wird getrennt gegen den passenden Schadensmodifikator und
Rüstungswert berechnet. Bei einer einzelnen Schadensart enthält `damage_type`
trotzdem eine Liste mit genau einem Eintrag. Ein Schadenswert darf nicht
unter `stats.damage` stehen, wenn die zugehörige Schadensart nicht in
`damage_type` enthalten ist.

## Melee Weapons

Nahkampfwaffen benötigen:

- `stats.range`
- `stats.hitbox`

`stats.range` beschreibt die maximale Distanz des direkten Angriffs.
`stats.hitbox` beschreibt Form, Größe und Position des Trefferbereichs.
Typische zusätzliche Werte sind Rückstoß, Trefferpause und eine
Angriffsanimation.

### Melee Attack Modes

Da B.O.N.K. ein zweidimensionales Spiel ist, werden Nahkampfangriffe über
zweidimensionale Trefferbereiche und Bewegungsrichtungen beschrieben. Für
Nahkampfwaffen sind zunächst folgende Angriffsmodi vorgesehen:

| Modus | Beschreibung | Typischer Trefferbereich |
| --- | --- | --- |
| `stab` | Schneller geradliniger Stich in Blickrichtung. | Schmaler, langer Bereich vor dem Spieler |
| `swing` | Seitlicher oder bogenförmiger Hieb vor dem Spieler. | Breiter Bogen oder kurzer Fächer |

`stab` und `swing` lösen ihren Angriff direkt nach der Ausführungszeit aus.

Jeder Nahkampfangriff benötigt eine Trefferbereichdefinition. Die Form muss
zum Modus passen:

- `stab` verwendet typischerweise eine schmale rechteckige oder kapselartige
  Hitbox.
- `swing` verwendet typischerweise einen Bogen oder einen Fächer.

Besondere Eigenschaften einer Waffe, zum Beispiel eine höhere
Bewegungsgeschwindigkeit während der Führung einer Lanze, werden nicht als
Angriffsmodus modelliert. Dafür ist später ein eigener passiver
Waffen-Effekt vorgesehen. So bleiben Angriffsausführung und zusätzliche
Waffenregeln getrennt.

```yaml
id: sword
display_name: Sword
description: A close-range physical weapon.
type: melee
damage_type:
  - physical

stats:
  damage:
    physical: 35
  attack:
    mode: swing
    cooldown: 0.8
    use_time: 0.25
  range: 70
  hitbox:
    type: arc
    width: 60
    height: 45
    offset: [35, 0]
```
## Range Weapons

Distanzwaffen benötigen:

- `stats.range`
- abhängig vom Angriffsmodus `stats.projectile` oder `stats.ray`

`stats.projectile` beschreibt ein erzeugtes Projektil. `stats.ray` beschreibt
einen direkten Strahl ohne eigenständiges Projektil. `stats.ammunition` wird
nur ergänzt, wenn die Waffe begrenzte Munition und ein Magazin besitzt.
Projektildefinitionen bleiben zunächst Teil der Waffendatei. Eine eigene YAML-
Datei pro Projektil wäre für die wenigen geplanten Waffen unnötig kleinteilig.

### Hitboxes for Projectiles, Wurfkörper und Rays

Projektile, Wurfkörper und Rays verwenden eine gemeinsame `hitbox`-Definition. Der
`hitbox.type` legt die geometrische Form fest; die weiteren Werte hängen von
dieser Form ab:

| Typ | Werte | Verwendung |
| --- | --- | --- |
| `circle` | `radius` | Kleine runde Projektile |
| `rectangle` | `size` | Breite und Länge eines Rays oder eines länglichen Projektils |
| `capsule` | `length`, `radius` | Längliche Projektile mit abgerundeten Enden |
| `arc` | `radius`, `width`, `angle` | Bogenförmige Rays oder Hiebflächen |

Die Hitbox ist die physische Trefferfläche und nicht automatisch identisch mit
dem sichtbaren Sprite. Ihre Position und Ausrichtung werden aus der
Projektil- oder Strahlposition und der Flugrichtung berechnet.

### Range Attack Modes

Für Distanzwaffen sind zunächst drei Angriffsmodi vorgesehen:

| Modus | Beschreibung | Typische Verwendung |
| --- | --- | --- |
| `single` | Erzeugt ein einzelnes Projektil in Schussrichtung. | Pistole oder präziser Zauberstab |
| `splatter` | Erzeugt mehrere Projektile pro Angriff, deren Flugbahnen voneinander abweichen. | Streuender Schuss |
| `ray` | Erzeugt einen direkten Strahl von der Waffe bis zur maximalen Reichweite. | Laser oder gebündelter Zauber |

`single` und `splatter` verwenden `stats.projectile`.

Die Flugbahn wird mit `trajectory` definiert:

- `trajectory: straight` bewegt das Projektil ohne Fallbewegung.
- `trajectory: ballistic` lässt das Projektil durch `gravity` oder `drop`
  absinken.
- `trajectory: wave` bewegt das Projektil wellenförmig quer zur ursprünglichen
  Schussrichtung. Die Wellenform wird über `amplitude` und `frequency`
  festgelegt.

Beispiel für `single` mit einem geraden Projektil:

```yaml
attack:
  mode: single
  cooldown: 0.33
  use_time: 0
projectile:
  speed: 600
  hitbox:
    type: circle
    radius: 2
  trajectory: straight
```

Bei `splatter` wird die Anzahl der Projektile über
`stats.attack.projectiles` festgelegt. `stats.attack.spread` definiert die
maximale Winkelabweichung. Ein Wert von `0` erzeugt eine gerade Projektilreihe;
höhere Werte verteilen die Projektile um die Schussrichtung. Die Werte unter
`stats.damage` gelten für jedes erzeugte Projektil. Eine Waffe mit fünf
Projektilen und `physical: 12` verursacht daher bei fünf Treffern insgesamt
bis zu 60 physischen Schaden vor Rüstung und anderen Modifikatoren.

Beispiel für `splatter` mit fünf gestreuten Projektilen:

```yaml
attack:
  mode: splatter
  projectiles: 5
  cooldown: 0.9
  use_time: 0
  spread: 20
projectile:
  speed: 500
  hitbox:
    type: circle
    radius: 2
  trajectory: straight
```

Ein `ray` verwendet kein `stats.projectile`. Stattdessen definiert
`stats.ray` die Hitbox, Lebensdauer und das Trefferverhalten des Strahls. Ein
Ray wird beim Erzeugen an der aktuellen Position und Blickrichtung des
Schützen ausgerichtet und verändert seine Ausrichtung während seiner
Lebensdauer nicht.

Die Hitbox kann bei einem Ray rechteckig oder bogenförmig sein. Ein
`hitbox.type: arc` beschreibt einen ringförmigen Ausschnitt vor dem Spieler:
`radius` definiert die Entfernung zum Ursprung, `width` die Dicke des Bogens
und `angle` dessen Öffnungswinkel. Die Ausrichtung des Bogens folgt der
Blickrichtung des Spielers.

`stats.attack.use_time` beschreibt die Ausführungs- oder Ladezeit vor dem
Angriff; `stats.ray.lifetime` beschreibt, wie lange der Strahl nach seiner
Erzeugung aktiv bleibt. Ein Strahl kann als einzelner Treffer beim Aktivieren
oder als wiederholter Schaden während seiner Lebensdauer ausgewertet werden.

Beispiel für `ray` mit einem geraden, kurzzeitig aktiven Strahl:

```yaml
attack:
  mode: ray
  cooldown: 0.2
  use_time: 0
ray:
  hitbox:
    type: rectangle
    size: [700, 8]
  lifetime: 1.0
  tick_rate: 10
```

Beispiel für einen bogenförmigen Ray:

```yaml
attack:
  mode: ray
  cooldown: 0.6
  use_time: 0
ray:
  hitbox:
    type: arc
    radius: 180
    width: 24
    angle: 60
  lifetime: 0.2
  tick_rate: 5
```

### Projectile Runtime Object

Beim Ausführen einer Waffe wird aus `stats.projectile` für jedes Projektil ein
eigenständiges Laufzeitobjekt erzeugt. Dieses Objekt enthält neben Bewegung und
Kollision die bereits aufgelösten Schadenswerte der Waffe:

```text
Projectile
├── position
├── velocity
├── collision_shape
├── damage_by_type
├── owner_id
└── source_weapon_id
```

Die Trefferprüfung liest ausschließlich `damage_by_type` aus dem Projektil.
Sie muss nicht erneut die Waffendatei laden oder die Waffe des Schützen
suchen. `owner_id` und `source_weapon_id` bleiben trotzdem erhalten, um
Selbsttreffer, Trefferzuordnung, Effekte und Statistiken zu behandeln. Sie
werden nicht benötigt, um den Grundschaden zu bestimmen.

Dadurch wird bei mehreren Projektilen der Schaden pro Projektil berechnet.
Charaktermodifikatoren, die beim Erzeugen des Angriffs bekannt sind, werden
vor dem Erzeugen in die Schadenswerte eingerechnet. Die Rüstung und andere
zielabhängige Werte werden erst beim Treffer angewendet.

### Examples
Beispiel für eine Pistole mit geradem physischen Projektil:

```yaml
id: pistol
display_name: Pistol
description: A reliable short-range weapon.
type: range
damage_type:
  - physical

stats:
  damage:
    physical: 20
  attack:
    mode: single
    cooldown: 0.33
    use_time: 0
  ammunition:
    magazine_size: 6
    reserve: 12
    reloadable: true
    reload_time: 1.2
  projectile:
    speed: 600
    hitbox:
      type: circle
      radius: 2
    trajectory: straight
  range: 600
```

Beispiel für einen Zauberstab mit geradem magischem Projektil:

```yaml
id: magic_wand
display_name: Magic Wand
description: Launches a straight magical projectile.
type: range
damage_type:
  - magic

stats:
  damage:
    magic: 28
  attack:
    mode: single
    cooldown: 0.8
    use_time: 0
  projectile:
    speed: 320
    hitbox:
      type: circle
      radius: 5
    trajectory: straight
  range: 640
```
#### Zukünftig

Ein wellenförmiges Projektil kann später dieselbe Struktur verwenden:

```yaml
projectile:
  speed: 320
  hitbox:
    type: circle
    radius: 5
  trajectory: wave
  amplitude: 18
  frequency: 3
```

Beispiel für eine Laserwaffe mit direktem Strahl:

```yaml
id: laser
display_name: Laser
description: Emits a direct magical ray.
type: range
damage_type:
  - magic

stats:
  damage:
    magic: 12
  attack:
    mode: ray
    cooldown: 0.2
    use_time: 1.0
  ray:
    hitbox:
      type: rectangle
      size: [700, 8]
    lifetime: 1.0
    tick_rate: 10
```

## Explosive Weapons

Explosivwaffen benötigen:

- `stats.range`
- `stats.delivery`
- `stats.explosion`

`stats.delivery` beschreibt den Wurfkörper, der die Explosion an ihren
Wirkungsort bringt. Er ist nicht der eigentliche Angriff, sondern nur der
Träger und Auslöser der Explosion. `stats.explosion` beschreibt die eigentliche
Angriffswirkung. Explosionen können entweder direkt Schaden verursachen oder
weitere Projektile erzeugen. Eine Explosion kann außerdem über
`affects_owner` festlegen, ob der Besitzer von ihrer Wirkung betroffen ist.
Der Wurfkörper besitzt keine eigene `lifetime`. Er bleibt bis zur Auslösung
des Timers, bis zu einem gültigen Aufprall oder bis er die Karte verlässt
aktiv.

Der Ablauf einer Explosivwaffe ist:

```text
Waffe einsetzen
    ↓
Wurfkörper erzeugen und bewegen
    ↓
Trigger prüfen (`timer` oder `impact`)
    ↓
Explosion erzeugen
    ↓
Schaden oder weitere Projektile anwenden
```

### Explosion Trigger

Die Auslösung wird über `stats.explosion.trigger` definiert:

| Trigger | Beschreibung | Zusätzliche Werte |
| --- | --- | --- |
| `timer` | Die Explosion wird nach einer festgelegten Zeit ausgelöst. | `timer` ist erforderlich und wird in Sekunden angegeben. |
| `impact` | Die Explosion wird beim gültigen Aufprall des Wurfkörpers ausgelöst. | Keine |

Bei `trigger: timer` ist `stats.explosion.timer` erforderlich. Der Wurfkörper
bleibt bis zum Ablauf dieses Timers aktiv. Bei `trigger: impact` wird der
Timer weggelassen; der Wurfkörper bleibt bis zum gültigen Aufprall aktiv. In
beiden Fällen endet der Wurfkörper außerdem, sobald er die Karte verlässt.

### Explosion Effects

Eine Explosion benötigt genau eine der folgenden Wirkungen:

- `damage`: Wendet den unter `stats.damage` definierten Schaden innerhalb der
  Explosions-Hitbox an.
- `projectiles`: Erzeugt beim Auslösen mehrere neue Projektile.

Die Explosions-Hitbox verwendet dieselbe Struktur wie andere Hitboxen. Für die
erste Version ist `circle` vorgesehen. Innerhalb der Hitbox verursacht eine
Explosion immer denselben Schaden; ein Schadensabfall zum Rand ist nicht
vorgesehen. Bei `effect: projectiles` werden die erzeugten Projektile mit
einer eigenen Projektildefinition beschrieben. `affects_owner` entscheidet,
ob der Besitzer von der Explosionswirkung betroffen ist.

Eine Explosion hat genau einen Wirkungsmodus:

- `instant`: Die Wirkung wird einmalig beim Auslösen angewendet. `lifetime`
  und `tick_rate` werden weggelassen.
- `tick`: Die Explosion bleibt für `lifetime` aktiv und wendet den Schaden
  regelmäßig mit `tick_rate` Treffern pro Sekunde an. Beide Werte sind
  erforderlich.

Der Modus wird über `stats.explosion.mode` definiert. Bei `effect: damage`
verwendet jeder Treffer den vollständigen Wert aus `stats.damage`. Bei
`effect: projectiles` gilt der definierte Schaden für jedes erzeugte
Projektil; diese Wirkung wird einmalig beim Auslösen angewendet und verwendet
daher `mode: instant`. Erzeugen acht Projektile jeweils `10` Schaden, können
sie zusammen bis zu `80` Schaden verursachen, wenn alle treffen. Der Modus
`tick` ist für `effect: damage` vorgesehen.

Bei einer Explosion mit `lifetime: 2.0` und `tick_rate: 4` wird die
Schadensprüfung viermal pro Sekunde und damit insgesamt ungefähr achtmal
ausgeführt. Der erste Tick erfolgt beim Beginn der Explosion; der letzte Tick
darf nicht über das Ende der `lifetime` hinausgehen. Die genaue Zeitposition
des letzten Ticks wird durch die Simulationsschritte bestimmt.

```yaml
id: grenade
display_name: Grenade
description: A thrown explosive weapon.
type: explosive
damage_type:
  - physical

stats:
  damage:
    physical: 60
  attack:
    mode: single
    cooldown: 1.0
    use_time: 0.2
  delivery:
    speed: 350
    hitbox:
      type: circle
      radius: 6
    trajectory: ballistic
  range: 450
  explosion:
    trigger: timer
    timer: 2.0
    mode: instant
    hitbox:
      type: circle
      radius: 100
    effect: damage
    affects_owner: true
```

Eine Explosion kann stattdessen mehrere Projektile erzeugen:

```yaml
explosion:
  trigger: impact
  hitbox:
    type: circle
    radius: 40
  effect: projectiles
  projectiles:
    count: 8
    spread: 360
    damage:
      physical: 10
    speed: 220
    lifetime: 1.5
    hitbox:
      type: circle
      radius: 3
  affects_owner: false
```

Beispiel für eine länger aktive Explosion mit Tick-Schaden:

```yaml
explosion:
  trigger: impact
  mode: tick
  lifetime: 2.0
  tick_rate: 4
  hitbox:
    type: circle
    radius: 80
  effect: damage
  affects_owner: false
```

## Complete Pistol Example

Das folgende Beispiel zeigt eine vollständige Waffen-Datei für eine Pistole.
Die Pistole verwendet einen geraden Einzelschuss, begrenzte Magazinmunition
und ein einzelnes physisches Projektil.

```yaml
id: pistol
display_name: Pistol
description: A reliable short-range weapon.

type: range
damage_type:
  - physical

stats:
  damage:
    physical: 20
  attack:
    mode: single
    cooldown: 0.33
    use_time: 0
  ammunition:
    magazine_size: 6
    reserve: 18
    reloadable: true
    reload_time: 1.2
  projectile:
    speed: 600
    lifetime: 1.0
    hitbox:
      type: circle
      radius: 2
    trajectory: straight
  range: 600

assets:
  world_sprite: sprites/items/weapons/pistol.png
  hand_sprite: sprites/items/weapons/pistol-hand.png
  projectile_sprite: sprites/items/weapons/pistol-projectile.png
  muzzle_effect: effects/weapons/pistol-muzzle.png
  audio:
    attack: sounds/weapons/pistol-attack.wav
    reload: sounds/weapons/pistol-reload.wav
```
