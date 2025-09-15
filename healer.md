# **Mythic+ Healer's Field Manual: Application Specification**

## **Part 1: Application Specification**

### **1.0 Application Overview: Mythic+ Healer's Field Manual**

#### **1.1 Vision Statement**

To be the definitive, at-a-glance digital resource for Mythic+ healers, empowering them with the critical knowledge needed to anticipate damage, manage resources effectively, and master boss encounters in *World of Warcraft*.

#### **1.2 Core Purpose**

The application will translate complex, multi-role dungeon guides into a structured, healer-centric format. It will focus exclusively on actionable intelligence for the healer role: what to heal, what to dispel, when to use cooldowns, and how to position for success. The content will cover the complete dungeon rotation for *The War Within* Season 3\.1

#### **1.3 Value Proposition**

By filtering out non-essential information, such as detailed damage-dealer rotations or nuanced tank-positioning strategies, the application saves the user critical time and reduces cognitive load during high-pressure gameplay. It provides not just *what* happens, but *why* it matters specifically to the healer, enabling a shift from reactive to proactive healing.

### **2.0 System Architecture and Core Functionality**

#### **2.1 High-Level Architecture**

The system will be a client-side application, developed using a cross-platform framework (e.g., React Native for mobile, Electron for desktop). Content will be fetched from or bundled with a static JSON database. This architecture prioritizes rapid load times and reliable offline access, acknowledging that players may have unstable internet connections during gameplay sessions.

#### **2.2 Core Features**

* **Dungeon Selection:** The main screen will present a clear, visually organized grid or list of the eight dungeons on rotation for the current season.3  
* **Boss Selection:** Upon selecting a dungeon, the user will be presented with a list of its bosses, arranged in the chronological order they are encountered within the instance.  
* **Healer Intelligence Display:** This is the core view of the application. This screen presents all healer-relevant data for a selected boss, structured for maximum clarity and rapid comprehension.

#### **2.3 Content Data Model (Database Schema)**

The AI agent will construct a database, likely a structured JSON file, based on the following schema. This model will serve as the foundational structure for all content detailed in Part 3 of this document.

JSON

{  
  "season": "The War Within Season 3",  
  "dungeons":  
        }  
      \]  
    }  
  \]  
}

### **3.0 User Interface (UI) and User Experience (UX) Blueprint**

#### **3.1 Navigation Flow**

The application's navigation will be simple and intuitive, following a clear hierarchical path:

1. **Home Screen (Dungeon List):** Displays all available dungeons.  
2. **Dungeon Screen (Boss List):** Accessed by tapping a dungeon on the Home Screen. Displays the bosses for that dungeon.  
3. **Boss Encounter Screen (Healer Intelligence Display):** Accessed by tapping a boss on the Dungeon Screen. Displays detailed healer information.

A persistent navigation bar or breadcrumb trail (e.g., Home \> Ara-Kara \> Avanoxx) will be present on all screens beyond the Home Screen to allow for easy and immediate return to previous levels.

#### **3.2 Encounter View Wireframe Concept**

The Boss Encounter Screen is the application's primary information delivery tool. Its design must prioritize clarity and speed of information acquisition.

* **Header:** The screen will be clearly titled with the Boss Name.  
* **Healer Summary:** Directly below the title, a concise "Healer Summary" provides a 1-2 sentence overview of the fight's core healing challenges and overall rhythm.  
* **Ability Cards:** The main content area will consist of a vertically scrolling list of "Ability Cards." Each card represents a single, significant boss ability. These cards will be structured according to the "Boss Ability Quick Reference" table format.  
* **Visual Prioritization:** Cards will be visually distinct based on the Damage Profile field. For instance, a "Critical" profile ability card could have a prominent red border, "High" a yellow border, and "Mechanic" a blue border. This allows the user to visually scan and prioritize the most immediate threats.

#### **3.3 Key Table: Boss Ability Quick Reference**

This table format is the fundamental building block of each "Ability Card" in the UI. Its structure is designed for rapid information absorption and is the designated format for all boss abilities detailed in Part 3 of this specification. The design directly maps a healer's in-combat thought process to the UI's data structure. The questions a healer must answer in seconds—"What's coming?", "Who gets hit?", "How hard?", "What's my job?", and "What's the trick?"—are answered by each column, minimizing cognitive load and maximizing decision-making speed.

| Ability Name & Type | Target(s) | Damage Profile | Healer's Primary Action | Critical Insight |
| :---- | :---- | :---- | :---- | :---- |

## **Part 2: User Stories for Implementation**

### **4.0 Agile Implementation Framework: Epics & Stories**

#### **4.1 Epic: Core Application Framework & Navigation**

* **Story 1:** As a user, I want to see a list of all current season dungeons on the main screen so that I can quickly select the one I am in.  
* **Story 2:** As a user, when I tap on a dungeon, I want to see a list of all its bosses in order so that I can select the one I am about to fight.  
* **Story 3:** As a user, I want a persistent back button or navigation trail so that I can easily move between the boss, dungeon, and home screens.

#### **4.2 Epic: Healer-Specific Encounter Data Presentation**

* **Story 4:** As a user, when I select a boss, I want to see a brief summary of the primary healing challenges for the entire fight so I can get a quick overview.  
* **Story 5:** As a user, on the boss screen, I want to see a separate, clearly defined card for each major boss ability so that I can mentally organize the fight's mechanics.  
* **Story 6:** As a user, I want each ability card to display the ability's target, damage profile, my required action, and a critical insight, so I have all necessary information in one place.  
* **Story 7:** As a user, I want ability cards to be color-coded based on their severity (e.g., red for deadly tank busters or group-wipes) so I can visually prioritize the most dangerous mechanics.

#### **4.3 Epic: Content & Usability**

* **Story 8:** As a developer, I need to implement the full content database for all 8 dungeons as specified in Part 3 of this specification.  
* **Story 9:** As a user, I want a simple search bar on the home screen to quickly find a specific dungeon or boss by name.

## **Part 3: Healer Encounter Compendium**

### **5.0 Dungeon: Ara-Kara, City of Echoes**

#### **5.1 Boss Encounter: Avanoxx**

* **Healer Summary:** A fight defined by predictable, high-damage phases requiring proactive cooldown usage. The primary challenge is managing sustained group healing for Gossamer Onslaught and Alerting Shrill while monitoring the tank's survivability against Voracious Bite.

| Ability Name & Type | Target(s) | Damage Profile | Healer's Primary Action | Critical Insight |
| :---- | :---- | :---- | :---- | :---- |
| **Alerting Shrill***Group Damage* | Group | **Critical** \- High, unavoidable Physical damage over 3 seconds. | Use a pre-planned group healing cooldown. | This is a pure healing throughput check. Ensure the group is near full health before the cast begins to prevent deaths.4 |
| **Gossamer Onslaught***Group Damage & Area Denial* | Group | **High** \- Sustained group damage over 5 seconds. | Maintain group-wide healing-over-time effects and use spot heals. | Players will be dropping web puddles. Advise them to stack these puddles to conserve space, but be prepared for the constant damage during the channel.4 |
| **Voracious Bite***Tank Buster* | Tank | **High** \- Three rapid Physical hits applying a 50% damage taken increase debuff. | Use an external defensive cooldown on the tank or be ready with large, direct heals. | The tank is extremely vulnerable during this 10-second debuff, especially if it overlaps with group damage. This is a priority for external mitigation.4 |
| **Insatiable***Boss Buff* | Boss | **Mechanic** \- Boss gains a stacking 50% damage increase. | None directly. Be prepared for all incoming damage to be significantly higher. | This occurs if Starved Crawler adds reach the boss. While not a direct healing mechanic, a single stack makes all other abilities far more lethal, requiring more aggressive cooldown usage.4 |

#### **5.2 Boss Encounter: Anub'zekt**

* **Healer Summary:** This encounter tests DoT management and spatial awareness. The healer's focus must be on players with the Infestation debuff, as they are the source of the next mechanical threat. Success hinges on controlling the placement of Ceaseless Swarm pools.

| Ability Name & Type | Target(s) | Damage Profile | Healer's Primary Action | Critical Insight |
| :---- | :---- | :---- | :---- | :---- |
| **Infestation***Poison DoT* | Random Players | **High** \- Heavy single-target Poison damage over time. | Focus healing on the debuffed targets. Dispel if possible, but prioritize healing. | On expiration, this DoT spawns a Ceaseless Swarm. The debuffed player must move away from the group to a safe drop-off location before expiration to prevent group-wide damage.4 |
| **Burrow Charge***Targeted AoE* | Random Ranged Player | **High** \- Large area-of-effect Physical damage at the target's location. | Be ready with spot heals for the targeted player and anyone caught in the 13-yard AoE. | The attack prioritizes ranged players. The group can designate one ranged player to bait all charges away from the group, simplifying positioning and healing.4 |
| **Eye of the Swarm***Area Denial & Group Damage* | Group | **Critical** \- Arena-wide lethal damage, with a small safe zone in front of the boss. | Keep the group topped off while inside the safe zone. | Infestation continues to be cast during this phase. Players must drop the resulting Ceaseless Swarm pools at the very edge of the safe circle to avoid cluttering the limited space.4 |
| **Silken Restraints***Crowd Control (Add)* | Random Player | **Mechanic** \- A channeled root from Bloodstained Webmage adds. | Assist with interrupts if able. Be aware of rooted players' health. | A rooted player cannot dodge other mechanics like Burrow Charge. This makes them a high-priority healing target until freed.4 |

#### **5.3 Boss Encounter: Ki'katal the Harvester**

* **Healer Summary:** A mechanically intensive fight where the healer acts as a risk manager. The timing and communication around dispelling Cultivated Poison are more critical than raw healing output. The fight culminates in a positioning and survival test during Cosmic Singularity.

| Ability Name & Type | Target(s) | Damage Profile | Healer's Primary Action | Critical Insight |
| :---- | :---- | :---- | :---- | :---- |
| **Cosmic Singularity***Group Pull & Damage* | Group | **Critical** \- Strong pull towards the boss, followed by a lethal 10-yard AoE. | None directly. Players must handle the mechanic themselves. | Players must stand in a Black Blood puddle to root themselves against the pull.5 Be prepared for high damage on anyone who fails the mechanic. After the cast, be ready to dispel roots or use Freedom effects on players rooted by the resulting slimes.6 |
| **Cultivated Poison***Poison DoT & Area Denial* | 3 Random Players | **High** \- Moderate Poison DoT that triggers a secondary effect. | Dispel the debuff, but only after coordinating with the target. | When dispelled or expired, the target takes a burst of damage and fires two Poison Waves. The target MUST be facing away from the group before the dispel occurs to prevent lethal friendly fire.4 Do not dispel reactively. |
| **Erupting Webs***Area Denial* | All Players | **Mechanic** \- Spawns numerous swirlies on the ground. | None directly. Focus on healing players who fail to dodge. | This mechanic primarily serves to restrict movement, making the positioning for Cultivated Poison and Cosmic Singularity more challenging.5 |
| **Black Blood***Mechanic (Add)* | Environment | **Mechanic** \- Puddles dropped by Blood Worker adds. | None directly. | These puddles are essential for surviving Cosmic Singularity. Ensure DPS are tagging the adds to create enough puddles for the group before the boss reaches 100 energy.5 |

### **6.0 Dungeon: The Dawnbreaker**

#### **6.1 Boss Encounter: Speaker Shadowcrown**

* **Healer Summary:** The central challenge is the "Dispel Punishment" of Burning Shadows. The act of dispelling this debuff directly causes the next major healing event, Shadow Shroud. This requires a two-step approach: prepare for group-wide healing, then dispel and immediately counter the resulting absorb shields.

| Ability Name & Type | Target(s) | Damage Profile | Healer's Primary Action | Critical Insight |
| :---- | :---- | :---- | :---- | :---- |
| **Burning Shadows***Magic DoT & Dispel Mechanic* | Random Player | **High** \- Heavy single-target Shadow DoT and a permanent 50% slow. | Dispel the Magic debuff. | **Crucial:** Dispelling this applies Shadow Shroud (a healing absorb) to 4 players. Do not dispel until you are ready to immediately follow up with strong AoE healing to break the absorbs.7 |
| **Obsidian Beam***Tank & Group Damage* | Tank & Group | **High** \- A large hit on the tank, a simultaneous hit on the group, followed by rotating beams. | Use a group healing cooldown or be prepared for heavy AoE healing. | The initial blast requires immediate group-wide healing. Players must then navigate the rotating beams, which are lethal on contact. The number of beams increases after the Darkness Comes phase.8 |
| **Collapsing Night***Area Denial* | Random Ranged Players | **Mechanic** \- Spawns void zones that grow over time. | None directly. As a ranged player, be prepared to be targeted. | This ability prioritizes ranged players and healers. Bait these zones away from the center of the room to ensure there is ample space to maneuver during Obsidian Beam.7 |
| **Darkness Comes***Phase Transition* | Group | **Mechanic** \- Creates a lethal bubble that expands from the boss. | None. | Players must mount up and fly away from the ship to survive. Ensure the group understands this mechanic to avoid unnecessary deaths.8 |

#### **6.2 Boss Encounter: Anub'ikkaj**

* **Healer Summary:** A test of sustained AoE healing and group coordination. The ramping damage of Shadowy Decay is the primary threat, and the group's ability to stack for efficient healing is paramount to survival.

| Ability Name & Type | Target(s) | Damage Profile | Healer's Primary Action | Critical Insight |
| :---- | :---- | :---- | :---- | :---- |
| **Shadowy Decay***Group Damage* | Group | **Critical** \- Stacking, ramping Shadow damage to all players over 5 seconds. | Use a major healing cooldown and sustained AoE healing. | This is the fight's main healing check. The damage increases with each tick. The group should stack together to maximize the effectiveness of AoE healing abilities.7 |
| **Dark Orb***Group Damage* | Group | **High** \- An orb travels across the room and explodes, dealing group-wide damage. | Be prepared for a large burst of AoE damage. | The damage is lower the further the orb travels. The group should position to allow the orb maximum travel time. Players hit by the explosion also get a DoT, Dark Scars, requiring follow-up healing.7 |
| **Terrifying Slam***Tank Buster & CC* | Tank | **High** \- Heavy Physical and Shadow damage with a knockback and fear effect on nearby players. | Focus heal the tank after the hit. Dispel fear if possible. | Position yourself away from the tank to avoid the 15-yard fear effect, ensuring you can continue healing uninterrupted.7 |

#### **6.3 Boss Encounter: Rasha'nan**

* **Healer Summary:** A high-movement encounter that demands significant healing throughput, particularly during Erosive Spray. The healer must manage their own positioning to dodge Rolling Acid while preparing for the intense, stacking group-wide damage.

| Ability Name & Type | Target(s) | Damage Profile | Healer's Primary Action | Critical Insight |
| :---- | :---- | :---- | :---- | :---- |
| **Erosive Spray***Group Damage* | Group | **Critical** \- High initial Nature damage followed by a stacking DoT, Lingering Erosion, on all players. | Use major healing cooldowns and sustained AoE healing. | This is the most dangerous ability. The group should stack tightly together (after dodging other mechanics) to allow for efficient AoE healing to counter the stacking DoT.7 |
| **Spinneret's Strands***Targeted Damage & CC* | 2 Random Players | **High** \- Ticking Shadow damage and a tether that pulls the player. | Spot-heal the targeted players. | To break the tether, the player must run 10 yards away from the web puddle. This also triggers a small burst of group damage. Advise targets to use a personal defensive.7 |
| **Rolling Acid***Area Denial* | Targeted Players | **Mechanic** \- Waves of acid travel across the platform. | Be ready to heal players who fail to dodge and gain the Corrosion DoT. | The waves can be used to shrink the web puddles from Spinneret's Strands, clearing space. However, the primary goal is to avoid being hit.7 |
| **Acidic Eruption***Group Damage (Intermission)* | Group | **High** \- Ramping Nature damage to all players until interrupted. | Use strong, sustained AoE healing. | This occurs after the flight phase. The damage increases over time, so the interrupt must happen quickly. Save a minor cooldown for this if the interrupt is delayed.7 |

### **7.0 Dungeon: Eco-Dome Al'dani**

#### **7.1 Boss Encounter: Azhiccar**

* **Healer Summary:** An attrition-based fight focused on managing a dangerous DoT (Toxic Regurgitation) and surviving periods of sustained, unavoidable group damage. Resource management is key to enduring the Devour phase.

| Ability Name & Type | Target(s) | Damage Profile | Healer's Primary Action | Critical Insight |
| :---- | :---- | :---- | :---- | :---- |
| **Toxic Regurgitation***Shadow DoT & Area Denial* | Random Players | **High** \- Heavy single-target Shadow DoT that leaves damaging pools. | Use strong single-target healing on the debuffed player. | Advise the targeted player to use a defensive cooldown and drop the resulting pools near the edge of the arena to preserve space for the Devour phase.10 |
| **Devour***Group Damage & Add Mechanic* | Group | **High** \- Sustained, unavoidable Shadow damage to all players. | Use efficient, sustained AoE healing. | During this phase, players must kill adds before the boss consumes them. The longer the phase lasts, the more healing is required. This is a mana-conservation challenge.11 |
| **Invading Shriek***Group Damage* | Group | **Moderate** \- A burst of Physical damage to all players. | Use AoE heals to top off the group. | This ability summons adds and serves as a predictable pulse of group damage. Be prepared for it, but save major cooldowns for Devour.11 |

#### **7.2 Boss Encounter: Taah'bat and A'wazj**

* **Healer Summary:** A two-target cleave fight where the main healing pressure comes from the Binding Javelin DoT. The healer must manage a dangerous tank Bleed while spot-healing the tethered players.

| Ability Name & Type | Target(s) | Damage Profile | Healer's Primary Action | Critical Insight |
| :---- | :---- | :---- | :---- | :---- |
| **Binding Javelin***Targeted Damage & CC* | 2 Random Players | **High** \- Ticking Arcane damage and a slow, tethering players to a spear. | Focus healing on the two tethered players. | The damage persists until the spear is destroyed. Players should overlap the initial placement circles to allow for efficient cleave damage on the boss and the spears, shortening the duration of this high-damage mechanic.10 |
| **Rift Claws***Tank Buster (Bleed)* | Tank | **High** \- An initial Arcane hit followed by a heavy Physical Bleed DoT. | Dispel the Bleed if possible (e.g., Paladin, Evoker). Otherwise, provide focused healing on the tank. | This is a significant source of tank damage. Coordinate with the tank on their defensive cooldown usage.11 |
| **Warp Strike***Area Denial* | Players in a line | **Moderate** \- Arcane damage to anyone in the path of the charge. | Heal players who fail to dodge the line attack. | During the Arcane Blitz phase, multiple Warp Strikes will occur. Advise players to aim the strikes through the boss while avoiding others' lines.11 |

#### **7.3 Boss Encounter: Soul-Scribe**

* **Healer Summary:** A fight characterized by constant, low-grade ticking damage from Echoes of Fate, punctuated by high-damage events. The healer's primary role is to manage the Wounded Fate debuff and provide burst healing during key moments like Whispers of Fate.

| Ability Name & Type | Target(s) | Damage Profile | Healer's Primary Action | Critical Insight |
| :---- | :---- | :---- | :---- | :---- |
| **Echoes of Fate***Group Damage* | Group | **Low** \- Constant, unavoidable ticking Arcane damage throughout the entire encounter. | Maintain group-wide healing-over-time effects. | This is an attrition mechanic designed to drain mana. Use your most efficient spells to counteract it. The real danger is when this overlaps with other damage sources.11 |
| **Whispers of Fate***Group Damage & Mechanic* | Group | **High** \- A burst of Arcane damage to all players, which also spawns personal echoes. | Use an AoE heal to counter the initial burst. | Players must collect their echo to gain a damage/healing buff. Failure results in the Wounded Fate debuff, which is a high-priority healing target.10 |
| **Wounded Fate***Debuff* | Player who fails mechanics | **High** \- Ticking Arcane damage and a Haste reduction. | Provide strong, focused healing to the debuffed player. | This debuff is the primary punishment for failing mechanics (e.g., not collecting an echo, getting hit by Eternal Weave). A player with this debuff is at high risk of death.10 |
| **Dread of the Unknown***Targeted AoE* | Marked Players | **Moderate** \- An explosion around marked players after a delay. | Heal players caught in the 9-yard AoE. | This ability often follows Whispers of Fate, forcing players to choose between collecting their echo and spreading out. Be prepared for the damage spike.12 |

### **8.0 Dungeon: Halls of Atonement**

#### **8.1 Boss Encounter: Halkias, the Sin-Stained Goliath**

* **Healer Summary:** A fight about spatial awareness and managing group health through predictable pulses of damage. The key is to keep the group healthy during Crumbling Slam while ensuring everyone can navigate the Refracted Sinlight beams without standing in Glass Shards.

| Ability Name & Type | Target(s) | Damage Profile | Healer's Primary Action | Critical Insight |
| :---- | :---- | :---- | :---- | :---- |
| **Crumbling Slam***Tank & Group Damage* | Tank & Group | **High** \- A hit on the tank that also deals sonic damage to the entire group. | Use an AoE heal to recover from the group-wide damage. | This ability also creates Glass Shard puddles. The tank can stack these to conserve space, but the group damage component is unavoidable and requires consistent healing.13 |
| **Refracted Sinlight***Area Denial* | Group | **Critical** \- Four rotating beams that are lethal on contact. | None directly. Focus on healing players who may be clipped by the beams. | This is cast at 100 energy. The beams can randomly change direction. The main challenge is having enough clean space to move, which is why puddle placement from Crumbling Slam and Heave Debris is important.14 |
| **Sinlight Visions***Fear (Magic)* | Players outside the circle | **Mechanic** \- A fear effect for players who leave the boss's inner circle. | Dispel the Magic debuff if a player is feared. | This mechanic forces the group to stay relatively close, making dodging Refracted Sinlight more difficult. A quick dispel can save a player.14 |

#### **8.2 Boss Encounter: Echelon**

* **Healer Summary:** This fight requires pre-emptive healing and defensive usage due to the stun component of Stone Shattering Leap. Managing the health of Undying Stonefiends is a group responsibility, but missed interrupts will result in significant random damage.

| Ability Name & Type | Target(s) | Damage Profile | Healer's Primary Action | Critical Insight |
| :---- | :---- | :---- | :---- | :---- |
| **Stone Shattering Leap***Targeted Damage & CC* | Random Player | **High** \- Heavy damage to a targeted player, followed by a stun. | Pre-emptively apply a heal-over-time or damage reduction effect to the target. | The target is stunned at the end of the cast, making them unable to use a defensive at the moment of impact. They must use it beforehand. Be ready to heal them immediately after the hit.13 |
| **Curse of Stone***Group Damage* | Group | **High** \- Heavy Nature damage to all players when an Undying Stonefiend is "killed." | Use AoE healing to recover from the group-wide damage. | This damage is unavoidable. If multiple Stonefiends are brought to 0 health at the same time, the overlapping damage can be lethal. Use a group defensive if this occurs.13 |
| **Villainous Bolt***Single-Target Damage (Add)* | Random Player | **Moderate** \- A standard shadow damage cast from Undying Stonefiends. | Heal the targeted player. | This is interruptible. While DPS should handle interrupts, be prepared for spikes of damage on random players if kicks are missed.13 |

#### **8.3 Boss Encounter: High Adjudicator Aleez**

* **Healer Summary:** A control-oriented fight where healing intensity is directly tied to how quickly the group manages the ghost mechanic. The primary healer responsibility is dispelling Unstable Anima to prevent cascading group damage.

| Ability Name & Type | Target(s) | Damage Profile | Healer's Primary Action | Critical Insight |
| :---- | :---- | :---- | :---- | :---- |
| **Unstable Anima***Magic DoT & AoE* | Random Players | **High** \- A Magic debuff that pulses shadow damage to nearby allies. | Dispel the Magic debuff immediately. | This is the most critical healer task. A missed dispel will cause significant, unnecessary group damage, especially since players need to be near the Vessel of Atonement to handle ghosts.13 |
| **Volatile Anima***Group Damage* | Group | **High** \- Ramping shadow damage to the group for each active Tormented Soul (ghost). | Use sustained AoE healing. | The longer ghosts are alive, the higher the group-wide damage becomes. This mechanic punishes slow execution with a heavy healing requirement.13 |
| **Anima Fountain***Area Denial* | Area | **Moderate** \- Anima impacts the ground, dealing damage to players within 5 yards. | Heal players who fail to dodge the impacts. | This forces movement and can complicate the process of kiting ghosts into the Vessels, potentially extending the duration of the high-damage Volatile Anima phase.13 |

#### **8.4 Boss Encounter: Lord Chamberlain**

* **Healer Summary:** A demanding encounter that tests triage healing. The healer must balance a severe, ramping tank DoT (Stigma of Pride) against the high, sustained damage on players soaking beams during Ritual of Woe. Cooldown management and external defensives are critical.

| Ability Name & Type | Target(s) | Damage Profile | Healer's Primary Action | Critical Insight |
| :---- | :---- | :---- | :---- | :---- |
| **Ritual of Woe***Group Soak* | 4 Players | **Critical** \- Extremely high, sustained damage on players intercepting beams. | Use major healing cooldowns and focus healing on the four soakers. | Each player must block a beam to prevent a group wipe. The damage is intense. Players should use personal defensives. The tank can and should intercept two beams simultaneously by standing between two statues, reducing the number of soakers required.15 |
| **Stigma of Pride***Tank Buster (DoT)* | Tank | **Critical** \- A Shadow DoT where each tick deals 30% more damage than the last. | Provide strong, focused healing and external defensive cooldowns to the tank. | This is one of the most dangerous tank DoTs. It requires constant attention and coordination with the tank's own mitigation.13 |
| **Erupting Torment***Area Denial* | Group | **High** \- Large shadow damage circles erupt around the boss and all statues. | None directly. Heal anyone who fails to move out. | This forces the group to move, which can be dangerous during the Ritual of Woe phase if not timed correctly.16 |
| **Unleashed Suffering***Frontal Cone* | Tank's Direction | **High** \- A frontal cone aimed at the tank. | None directly. | This is a simple mechanic to dodge, but a non-tank player hit by it will likely die. Be aware of the tank's positioning.16 |

### **9.0 Dungeon: Operation: Floodgate**

#### **9.1 Boss Encounter: Swampface**

* **Healer Summary:** A unique fight focused on partner management and surviving a heavy DoT. The Razorchoke Vines mechanic forces paired players to coordinate all movement, and the healer must be prepared to provide significant single-target healing to those affected.

| Ability Name & Type | Target(s) | Damage Profile | Healer's Primary Action | Critical Insight |
| :---- | :---- | :---- | :---- | :---- |
| **Razorchoke Vines***DoT & Paired Mechanic* | 4 Players | **High** \- A 24-second DoT that binds two players together. | Provide sustained single-target healing to the four debuffed players. | If paired players move more than 14 yards apart, they are pulled together. This requires constant communication, especially when dodging other mechanics. The ability prefers to target non-healers.18 |
| **Wallop***Targeted Damage & CC* | Random Player | **High** \- A large physical hit that knocks the target into the air. | Heal the target after they land. | The targeted player cannot move or dodge while in the air. They should use a defensive before the hit.18 |

#### **9.2 Boss Encounter: OAF-MOD 2**

* **Healer Summary:** This encounter is about managing multiple sources of incoming damage simultaneously. The healer needs to be aware of the tank's position for Tidal Surge, heal through the group-wide Depth Charge, and assist with interrupts on the adds.

| Ability Name & Type | Target(s) | Damage Profile | Healer's Primary Action | Critical Insight |
| :---- | :---- | :---- | :---- | :---- |
| **Tidal Surge***Area Denial* | Player in a line | **Critical** \- A massive wave that deals lethal damage. | None directly. Heal anyone clipped by the wave. | The targeted player must kite this wave away from the group, likely requiring a movement speed ability to outrun it and create distance.18 |
| **Depth Charge***Group Damage* | Group | **High** \- A large burst of unavoidable group-wide damage. | Use an AoE healing cooldown. | This is a straightforward healing check. Ensure the group is healthy before the cast completes. |
| **Maximum Distortion***Group Damage (Add)* | Group | **High** \- An interruptible cast from Mechadrone adds that deals heavy group damage. | Assist with interrupts if possible. | This cast is the highest priority for interrupts. A successful cast will put immense pressure on the healer.18 |
| **Doom Storm***Targeted AoE (Add)* | Random Player | **High** \- A damaging circle placed on a random player by Mechadrone adds. | Heal players who are slow to move out of the effect. | This cast happens twice back-to-back, often targeting a different player the second time. Players must remain vigilant after the first circle appears.18 |

#### **9.3 Boss Encounter: G-T.O. (Giga-Turbine Operator)**

* **Healer Summary:** A high-intensity fight that alternates between heavy group-wide rot damage during Turbo Charge and intense single-target healing for Gigazap. Cooldowns must be carefully planned to handle the overlapping pressure.

| Ability Name & Type | Target(s) | Damage Profile | Healer's Primary Action | Critical Insight |
| :---- | :---- | :---- | :---- | :---- |
| **Turbo Charge***Group Damage* | Group | **Critical** \- Heavy, ticking damage to the group and shoots out lines at random players. | Use a major healing cooldown and sustained AoE healing. | This is the fight's primary burn phase. The damage is very high and requires a dedicated healing plan. Players must also dodge the random lines of damage.18 |
| **Gigazap***Magic DoT* | 2 Random Players | **High** \- A heavy Magic DoT that deals significant damage over 6 seconds. | Provide strong, focused single-target healing to both debuffed players. | The debuffed players are at high risk of death. It is recommended to use a minor cooldown for the second set of zaps in each cycle, as this often overlaps with the lead-up to the next Turbo Charge.19 |
| **Leaping Sparks***Mechanic* | All Players | **Mechanic** \- Sparks fixate on each player and stun on contact. | None directly. | Players must kite their spark into a Dam Water puddle to dissipate it. A player with Gigazap must not kite their spark near a puddle, as it will electrify it and make it unusable.18 |
| **Thunder Punch***Tank Buster* | Tank | **Critical** \- A massive initial hit, a knockback, and a heavy DoT. | Use an external defensive and be ready with strong, direct heals. | This is an extremely dangerous tank buster. The DoT component requires sustained healing attention even after the initial hit.20 |

### **10.0 Dungeon: Priory of the Sacred Flame**

#### **10.1 Boss Encounter: Captain Dailcry**

* **Healer Summary:** A council-style fight where the healer must manage multiple damage sources from three different mini-bosses. The primary challenges are the group-wide Holy Radiance, the tank bleed Pierce Armor, and spot-healing for Savage Mauling.

| Ability Name & Type | Target(s) | Damage Profile | Healer's Primary Action | Critical Insight |
| :---- | :---- | :---- | :---- | :---- |
| **Holy Radiance***Group Damage* | Group | **High** \- Channeled group-wide Holy damage from Elaena Emberlanz. | Use sustained AoE healing throughout the channel. | This is a predictable period of high group damage. Ensure the group is healthy before it begins.21 |
| **Pierce Armor***Tank Buster (Bleed)* | Tank | **High** \- A stacking Bleed effect applied to the tank. | Dispel the Bleed if possible. Otherwise, provide focused tank healing. | The stacks can become dangerous quickly. Coordinate with the tank on mitigation and kiting if necessary.22 |
| **Savage Mauling***Single-Target Damage (Bleed)* | Random Player | **Moderate** \- A hit and a Bleed effect on a random player. | Spot-heal the affected player. | The Bleed from War Lynx adds requires the target to be healed to full health to be removed.21 |
| **Divine Judgment***Tank Buster (Magic)* | Tank | **Moderate** \- A Magic debuff that deals damage. | Dispel the Magic debuff from the tank. | A quick dispel mitigates a significant amount of tank damage, allowing you to focus on other sources.21 |

#### **10.2 Boss Encounter: Baron Braunpyke**

* **Healer Summary:** A single-target fight with constant, unavoidable group-wide damage from Radiant Flame. The healer's main job is to maintain high throughput while being prepared for the heavy tank damage from Blazing Strike.

| Ability Name & Type | Target(s) | Damage Profile | Healer's Primary Action | Critical Insight |
| :---- | :---- | :---- | :---- | :---- |
| **Radiant Flame***Group Damage* | Group | **Moderate** \- Constant, unavoidable ticking Holy damage to all players. | Maintain efficient, group-wide healing-over-time effects. | This is a mana-intensive attrition mechanic. It makes every other source of damage more dangerous as players will rarely be at full health.21 |
| **Blazing Strike***Tank Buster (DoT)* | Tank | **High** \- A heavy initial hit that leaves a dangerous Holy DoT. | Use an external defensive and provide focused healing. | The tank must use a defensive for every cast of this ability. The DoT requires sustained attention.21 |
| **Sacrificial Flame***Group Soak* | Group | **High** \- Group-wide damage based on the number of Sacrificial Pyre stacks on the boss. | Use AoE healing to recover from the burst. | Players can soak pyres to reduce the number of stacks, but this also deals damage. Be aware of the stack count to anticipate the burst.22 |

#### **10.3 Boss Encounter: Prioress Murrpray**

* **Healer Summary:** A two-phase fight where the most critical moment is the intermission at 50% health. The healer must use major cooldowns to survive the ramping damage of Embrace the Light while the group breaks the boss's shield. Overlaps of Inner Fire and Blinding Light are the deadliest moments.

| Ability Name & Type | Target(s) | Damage Profile | Healer's Primary Action | Critical Insight |
| :---- | :---- | :---- | :---- | :---- |
| **Embrace the Light***Group Damage (Intermission)* | Group | **Critical** \- High, ramping group-wide Holy damage while the boss has an absorb shield. | Use major healing cooldowns and defensives. | This is the most dangerous part of the fight. The group must break the shield and interrupt the cast as quickly as possible. The damage becomes unsurvivable after a short time.21 |
| **Inner Fire***Group Damage* | Group | **High** \- The boss buffs herself, pulsing AoE Holy damage for 12 seconds. | Use a healing cooldown and sustained AoE healing. | This is a predictable window of high damage. Be prepared for it every time the boss gains the buff.21 |
| **Blinding Light***Group Damage & CC* | Group | **High** \- A burst of Holy damage and a disorient to anyone facing the boss. | Use an AoE heal to recover. Ensure you turn your character away. | If this overlaps with Inner Fire, the combined damage is extremely dangerous. A group defensive cooldown is highly recommended for this overlap.21 |
| **Purify***Area Denial* | Random Player | **High** \- A beam fixates on a player, dealing heavy damage and leaving fire on the ground. | Spot-heal the targeted player if they are taking damage. | The targeted player must kite this beam to the edge of the platform to conserve space. The damage is high, so they should use a personal defensive.21 |

### **11.0 Dungeon: Tazavesh: Streets of Wonder**

#### **11.1 Boss Encounter: Zo'phex the Sentinel**

* **Healer Summary:** A fight focused on managing a critical debuff and surviving a high-pressure fixate mechanic. The healer's main job is to keep the Interrogation target alive while the group frees them.

| Ability Name & Type | Target(s) | Damage Profile | Healer's Primary Action | Critical Insight |
| :---- | :---- | :---- | :---- | :---- |
| **Interrogation***Fixate & Damage* | Random Player | **High** \- The target is trapped in a cell and takes continuous damage while the boss advances. | Pour strong, continuous healing into the trapped player. | The trapped player should run as far away as possible to buy time. The rest of the group must break the cell before the boss reaches the player. The boss's frontal cleave during this is lethal.24 |
| **Impound Contraband***Silence & Mechanic* | Random Player | **Mechanic** \- The player is disarmed and silenced. | None directly. | The player must run to their weapon on the ground to remove the effect. As a healer, if you are targeted, you cannot cast spells until you retrieve your weapon.24 |
| **Charged Slash***Frontal Cone* | Tank's Direction | **High** \- A large frontal cone attack. | Heal anyone who fails to dodge. | The group should stay relatively close to the boss (but not in front) to make dodging this easier.24 |

#### **11.2 Boss Encounter: The Grand Menagerie (Alcruux & Venza)**

* **Healer Summary:** A two-boss encounter where the primary healing challenge is managing the Purification Protocol DoT and its subsequent explosion. Positioning and awareness are key to avoiding overlapping mechanics.

| Ability Name & Type | Target(s) | Damage Profile | Healer's Primary Action | Critical Insight |
| :---- | :---- | :---- | :---- | :---- |
| **Purification Protocol***Magic DoT & AoE* | 2 Random Players | **High** \- A Magic DoT that creates a damaging circle on expiration or dispel. | Dispel one debuff, wait for the explosion, then dispel the second. | Do not dispel both debuffs at the same time, as the overlapping damage can be lethal. The targeted players must move away from the group before the effect ends.26 |
| **Grand Consumption***Area Denial* | Group | **Mechanic** \- A two-wave sequence of AoE circles covering the room. | Heal anyone who fails the mechanic. | Players must stand in the safe spots of the second wave, wait for the first wave to explode, then move into the now-safe spots from the first wave. It is a simple but punishing mechanic.24 |
| **Chains of Damnation***Root & DoT* | Random Player | **High** \- Roots a player and applies a DoT. | Provide focused healing to the rooted player. | DPS must quickly destroy the chains to free the player, who is vulnerable to other mechanics while rooted.24 |

#### **11.3 Boss Encounter: So'azmi**

* **Healer Summary:** A mechanically complex fight where personal survival and execution of the Shuri teleport mechanic are paramount. Healing requirements are secondary to correctly navigating the arena and contributing to the Double Technique interrupt.

| Ability Name & Type | Target(s) | Damage Profile | Healer's Primary Action | Critical Insight |
| :---- | :---- | :---- | :---- | :---- |
| **Shuri***Area Denial* | Group | **Critical** \- An expanding ring of energy that is lethal on contact. | None directly. You must execute the mechanic correctly. | All players must use the matching teleporter relics to move to a safe quadrant of the room. Misjudging the teleporter will result in certain death.24 |
| **Double Technique***Group Damage (Interrupt)* | Group | **Critical** \- A channeled cast that applies a lethal DoT to the group if successful. | Assist with interrupts if you have one. | The boss teleports to a random quadrant and begins the cast. The group must use the teleporters to reach him and apply **two** interrupts to stop the cast.27 |
| **Phase Slash***Single-Target Damage* | Random Players | **High** \- The boss teleports to random players and deals a burst of damage. | Be prepared to spot-heal multiple players in quick succession. | This ability can be dangerous if players are already low from other mechanics. Use defensives if targeted at low health.27 |
| **Dimensional Gates***Phase Transition* | Environment | **Mechanic** \- At 70% and 40% health, walls divide the arena. | None. | These walls create line-of-sight issues and restrict access to teleporters, making both Shuri and Double Technique more difficult to handle.24 |

### **12.0 Dungeon: Tazavesh: So'leah's Gambit**

#### **12.1 Boss Encounter: Hylbrande**

* **Healer Summary:** A fight with a significant tank buster and high burst damage on random players. The main challenge is keeping the group stable during the Sanitizing Cycle while players are focused on the code-breaking mechanic.

| Ability Name & Type | Target(s) | Damage Profile | Healer's Primary Action | Critical Insight |
| :---- | :---- | :---- | :---- | :---- |
| **Shearing Swings***Tank Buster* | Tank | **Critical** \- A heavy two-hit combo that requires mitigation. | Use an external defensive or be ready with large, instant heals. | This is a major source of tank damage and requires the healer's full attention when cast.29 |
| **Purifying Burst***Single-Target Damage* | 3 Random Players | **High** \- A ball of energy splits and hits three random players for heavy damage. | Be prepared to quickly heal the three targeted players. | The targets are marked with red arrows. Advise them to use a personal defensive to ease the healing burden.29 |
| **Purged by Fire***Area Denial* | Random Player | **High** \- A beam from a turret fixates on a player, chasing them and leaving damaging zones. | Spot-heal the kiting player if they are clipped by the beam. | The targeted player must kite this beam around the perimeter of the room, avoiding the runes and consoles needed for the Sanitizing Cycle mechanic.29 |

#### **12.2 Boss Encounter: Timecap'n Hooktail**

* **Healer Summary:** A high-movement fight with several dangerous DoTs. The healer must manage the Time Bomb debuff, spot-heal the Anchor Shot target, and be prepared for the group-wide damage from dispelling Hyperlight Spark.

| Ability Name & Type | Target(s) | Damage Profile | Healer's Primary Action | Critical Insight |
| :---- | :---- | :---- | :---- | :---- |
| **Hyperlight Spark***Magic DoT & Dispel Mechanic* | 2 Random Players | **High** \- A ramping Magic DoT that also provides a 30% Haste buff. | Dispel the debuff before the damage becomes unhealable. | Dispelling triggers group-wide damage. **Never dispel both at the same time.** Stagger the dispels and ensure the group is at full health before each one. Coordinated groups can leverage the Haste buff for longer by using defensives.29 |
| **Anchor Shot***Single-Target Damage & CC* | Random Player | **High** \- A grapple pulls a player towards lethal water and applies a DoT. | Provide strong, focused healing to the targeted player. | The player must run against the pull and use movement abilities to survive. The healing requirement is high for the 6-second duration.29 |
| **Time Bomb***Single-Target Damage (DoT)* | Random Player | **High** \- A heavy DoT on a random player. | Provide sustained healing to the debuffed player. | This is a simple but potent DoT that requires immediate and sustained healing attention.29 |

#### **12.3 Boss Encounter: So'leah**

* **Healer Summary:** A two-phase fight where the healer paces the encounter by managing the soaks for Collapsing Star. The intermission phase, Power Overwhelming, is a major healing cooldown moment. Positioning is key to surviving the final phase.

| Ability Name & Type | Target(s) | Damage Profile | Healer's Primary Action | Critical Insight |
| :---- | :---- | :---- | :---- | :---- |
| **Collapsing Star***Group Damage (Soak)* | Group | **High** \- Orbs spawn that must be soaked, applying a stacking DoT to the entire group. | Soak the orbs one at a time to control the rate of incoming group damage. | As the healer, you are best equipped to pace this mechanic. Step into an orb, heal the group through the 3-second DoT, then soak the next one. Soaking them all at once will cause a wipe.30 |
| **Power Overwhelming***Group Damage (Intermission)* | Group | **Critical** \- The boss takes 99% reduced damage and pulses heavy group-wide damage. | Use major healing cooldowns and sustained AoE healing. | This phase ends when all five players correctly position themselves to aim beams through the relics. The damage is intense and requires a dedicated healing plan.31 |
| **Energy Fragmentation***Area Denial* | Environment | **Critical** \- The five relics on the ground shoot out projectiles in multiple directions. | None directly. Focus on personal survival and dodging. | This mechanic makes the area extremely dangerous. Tanking the boss near the entrance stairs provides more reaction time as the relics are further away.31 |
| **Hyperlight Nova***Area Denial* | Environment | **Critical** \- Large AoE circles appear around the boss and all five relics. | None directly. Move to a safe location. | This is a simple but lethal mechanic. The safe zones can be small, especially when combined with the positioning of Energy Fragmentation projectiles.30 |

