MACRO RGB
	REPT _NARG / 3

		DEF wWhite = $1F

	; Color correction start here
		; Colors Matrix
		IF COLOR_MATRIX > 0
			IF COLOR_MATRIX == 1 || COLOR_MATRIX > 3
			; Personal matrix made by rouding up Hunterk matrix numbers and taking bRed=0 instead of -1
				; Red matrix
				DEF rRed = 9
				DEF gRed = 2
				DEF bRed = 0
				; Green matrix
				DEF rGreen = 0
				DEF gGreen = 8
				DEF bGreen = 2
				; Blue Matrix
				DEF rBlue = 0
				DEF gBlue = 0
				DEF bBlue = 9
			ELIF COLOR_MATRIX == 2
			; Hunterk Color Mangler matrix
				; Red matrix
				DEF rRed =  0.931954
				DEF gRed =  0.174893
				DEF bRed = -0.106848
				; Green matrix
				DEF rGreen = 0.0473918
				DEF gGreen = 0.7639270
				DEF bGreen = 0.1886810
				; Blue Matrix
				DEF rBlue = 0.0257754
				DEF gBlue = 0.0351781
				DEF bBlue = 0.9390470
			ELIF COLOR_MATRIX == 3
			; Jojobear matrix
				; Red matrix
				DEF rRed = 13
				DEF gRed = 2
				DEF bRed = 1
				; Green matrix
				DEF rGreen = 0
				DEF gGreen = 2
				DEF bGreen = 1
				; Blue Matrix
				DEF rBlue = 0
				DEF gBlue = 2
				DEF bBlue = 14
			ENDC

			DEF dRed = (rRed + gRed + bRed)
			DEF dGreen = (rGreen + gGreen + bGreen)
			DEF dBlue = (rBlue + gBlue + bBlue)

			DEF mRed = (((rRed*(\1)) + (gRed*(\2)) + (bRed*(\3))) / dRed)

			DEF mGreen = (((rGreen*(\1)) + (gGreen*(\2)) + (bGreen*(\3))) / dGreen)

			DEF mBlue = (((rBlue*(\1)) + (gBlue*(\2)) + (bBlue*(\3))) / dBlue)

		ELSE
		; If COLOR_MATRIX = 0 then use original colors 
			DEF mRed = (\1)
			DEF mGreen = (\2)
			DEF mBlue = (\3)
		ENDC

; Gamma start here
		IF GAMMA == 0
			REDEF GAMMA = 1.0
		ENDC

		DEF pGamma = (DIV(1.0, GAMMA))

		DEF gMul = 1.0
		DEF gDiv = (POW(gMul, pGamma))

		DEF ppgRed = (DIV(MUL(mRed, gMul), wWhite))
		DEF ppgGreen = (DIV(MUL(mGreen, gMul), wWhite))
		DEF ppgBlue = (DIV(MUL(mBlue, gMul), wWhite))

		DEF pgRed = (POW(ppgRed, pGamma))
		DEF pgGreen = (POW(ppgGreen, pGamma))
		DEF pgBlue = (POW(ppgBlue, pGamma))

		DEF gRed = (DIV(MUL(pgRed, wWhite), gDiv))
		DEF gGreen = (DIV(MUL(pgGreen, wWhite), gDiv))
		DEF gBlue = (DIV(MUL(pgBlue, wWhite), gDiv))

; White Point start here
		IF WHITE_POINT == 0
			REDEF wRed = wWhite
			REDEF wGreen = wWhite
			REDEF wBlue = wWhite
		ENDC

		DEF wpRed = (gRed * wRed / wWhite)
		DEF wpGreen = (gGreen * wGreen / wWhite)
		DEF wpBlue = (gBlue * wBlue / wWhite)


		IF LCD_COLORS ; experimental, LCD color correction
			DEF whiteHigh = HIGH(palred wRed + palgreen wGreen + palblue wBlue)
			DEF whiteLow = LOW(palred wRed + palgreen wGreen + palblue wBlue)
			dw palred wpRed + palgreen wpGreen + palblue wpBlue
		ELSE
			DEF whiteHigh = $FF
			DEF whiteLow = $FF
			dw palred (\1) + palgreen (\2) + palblue (\3)
		ENDC
		SHIFT 3
	ENDR
ENDM

DEF palred   EQUS "(1 << 0) *"
DEF palgreen EQUS "(1 << 5) *"
DEF palblue  EQUS "(1 << 10) *"

DEF palettes EQUS "* PALETTE_SIZE"
DEF palette  EQUS "+ PALETTE_SIZE *"
DEF color    EQUS "+ PAL_COLOR_SIZE *"

DEF tiles EQUS "* LEN_2BPP_TILE"
DEF tile  EQUS "+ LEN_2BPP_TILE *"

MACRO dbsprite
; x tile, y tile, x pixel, y pixel, vtile offset, attributes
	db (\2 * TILE_WIDTH) % $100 + \4, (\1 * TILE_WIDTH) % $100 + \3, \5, \6
ENDM
