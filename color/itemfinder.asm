; Hook for engine/items/itemfinder.asm
HiddenItemNear:
    call DelayFrame
    jp _HiddenItemNear ; check for hidden items
