# Horde-Hunter 👽🧟‍♂️

Horde Hunter is a 2D top-down roguelite survival game developed in Godot 4 using GDScript.

As a crash-landed alien warrior, the player must survive infinite waves of mutated zombies, scavenge for technology, and defeat epic bosses to unlock new threats and weapons.

🎮 Game Overview

Genre: Survival Wave Shooter

Engine: Godot 4.3

Art Style: 16-bit Pixel Art

⚙️ Technical Features

💾 Custom Save/Load Architecture

Implemented a robust persistence system using JSON serialization.

Tracks high scores, coin economy, and player stats.

Persistent World State: Defeating a main boss  flips a boolean flag in the save file (user://savegame.json), unlocking that enemy type as a random spawn.

Scene Persistence: Uses a temporary "flag file" system to pass data seamlessly between the Main Menu and the Game Scene.

🌊 Procedural Wave Management

Instead of hard-coded levels, the game uses a mathematical difficulty scaler.

Dynamic Variables: Zombie health, speed, and spawn limits increase automatically based on the current_wave_number.

Boss Injection: The logic detects specific wave intervals (Wave 5, Wave 11) to pause the spawner and inject Boss Scenes.

🎲 Weighted RNG Loot System

Loot crates do not spawn items randomly; they use a Weighted Probability system.

Algorithm: Assigns float weights to items (Coins=40, Lives=20, Walls=10) and calculates drop chances dynamically, allowing for precise control over the game economy.

🔊 Dynamic Audio System

Built a global AudioController singleton.

Handles smooth transitions between Menu, Ambient, and Boss music states.

Prevents audio overlapping and manages SFX priority.

🛠️ Code Highlights

Entity State Management:
Zombies and Bosses are decoupled from the main game loop using Signals. When an entity dies, it emits a died(points) signal that the Game Manager listens for, ensuring modular and clean code.


🚀 How to Run

Clone this repository.

Open Godot Engine 4.3.

Click Import and select the project.godot file from the cloned folder.

Press F5 to run the project.

👨‍💻 Developer

https://orajwije.itch.io/ Self-taught Indie Developer exploring game design and logic in Godot.

Assets and code are for educational and portfolio purposes.
