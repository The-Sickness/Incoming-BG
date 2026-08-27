<div align="center">

<h1>⚔️ Incoming-BG</h1>

<p><strong>Master your communication in WoW PvP.</strong><br>
A full-featured battleground addon with live stats, 68 preset callouts, multi-character tracking, and deep UI customization.</p>

![Version](https://img.shields.io/badge/version-6.9-gold?style=flat-square&color=c8a032)
![Game](https://img.shields.io/badge/WoW-Retail-blue?style=flat-square&color=3a6bbf)
![Messages](https://img.shields.io/badge/preset_messages-68-blue?style=flat-square&color=3a6bbf)
![Status](https://img.shields.io/badge/status-up_to_date-green?style=flat-square&color=2e7d32)

</div>

---

## 📖 Overview

Incoming-BG is purpose-built for players who want comprehensive battleground tools without compromise. Unlike lightweight alternatives, it is always maintained and packs everything into one addon: a live PvP stats dashboard, an extensive callout library, per-character stat tracking across alts, and granular UI customization.

Whether you are holding the Blacksmith at Arathi Basin or chasing the EFC through Twin Peaks, Incoming-BG keeps your team informed and your stats up to date.

---

## ✨ Features

<details>
<summary><strong>📊 Live PvP Stats Dashboard</strong></summary>
<br>

A dedicated stats window displays Honor Points, Conquest Points, Honor Level, and Solo Shuffle Rating — all updated live as you play. Use the character dropdown to switch between alts and view their stored stats without logging out.

> **Note:** You must log into each character at least once for their data to be stored in the addon database.

</details>

<details>
<summary><strong>💬 68 Preset Messages + Custom Callouts</strong></summary>
<br>

Choose from 68 preset messages covering every battleground scenario. Preview any message before sending for clarity and precision.

You can also write your own custom callouts for:

- `INC` — Incoming
- `Send More` — Request reinforcements
- `All Clear` — Location secured
- `Need Heals` — Call for healers
- `EFC` — Enemy flag carrier position
- `FC` — Friendly flag carrier position

Each custom message has a live preview and a one-click clear button.

> ⚠️ **Important:** Custom messages must comply with the WoW Terms of Service. The addon author is not responsible for any violations.

</details>

<details>
<summary><strong>🚩 EFC and FC Buttons</strong></summary>
<br>

Dedicated flag carrier communication with:

- **10 preset messages** for the Enemy Flag Carrier
- **5 preset messages** for your Flag Carrier

</details>

<details>
<summary><strong>🗓️ Weekly Conquest Tracker</strong></summary>
<br>

Tracks your weekly Conquest cap and progress dynamically, always reflecting current objectives and caps set by the game.

</details>

<details>
<summary><strong>🗺️ Adaptive Map (10 Sizes)</strong></summary>
<br>

Adjust your tactical map to any of 10 sizes on the fly — from a broad overview to a close-up of a specific objective area.

</details>

<details>
<summary><strong>🎨 Deep UI Customization</strong></summary>
<br>

Tailor every part of the Incoming-BG interface to match your style:

| Option | Details |
|---|---|
| Button textures | 32 choices |
| Borders and backgrounds | Multiple styles from sleek to bold |
| Fonts and colors | Wide selection of fonts and color palettes |
| Size adjustments | Control font and button sizes independently |

For even more fonts, install **SharedMediaAdditionalFonts**.  
For more textures, install **SharedMedia**.

</details>

---

## 📈 PvP Stats Window

The stats window is organized into five tabs. Use the character dropdown at the top to switch between alts.

> **Note:** Arena data may require a `/reload` to update due to how the API fetches rating data.

| Tab | What It Shows |
|---|---|
| **General** | Player name, Conquest Points, Honor Points, Honor Level, Conquest Cap progress, Solo Shuffle Rating |
| **Battlegrounds** | BGs played / won / lost, total honorable kills, BG honorable kills |
| **Solo RBG** | Best rating, games won, games played, most played spec |
| **Solo Shuffle** | Best rating (current season), rounds won, rounds played, most played spec |
| **Misc** | Total kills, total killing blows, BG killing blows, total deaths, BG deaths |

---

## 🗺️ Battleground Node Coverage

<details>
<summary><strong>View all covered battlegrounds</strong></summary>
<br>

| Battleground | Covered Nodes |
|---|---|
| **Arathi Basin** | Stables, Blacksmith, Lumber Mill, Gold Mine, Farm |
| **Alterac Valley** | Stormpike GY, Irondeep Mine, Dun Baldar, Icewing Pass, Stonehearth Outpost, Iceblood GY, Iceblood Garrison, Tower Point, Coldtooth Mine, Dun Baldar Pass, Icewing Bunker, Field of Strife, Stonehearth GY, Stonehearth Bunker, Frost Dagger Pass, Snowfall GY, Winterax Hold, Frostwolf GY, Frostwolf Village, Frostwolf Keep, Hall of the Frostwolf |
| **Eye of the Storm** | Mage Tower, Draenei Ruins, Blood Elf Tower, Fel Reaver Ruins |
| **Battle for Gilneas** | Lighthouse, Waterworks, Mines |
| **Isle of Conquest** | Docks, Workshop, Hangar, Refinery, Quarry |
| **Twin Peaks** | Wildhammer Stronghold, Dragonmaw Stronghold |
| **Warsong Gulch** | Silverwing Hold, Warsong Flag Room |
| **Wintergrasp** | Broken Temple, Cauldron of Flames, Central Bridge, Chilled Quagmire, Eastern Bridge, Flamewatch Tower, Forest of Shadows, Glacial Falls, Steppe of Life, Sunken Ring, Western Bridge, Winter's Edge Tower, Wintergrasp Fortress, Eastpark Workshop, Westpark Workshop |
| **Deepwind Gorge** | Market, Horde Keep, Alliance Keep |
| **Silvershard Mines** | Lava Crater, Topaz Quarry, Diamond Mine |
| **Temple of Kotmogu** | Full orb control area |
| **Ashran** | Emberfall Tower, Volrath's Advance, Archmage Overwatch, Tremblade's Vanguard |
| **Southshore vs Tarren Mill** | Southshore, Tarren Mill |
| **Stormshield** | Alliance base (Ashran) |

</details>

---

## 🔧 How the Character Dropdown Works

When the addon loads, the dropdown is populated from all characters stored in the `IncCalloutDB` database. Selecting a character triggers a stat fetch and refreshes all five tabs instantly.

The addon also listens for in-game events like zone changes and PvP reward triggers to keep stored stats current automatically.

> **Reminder:** A character must be logged into at least once before their stats appear in the dropdown.

---

## 📦 Recommended Companions

| Addon | What It Adds |
|---|---|
| **SharedMediaAdditionalFonts** | More fonts for the Incoming-BG font dropdown |
| **SharedMedia** | More textures for the button and border dropdowns |

---

<div align="center">

*In WoW PvP, the thin line between triumph and defeat hinges on your ability to communicate clearly and respond swiftly. Incoming-BG puts that edge in your hands.*

</div>
