PLANT_FIRE_RATE     EQU     100

*---
* Updates an entity
*
* a0 - Address of entity to update
*
* d0.b - 0 on success, 1 on error
*---
plant_Update:
    move.l  a0, a1  ; Save current entity address to a1

    bsr plant_GetTarget ; TODO: Cache the target until they are DEAD!

    tst.b   d0
    beq     .done
    move.l  a1, a0    
    
    move.w  ENTITY_OFFSET_TIMER(a0), d1
    cmp.w   #0, d1
    bne     .skip
    
    move.l  ENTITY_OFFSET_POSITION(a0), d0  ; Move current entity position to d0
    bsr     plant_Shoot                     ; Spawn a projectile at d0
    move.w  #PLANT_FIRE_RATE, d1
.skip
    sub.w   #1,d1   ; Decrement timer
    move.w  d1, ENTITY_OFFSET_TIMER(a1)
    

.done
    move.l  a1, a0  ; Restore entity address
    rts
    
*---
* Updates an entity
*
* d0.l - XY value to search from
*
* d0.b - 1 if target found, 0 if no target
* a0   - Entity to target
*---
plant_GetTarget:
    move.l  ENTITY_OFFSET_POSITION(a0), d0
    move.l  a5, a0  ; Set ZombieList as list to check
    movem.l   d3-d4, -(sp)
    move.l  ENTITY_LIST_OFFSET_COUNT(a0), d3
    add.l   #ENTITY_LIST_START, a0

.loop
    move.l (a0), d4
    btst   #0, d4   ; Skip entity if inUse = false
    beq     .skipEntity
    
    move.l  ENTITY_OFFSET_POSITION(a0), d1
    cmp.w   d1, d0                          ; Compare caller entity Y pos to target entity Y pos
    bne     .skipEntity                     ; If Y pos not equal, skip
    
    swap    d0  ; Swap to Y X
    swap    d1  ; Swap to Y X
    
    cmp.w   d1, d0      ; Compare caller entity X pos to target entity X pos
    bgt     .skipEntity ; If caller X is greater than target X, skip
    
    move.b  #1, d0
    bra     .done
    
.skipEntity
    add.l   #ENTITY_LIST_NEXT_ENT, a0   ; Move to next entity positions
    
    dbra    d3, .loop

    move.b  #0, d0
    
.done    
    movem.l   (sp)+, d3-d4
    rts

plant_Shoot:
    ;movem   d2/a0, -(sp)
    move.l  ENTITY_OFFSET_POSITION(a0), d2
    swap    d2
    add.w   #60, d2
    swap    d2
    bsr     projectile_new ; uh this will be bad
    ;movem   (sp)+, d2/a0
    rts








*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
