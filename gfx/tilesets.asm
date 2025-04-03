SECTION "Tilesets 1", ROMX

;Overworld_GFX::     INCBIN "gfx/tilesets/overworld.2bpp"
Overworld_GFX::
     INCBIN "gfx/tilesets/overworld.2bpp", $0, tile $60
     INCBIN "gfx/tilesets/overworld.2bpp", tile $100
Overworld_Block::   INCBIN "gfx/blocksets/overworld.bst"
Overworld_Attr::    INCBIN "gfx/blocksets/overworld_attr.bst"

;Overworld_Block::
;	dw Overworld_Block2
;	dw Overworld_Attr

RedsHouse1_GFX::
RedsHouse2_GFX::    INCBIN "gfx/tilesets/reds_house.2bpp"
RedsHouse1_Block::
RedsHouse2_Block::  INCBIN "gfx/blocksets/reds_house.bst"
RedsHouse1_Attr::
RedsHouse2_Attr::   INCBIN "gfx/blocksets/reds_house_attr.bst"

House_GFX::         INCBIN "gfx/tilesets/house.2bpp"
House_Block::       INCBIN "gfx/blocksets/house.bst"
House_Attr::        INCBIN "gfx/blocksets/house_attr.bst"

Mansion_GFX::       INCBIN "gfx/tilesets/mansion.2bpp"
Mansion_Block::     INCBIN "gfx/blocksets/mansion.bst"
Mansion_Attr::      INCBIN "gfx/blocksets/mansion_attr.bst"

SECTION "Tilesets 1bis", ROMX

ShipPort_GFX::      INCBIN "gfx/tilesets/ship_port.2bpp"
ShipPort_Block::    INCBIN "gfx/blocksets/ship_port.bst"
ShipPort_Attr::     INCBIN "gfx/blocksets/ship_port_attr.bst"

Interior_GFX::      INCBIN "gfx/tilesets/interior.2bpp"
Interior_Block::    INCBIN "gfx/blocksets/interior.bst"
Interior_Attr::     INCBIN "gfx/blocksets/interior_attr.bst"

Plateau_GFX::       INCBIN "gfx/tilesets/plateau.2bpp"
Plateau_Block::     INCBIN "gfx/blocksets/plateau.bst"
Plateau_Attr::      INCBIN "gfx/blocksets/plateau_attr.bst"


SECTION "Tilesets 2", ROMX

Dojo_GFX::
Gym_GFX::           INCBIN "gfx/tilesets/gym.2bpp"
Dojo_Block::
Gym_Block::         INCBIN "gfx/blocksets/gym.bst"
Dojo_Attr::
Gym_Attr::          INCBIN "gfx/blocksets/gym_attr.bst"

Mart_GFX::
Pokecenter_GFX::    INCBIN "gfx/tilesets/pokecenter.2bpp"
Mart_Block::
Pokecenter_Block::  INCBIN "gfx/blocksets/pokecenter.bst"
Mart_Attr::
Pokecenter_Attr::   INCBIN "gfx/blocksets/pokecenter_attr.bst"

;Pokecenter_Block::
;Mart_Block::
;     dw Pokecenter_Block2
;     dw Pokecenter_Attr

ForestGate_GFX::
;Museum_GFX::
Gate_GFX::          INCBIN "gfx/tilesets/gate.2bpp"
ForestGate_Block::
;Museum_Block::
Gate_Block::        INCBIN "gfx/blocksets/gate.bst"
ForestGate_Attr::
;Museum_Attr::
Gate_Attr::         INCBIN "gfx/blocksets/gate_attr.bst"


SECTION "Tilesets 2bis", ROMX

Forest_GFX::        INCBIN "gfx/tilesets/forest.2bpp"
Forest_Block::      INCBIN "gfx/blocksets/forest.bst"
Forest_Attr::       INCBIN "gfx/blocksets/forest_attr.bst"

Facility_GFX::      INCBIN "gfx/tilesets/facility.2bpp"
Facility_Block::    INCBIN "gfx/blocksets/facility.bst"
Facility_Attr::     INCBIN "gfx/blocksets/facility_attr.bst"


SECTION "Tilesets 3", ROMX

Cemetery_GFX::      INCBIN "gfx/tilesets/cemetery.2bpp"
Cemetery_Block::    INCBIN "gfx/blocksets/cemetery.bst"
Cemetery_Attr::     INCBIN "gfx/blocksets/cemetery_attr.bst"

Cavern_GFX::        INCBIN "gfx/tilesets/cavern.2bpp"
Cavern_Block::      INCBIN "gfx/blocksets/cavern.bst"
Cavern_Attr::       INCBIN "gfx/blocksets/cavern_attr.bst"

Lobby_GFX::         INCBIN "gfx/tilesets/lobby.2bpp"
Lobby_Block::       INCBIN "gfx/blocksets/lobby.bst"
Lobby_Attr::        INCBIN "gfx/blocksets/lobby_attr.bst"

SECTION "Tilesets 3bis", ROMX

Ship_GFX::          INCBIN "gfx/tilesets/ship.2bpp"
Ship_Block::        INCBIN "gfx/blocksets/ship.bst"
Ship_Attr::         INCBIN "gfx/blocksets/ship_attr.bst"

Lab_GFX::           INCBIN "gfx/tilesets/lab.2bpp"
Lab_Block::         INCBIN "gfx/blocksets/lab.bst"
Lab_Attr::          INCBIN "gfx/blocksets/lab_attr.bst"

Club_GFX::          INCBIN "gfx/tilesets/club.2bpp"
Club_Block::        INCBIN "gfx/blocksets/club.bst"
Club_Attr::         INCBIN "gfx/blocksets/club_attr.bst"

Underground_GFX::   INCBIN "gfx/tilesets/underground.2bpp"
Underground_Block:: INCBIN "gfx/blocksets/underground.bst"
Underground_Attr::  INCBIN "gfx/blocksets/underground_attr.bst"


SECTION "Tilesets 4", ROMX
Museum_GFX::        INCBIN "gfx/tilesets/museum.2bpp"
Museum_Block::      INCBIN "gfx/blocksets/museum.bst"
Museum_Attr::       INCBIN "gfx/blocksets/museum_attr.bst"
