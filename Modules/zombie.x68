ZOMBIE_SPEED    EQU     1
ZOMBIE_ATK_SOUND EQU    0
ZOMBIE_ATK_DIST EQU     30
ZOMBIE_ATK_DMG  EQU     5
ZOMBIE_HEALTH   EQU     100

*---
* Spawn a new zombie at position
* if there is space in the zombie list
*
* d0 - Spawn position [X][Y]
*
* a0 - Zombie spawned
*---
zombie_New:
    move.l  d3, -(sp)
    move.l  d0, d2                  ; Set spawn position
    clr.l   d0  
    move.l  #ZOMBIE_HEALTH, d1      ; Set zombie health

    move.w  #12, d3                 ; Set zombie width
    swap    d3
    move.w  #16, d3                 ; Set zombie height
    
    lea     zombie_Update, a2       ; Set zombie update
    lea     Zombie, a1              ; Set zombie bmp

    move.l  a5, a0                  ; Set zombie list as entity list
    bsr     entity_ListNewEntity    ; Spawn
    move.l  (sp)+, d3
    rts
*---
* Update Zombie
*
* a0 - Address of entity to update
*---
zombie_Update:
    move.l  a0, -(sp)
    bsr     zombie_FindTarget   ; Check for plant in range
    move.l  a0, a1
    move.l  (sp)+, a0
    tst.b   d0
    bne     .doAttack
    
    move.l  ENTITY_OFFSET_POSITION(a0), d0          ; Get current position
    move.l  ENTITY_OFFSET_PREV_POSITION(a0), d1     
    move.l  d0, ENTITY_OFFSET_PREV_POSITION(a0)     ; Set prev pos to curr pos
    swap    d0                                      ; Swap XY to YX
    sub.w   #ZOMBIE_SPEED, d0                       ; Apply move speed
    swap    d0                                      ; Swap YX to XY
    move.l  d0, ENTITY_OFFSET_POSITION(a0)          ; Update curr position
    
    swap    d0
    cmp.w   #0, d0          ; Check if zombie reached left side of screen
    bgt     .noLose         ; If not, skip
    bsr     state_SetLose   ; Otherwise, set the lose state
.noLose
  
    bra     .done

.doAttack
    bsr     zombie_Attack
    
.done
    rts


*---
* Check for plant to attack
*
* a0 - Address of zombie
* 
* d0 - 0 = No plant in range, 1 = Plant in range
* a1 - Plant entity in range, junk is no plant in range
*---
zombie_FindTarget:
    move.l  d3, -(sp)
    move.l  ENTITY_OFFSET_POSITION(a0), d1  ; Position XY
    
    move.l  a4, a0
    move.l  ENTITY_LIST_OFFSET_COUNT(a0), d3
    add.l   #ENTITY_LIST_START, a0

.loop
    move.l  (a0), d2
    btst    #0, d2   ; Skip entity if inUse = true
    beq     .skipEntity
    
    move.l  ENTITY_OFFSET_POSITION(a0), d0
    cmp.w   d0, d1 ; Check if Row is equal
    bne     .skipEntity

    swap    d0
    swap    d1
    move.l  #ZOMBIE_ATK_DIST, d2
    bsr     collision_Distance
    swap    d1
    tst.b   d0
    beq     .skipEntity
    
    move.l  #1, d0
    bra     .done
    
.skipEntity
    add.l   #ENTITY_LIST_NEXT_ENT, a0
    dbra    d3, .loop
    move.l  #0, d0
.done
    move.l  (sp)+, d3
    rts

*---
* Have zombie attack entity
*
* a0 - Address of zombie entity
* a1 - Address of entity to attack
*---
zombie_Attack:
    cmp.w   #0, ENTITY_OFFSET_TIMER(a0)
    bne     .skipSFX
    
    movem.l d0/a1, -(sp)
    move.l  #73, d0
    lea     ZombieEatSFX, a1
    trap    #15
    movem.l (sp)+, d0/a1 
    
.skipSFX
    exg     a1, a0
    move.l  #ZOMBIE_ATK_DMG, d0
    bsr     entity_Damage
    exg     a1, a0
    tst.b   d0
    bne     .skipResetSFX
    move.w  #1, ENTITY_OFFSET_TIMER(a0)
.skipResetSFX

    rts

*---
* Spawns zombies 
* **RANDOM**
*---
zombie_Generator
    move.l  #0, d0
    move.l  #4, d1
    bsr     random_ByteRange
    mulu    #2, d0
    exg     a4, d6
    ;move.l  #0, d0
    lea     RowPositionArray, a4
    move.w  #600, d2
    swap    d2
    move.w  (a4, d0), d0    ; Y Position
    swap    d0              ; Switch to YX
    move.w  #600, d0        ; X Position
    swap    d0              ; Swap back to XY
    ;move.w  #0, d0
    bsr     zombie_New
    
    exg     a4, d6
    rts
    
ZombieEatSFX    dc.b    'zombie_eat.wav',0
                dc.l    0



*~Font name~Courier New~
*~Font size~16~
*~Tab type~1~
*~Tab size~4~
