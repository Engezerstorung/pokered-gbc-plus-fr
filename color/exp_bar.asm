AnimateEXPBarAgain:
	call LoadMonData
	call IsCurrentMonBattleMon
	ret nz
	xor a
	ld [wEXPBarPixelLength], a
	hlcoord 17, 11
	ld a, $63
	ld c, $08
.loop
	ld [hld], a
	dec c
	jr nz, .loop
AnimateEXPBar:
	call LoadMonData
	call IsCurrentMonBattleMon
	ret nz
	ld a, [wBattleMonLevel]
	cp 100
	ret z

	ldh a, [hAutoBGTransferEnabled]
	push af
	ld a, $ff
.breakpoint	
	ldh [hAutoBGTransferEnabled], a

	ld a, SFX_HEAL_HP
	call PlaySoundWaitForCurrent
	callfar CalcEXPBarPixelLength
	ld hl, wEXPBarPixelLength
	ld e, [hl]
	ldh a, [hQuotient + 3]
	ld [hl], a
	sub e
	jr z, .done
	ld b, a
	ld c, $08
	hlcoord 17, 11

	ld a, e
	and $7
	ld e, a
	ld d, 0

.loop1
	ld a, [hl]
	cp $6B
	jr nz, .loop2
	dec hl
	dec c
	jr z, .done
	jr .loop1
.loop2
	ld a, 1
	ldh [hAutoBGTransferPortion], a

	inc e
	ld a, e
	cp 8
	ld a, $64
	jr nz, .notFullExp
	ld a, $6B
	ld e, d
.notFullExp
	ld [hl], a

	jr z, .dontLoad

;	jr nz, .loadPartial
;	call DelayFrame
;	jr .dontLoad
;.loadPartial
	push hl
	push de
	push bc
	farcall LoadPartialBarTile
	pop bc
	pop de
	pop hl
.dontLoad

	call DelayFrame

	dec b
	jr nz, .loop1
.done

	pop af
	ldh [hAutoBGTransferEnabled], a

	ld bc, $08
	hlcoord 10, 11
	ld de, wTileMapBackup + 10 + 11 * 20
	call CopyData
	ld c, $20
	jp DelayFrames

KeepEXPBarFull:
	call IsCurrentMonBattleMon
	ret nz
	ld a, [wEXPBarKeepFullFlag]
	set 0, a
	ld [wEXPBarKeepFullFlag], a
	ld a, [wCurEnemyLevel]
	ret

IsCurrentMonBattleMon:
	ld a, [wPlayerMonNumber]
	ld b, a
	ld a, [wWhichPokemon]
	cp b
	ret
