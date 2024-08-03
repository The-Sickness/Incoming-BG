Incoming-BG: Master Your Communication in WoW PvP

 

Elevate Your PvP Experience with Incoming-BG. Crafted meticulously by me, Incoming-BG is your premier addon for mastering the battlegrounds in World of Warcraft. Whether you're defending the honor of the Alliance in Stormwind or launching an assault in Orgrimmar, Incoming-BG transforms your gameplay into a strategic, well-communicated victory. Unlike similar add-ons, this one is not lightweight and is always up-to-date. 

 

Comprehensive Features:
 

Centralized PvP Stats Dashboard
Keep vital PvP statistics at your fingertips. This dedicated window displays Honor Points, Conquest Points, Honor Level, and Solo Shuffle Rating, all updated live as you engage in combat. The addition of a new character dropdown feature enhances this functionality by allowing you to switch between different characters and specs seamlessly, viewing specific PvP stats without the need to log out. Perfect for those who want to track their progress across multiple characters without pausing the action. Please keep in mind that you MUST log into whatever character stats you want to look at, at least once. That way their info is stored in the saved variables.

 

One-Click Accessibility
Integrated directly into the Incoming-BG’s main user interface, a new, easily accessible button allows you to swiftly pull up your PvP stats overview. This feature ensures that you’re always informed and ready, even mid-battle.

 

Refined User Interface Design
With a focus on usability, the new interface design strips away any unnecessary elements. The result is a clean, minimalist layout that not only looks good but enhances your gameplay by reducing distractions.

 

Real-Time Stat Updates
As you earn points and climb the ranks, the addon window dynamically updates. Watch your statistics change in real time, reflecting your on-field successes instantaneously.

 

Extensive Message Options
Choose from an arsenal of 68 preset messages, designed to cover every conceivable battleground scenario. Preview your message before sending to ensure clarity and precision.

 

Custom Messages
Players can now create their own custom messages for 'Send More', 'INC', 'All Clear', 'Need Heals', 'EFC', and 'FC' messages. Each custom message has a preview feature to show how it will look in chat. Custom messages can be individually cleared using the new 'Clear' button next to each custom message input field.

WARNING: Ensure that your custom messages comply with the game's Terms of Service (TOC). I am not responsible for any violations of the TOC, and I will not be held responsible for any consequences resulting from such violations.

 

Adaptive Map Integration
Customize your tactical view with 10 different map sizes. Whether you need a broad overview or a detailed close-up of a specific area, adjust your map dynamically to suit the encounter’s demands.

 

Deep Customization Tools
Tailor the Incoming-BG interface to fit your personal or team style:

Borders & Backgrounds: Choose from a variety of designs—from sleek and modern to rugged and bold.
Button Textures: Choose from 32 different textures for your buttons.
Fonts & Colors: Experiment with an array of fonts and color palettes to find what best suits the intensity of PvP encounters or matches your existing UI.
Size Adjustments: Modify font and button sizes for optimal readability and aesthetic preference.
New Weekly Conquest Tracker
A newly added feature to track your weekly Conquest cap and progress dynamically, reflecting current objectives and caps set by the game.

 

New EFC and FC Buttons
Enhanced communication with 10 preset messages for the Enemy Flag Carrier and 5 for our Flag Carrier, facilitating critical battlefield communications.

 

New Solo Shuffle Rating Tracking
Introducing a dynamic feature to track your Solo Shuffle rating specific to each specialization. The PvP Stats window now includes a dropdown to select between different characters, enhancing its utility by allowing you to view and compare stats across your alts without needing to log in and out. (Please keep in mind that the way the API fetches arena data may result in having to do a /reload to update.)

 

Customizable Button Textures
We're excited to introduce a new feature that allows players to customize their button textures! You can now choose from up to 32 different button textures to personalize your PvP experience. Whether you prefer a sleek, modern look or a classic, traditional design, there's a texture to match your style.

 

New Features and Changes in PvP Stats Window
General Tab

Player Name: Displays the name of the currently selected player.
Conquest Points: Shows the current number of Conquest Points the player has earned.
Honor Points: Indicates the current number of Honor Points the player has earned.
Honor Level: Displays the player's current Honor Level.
Conquest Cap: Shows the player's current progress towards the Conquest Cap.
Solo Shuffle Rating: Indicates the player's rating in Solo Shuffle.

BG’s (Battlegrounds) Tab

BGs Played: Displays the total number of battlegrounds played.
BGs Won: Shows the total number of battlegrounds won.
BGs Lost: Indicates the total number of battlegrounds lost.
Total Honorable Kills: Displays the total number of honorable kills achieved by the player.
Battleground Honorable Kills: Shows the number of honorable kills achieved specifically in battlegrounds.

Solo RBG Tab (previously Blitz Tab)

Best Rating: Displays the player's highest rating achieved in Solo RBG.
Games Won: Indicates the number of Solo RBG games won by the player.
Games Played: Shows the total number of Solo RBG games played by the player.
Most Played Spec: Displays the specialization most frequently used by the player in Solo RBG.
Played Most: Shows the statistic related to the most played aspect by the player in Solo RBG.

Solo Shuffle Tab

Best Rating: Displays the player's best rating achieved in Solo Shuffle for the current season.
Rounds Won: Indicates the number of Solo Shuffle rounds won in the current season.
Rounds Played: Shows the total number of Solo Shuffle rounds played in the current season.
Most Played (Spec): Displays the player's most played specialization in Solo Shuffle for the current season.

Misc Tab

Total Kills (Exp or Honor): Displays the total number of kills that grant experience or honor.
Total Killing Blows: Shows the total number of killing blows.
Battleground Killing Blows: Indicates the number of killing blows achieved in battlegrounds.
Total Deaths: Displays the total number of deaths.
Battleground Deaths: Shows the total number of deaths in battlegrounds.

How the Character Dropdown Works
The character dropdown menu is designed to allow you to switch between different characters and view their respective PvP stats without having to log into each one separately. Here's how it works:

Initialization
When the addon is loaded, the dropdown menu is initialized with a list of characters stored in the IncCalloutDB database. Each character is listed with their full name (including realm).

 

OnClick Event
When a character is selected from the dropdown, the OnClick function is triggered. This function:

Sets the selected character as the active one in the dropdown menu.
Updates the displayed stats for the newly selected character by fetching the relevant data from the IncCalloutDB database.
Highlights the selected character's tab to indicate the active selection.
Data Fetching
The stats for the selected character are fetched from the IncCalloutDB database. This database stores various PvP statistics for each character, including Conquest Points, Honor Points, Solo Shuffle Rating, and more.

 

Display Update
The fetched data is then used to update the corresponding UI elements in the various tabs (General, BG's, Blitz, Solo Shuffle, and Misc). Each tab displays specific stats relevant to its category.

 

Event Handling
The addon includes event handlers that listen for various game events, such as entering the world, changing zones, and receiving PvP rewards. When these events occur, the addon updates the stored stats and refreshes the display to ensure the information is always current.

By using the dropdown menu, you can quickly switch between characters and view up-to-date PvP statistics without needing to log in and out of each character. This feature enhances the convenience and usability of the addon, allowing you to manage and monitor the PvP progress of multiple characters seamlessly.

Update to version 6.9 of Incoming-BG today and enjoy a more personalized and visually appealing PvP experience!

 

 For more additional fonts please go SharedMediaAdditionalFonts, it will add many more fonts to the dropdown that you can choose from.

For more additional textures please go to SharedMedia, it will add more textures to the dropdown.

 

 

Detailed Node Coverage: Incoming-BG provides strategic insights into each battleground’s critical areas, meticulously covering all key locations to ensure superior strategic planning:

Arathi Basin: Stables, Blacksmith, Lumber Mill, Gold Mine, Farm
Alterac Valley: Stormpike Graveyard, Irondeep Mine, Dun Baldar, Hall of the Stormpike, Icewing Pass, Stonehearth Outpost, Iceblood Graveyard, Iceblood Garrison, Tower Point, Coldtooth Mine, Dun Baldar Pass, Icewing Bunker, Field of Strife, Stonehearth Graveyard, Stonehearth Bunker, Frost Dagger Pass, Snowfall Graveyard, Winterax Hold, Frostwolf Graveyard, Frostwolf Village, Frostwolf Keep, Hall of the Frostwolf
Eye of the Storm: Mage Tower, Draenei Ruins, Blood Elf Tower, Fel Reaver Ruins
Battle for Gilneas: Lighthouse, Waterworks, Mines
Isle of Conquest: Docks, Workshop, Hangar, Refinery, Quarry
Twin Peaks: Wildhammer Stronghold, Dragonmaw Stronghold
Warsong Gulch: Silverwing Hold, Warsong Flag Room
Wintergrasp: The Broken Temple, Cauldron of Flames, Central Bridge, The Chilled Quagemire, Eastern Bridge, Flamewatch Tower, The Forest of Shadows, Glacial Falls, The Steppe of Life, The Sunken Ring, Western Bridge, Winter's Edge Tower, Wintergrasp Fortress, Eastpark Workshop, Westpark Workshop
Deepwind Gorge: Market, Horde Keep, Alliance Keep
Silvershard Mines: Lava Crater, Topaz Quarry, Diamond Mine
Temple of Kotmogu: Generally the whole area is treated as a node for orb control.
Ashran: Emberfall Tower, Volrath's Advance, Archmage Overwatch, Tremblade's Vanguard
Southshore vs. Tarren Mill: Not typically a node-based battleground but includes major town areas: Southshore and Tarren Mill.
Stormshield: Part of Ashran, serving as the Alliance base.
Step Into Strategy with Incoming-BG: In WoW PvP, the thin line between triumph and defeat hinges on your ability to communicate clearly and respond swiftly. With Incoming-BG, empower your team with streamlined communication tools, real-time data, and customizable features that bring tactical advantage to your fingertips.
