This Romhack start from my port of the pokered-gbc to french build upon
If you want a base experience of the pokered-gbc romhack in french, go there : https://github.com/Engezerstorung/pokered-gbc-fr

This romhack includ some changes such as :
- Tweaks to color palettes
- Tweaks to Tilesets to allow more colors use and general visuals improvement while keeping their vanilla design
- Tweaks to some maps and blocksets for visual improvement
- Added uniques party pokémons icons following the tutorial on pret/pokered/wiki
- Replaced the generics pokemons sprites on maps by unique ones from Crystal CLear
- Also the pokécenter Bench Guy is a real little boy now
- Those last two points come with an overhaul to the sprite_OAM engine, as follow :
- You can now create dedicated OAM tables for specific sprites
- You can define a per sprite XY pixel offset
- You can do both those easily in a list at the bottom of  data/sprites/facings.asm

QOL:
 -Runnings shoes



IMPORTANT
To Import save across patched and unpatched versions : 
- Save at the entrance of an interior (like a pokécenter) as of not having to move a block to go out
- Import save in new version
- Load save, press direction to exit the building
- Profit

Made using those sources :
- Full color patch for pokémon red by FroggestSpirit, Drenn, and dannye : https://github.com/dannye/pokered-gbc .
- French disassembly : https://github.com/einstein95/pokered-fr
- Shockwave Crystal Clear Sprites 
- Pret Pokered wiki tutorials : https://github.com/pret/pokered/wiki/Tutorials
- All steming from pret dissassembly : https://github.com/pret/pokered/
