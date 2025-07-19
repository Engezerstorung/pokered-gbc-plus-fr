; Pseudo-OAM flags used by game logic
	const_def 4
	const BIT_END_OF_OAM_DATA    ; 4
	const_def 7
	const BIT_SPRITE_UNDER_GRASS ; 7

; Used in SpriteFacingAndAnimationTable (see data/sprites/facings.asm)
DEF FACING_END  EQU 1 << BIT_END_OF_OAM_DATA
DEF UNDER_GRASS EQU 1 << BIT_SPRITE_UNDER_GRASS
