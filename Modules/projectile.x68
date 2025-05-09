
PROJECTILE_INIT_VELOCITY    EQU 10
PROJECTILE_FILL_COLOR       EQU $0000CC00
PROJECTILE_STROKE_COLOR     EQU $00000000
PROJECTILE_DIAMETER         EQU $000A000A ; 10x10
PROJECTILE_DRAW_DIAMETER    EQU $00090009

*---
* Create a new projectile
*
* d0.l - XY spawn position [XXXX][YYYY]
*
* d0.b - 0 on success, 1 on error
*---
projectile_New:
    movem.l   d3, -(sp)
    move.l  #0, d0
    move.w  #100, d1
    ;move.w  #0, d2
    ;swap    d2
    ;move.w  #0, d2
    move.l  #PROJECTILE_DIAMETER, d3
    lea     projectile_Update, a2
    ;bsr     entity_New
    move.l  a6, a0                  ; Set projectile list as entity list
    bsr     entity_ListNewEntity    ; Attempt to create new entity
    
    move.l  ENTITY_OFFSET_FLAGS(a0), d0 ; Move entity flags into d0              
    bset    #ENTITY_BIT_IS_PROJ, d0     ; Set projectile flag
    move.l  d0, (a0)                    ; Move updated flags back into entity
    
    movem.l d0/a1, -(sp)
    move.l  #73, d0
    lea     PeaShootSFX, a1
    trap    #15
    movem.l (sp)+, d0/a1  
    movem.l   (sp)+, d3
    rts
    
*---
* Updates a projectile
*
* a0 - Address of projectile entity to update
*
* d0.b - 0 on success, 1 on error
*---
projectile_Update:
    movem.l   d3-d4/a3, -(sp)
    move.l  a0, a3
    
    move.l  ENTITY_OFFSET_POSITION(a0), d0
    move.l  ENTITY_OFFSET_PREV_POSITION(a0), d1
    move.l  d0, ENTITY_OFFSET_PREV_POSITION(a0)
    swap    d0
    add.w   #PROJECTILE_INIT_VELOCITY, d0
    swap    d0
    ;add.w   #PROJECTILE_INIT_VELOCITY, d0

    move.l  d0, ENTITY_OFFSET_POSITION(a0)

    move.l  a5, a0  ; Set ZombieList as list to check
    
    move.l  ENTITY_LIST_OFFSET_COUNT(a0), d3
    add.l   #ENTITY_LIST_START, a0

.loop
    move.l (a0), d4
    btst   #0, d4   ; Skip entity if inUse = false
    beq     .skipEntity
    
    move.l  ENTITY_OFFSET_POSITION(a3), d0
    move.l  ENTITY_OFFSET_POSITION(a0), d2
    cmp.w   d2, d0                          ; Compare caller entity Y pos to target entity Y pos
    bne     .skipEntity                     ; If Y pos not equal, skip
    
    swap    d0  ;-------------
    swap    d1  ; Swap to Y X
    swap    d2  ;-------------
    

   ; cmp.w   d1, d0      ; Compare caller entity X pos to target entity X pos
   ; blt     .dontSwap   ; If caller X is less than target X, dont swap values
    
   ; exg     d1, d0  ; Swap d1 and d0 to avoid negatives
    
;.dontSwap
    ;move.l  #10, d2    
    bsr     collision_PointBtwn
    tst.b   d0
    beq     .noCollision    
    move.w  #50, d0         ; Update to be whatever damage is set by the proj ent
    bsr     entity_Damage   ; Damage the zombie
    tst.b   d0
    beq     .noKill
    move.b  ZombieKillCount, d0
    add.b   #1, d0
    move.b  d0, ZombieKillCount
.noKill
    exg     a3, a0          ; Swap a0 to be the current projectile
    bsr     entity_Kill     ; Kill the projectile
    exg     a3, a0          ; This flips a0 back to the zombie list
   ; add.l   #25, d5 ; APPLY SCORE
    
    movem.l d0/a1, -(sp)
    move.l  #73, d0
    lea     PeaHitSFX, a1
    trap    #15
    movem.l (sp)+, d0/a1 
    ;bra     .done
.noCollision
;    bra     .done
    
.skipEntity

    add.l   #ENTITY_LIST_NEXT_ENT, a0   ; Move to next entity positions
    dbra    d3, .loop
    
.done    
    move.l  a3, a0
    movem.l   (sp)+, d3-d4/a3
    rts
    

    
    rts
    







PeaShootSFX     dc.b 'pea_shoot.wav',0
PeaHitSFX       dc.b 'pea_hit.wav',0




*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
