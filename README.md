This Romhack start from my port of the pokered-gbc to french to build upon.

If you want to play the game in english look at the english branch here : https://github.com/Engezerstorung/pokered-gbc-plus-fr/tree/English .

If you want a base experience of the pokered-gbc romhack in french, go there : https://github.com/Engezerstorung/pokered-gbc-fr .

This romhack include some changes such as :
- Tweaks to color palettes
- Tweaks to Tilesets to allow more colors use and general visual improvements while keeping their vanilla design
- Tweaks to some maps and blocksets for visual improvement
- Added uniques party pokémons icons following the tutorial on pret/pokered/wiki
- Added uniques sprites and palettes for Gym Leaders.
- Replaced the generics pokemons sprites on maps by unique ones from Crystal CLear
- Also the pokécenter Bench Guy is a real little boy now
- Those last two points come with an overhaul to the sprite_OAM engine, as follow :
- You can now create dedicated animation tables for specific sprites
- You can define a per sprite XY pixel offset
- You can do both those easily in a list at the bottom of data/sprites/facings.asm

QOL :
- Runnings shoes



IMPORTANT
To Import save across patched and unpatched versions : 
- Save at the entrance of an interior (like a pokécenter) as of not having to move a block to go out
- Import save in new version
- Load save, press direction to exit the building
- Profit

Made using those sources :
- Full color patch for pokémon red by FroggestSpirit, Drenn, and dannye : https://github.com/dannye/pokered-gbc .
- French disassembly : https://github.com/einstein95/pokered-fr
- Pret Pokered wiki tutorials : https://github.com/pret/pokered/wiki/Tutorials
- All steming from pret dissassembly : https://github.com/pret/pokered/

# pokered-gbc

Pokémon Red/Blue overhauled with full GBC support. Made by FroggestSpirit, Drenn, and dannye. Also check out the crysaudio branch.

Original README follows...

# Pokémon Red and Blue [![Build Status][ci-badge]][ci]
