
ENTITY_SIZE                     EQU 32
ENTITY_HEADER_SIZE              EQU 8
   
ENTITY_BIT_IS_PROJ              EQU 5
ENTITY_BIT_SUNGEN               EQU 4
ENTITY_BIT_IS_FRIEND            EQU 3
ENTITY_BIT_IS_DEAD              EQU 2
ENTITY_BIT_DRAW                 EQU 1
ENTITY_BIT_IN_USE               EQU 0

ENTITY_OFFSET_FLAGS             EQU 0
ENTITY_OFFSET_HEALTH            EQU 6   ; word
ENTITY_OFFSET_TIMER             EQU 4   ; word
ENTITY_OFFSET_POSITION          EQU 8
ENTITY_OFFSET_PREV_POSITION     EQU 12
ENTITY_OFFSET_VELOCITY          EQU 16
ENTITY_OFFSET_AABB              EQU 20
ENTITY_OFFSET_BITMAP            EQU 24
ENTITY_OFFSET_UPDATE            EQU 28

ENTITY_LIST_NEXT_ENT            EQU ENTITY_SIZE
ENTITY_LIST_OFFSET_COUNT        EQU 0
ENTITY_LIST_START               EQU 4

*                                      ENTITY
*               --------------------------------------------------------
* Bit Flags -- |   b0000...000[sunGen][isFriend][isDead][draw][inUse]   |
*              |--------------------------------------------------------|
* Small Data - |       [Timer] 0xFF       |       [Health] 0xFF         |
*              |--------------------------------------------------------|
* Position --- |         [X] 0xFFFF       |        [Y] 0xFFFF           |
*              |--------------------------------------------------------|
* Prev Pos --- |         [X] 0xFFFF       |        [Y] 0xFFFF           |
*              |--------------------------------------------------------|
* Veclocity -- |                    0xFFFF.FFFF                         | 
*              |--------------------------------------------------------|
* Size ------- |      [Width] 0xFFFF      |      [Height] 0xFFFF        |
*              |--------------------------------------------------------|
* Bitmap ----- |                     0xFFFFFFFF                         |
*              |--------------------------------------------------------|
* Update ----- |                     0xFFFFFFFF                         |
*               --------------------------------------------------------
*
*   BIT FLAG INDEX
*   --------------
*   [0] inUse        - If true, entity should be updated and drawn every frame
*   [1] draw         - If true, entity should be drawn this frame
*   [2] isDead       - If true, entity should not update but still draw (it will also have physics applied)
*   [3] ifFriend     - if true, entity is on the plants team
*   [4] sunGen       - if true, entity will generate suns on timer
*   [5] isProjectile - if true, entity will be drawn as a primitive circle


*---
* Creates an entity header and fill entity data
* 
* a0 - Address to create entity at
* a1 - Address of bitmap
* a2 - Address of Update
* d0 - Start flags 0x000[sunGen][isFriend][isDead][isStatic][input_unused_inUse]
* d1 - 0x[SunGen][Health]
* d2 - Position [XXXX][YYYY]
* d3 - Hitbox [WWWW][HHHH]
*
* a0 - Address of entity
* d0 - 0 on success, 1 on error
*---
entity_New:    
    *** Initialize Entity ***
    bset    #ENTITY_BIT_IN_USE, d0              ; Set entity inUse flag
    move.l  d0, ENTITY_OFFSET_FLAGS(a0)         ; Set entity flags
    move.l  d1, ENTITY_OFFSET_TIMER(a0)         ; Set enity [timer][health]
    move.l  d2, ENTITY_OFFSET_POSITION(a0)      ; Set entity initial position
    clr.l   ENTITY_OFFSET_PREV_POSITION(a0)     ; Set entity previous position
    clr.l   ENTITY_OFFSET_VELOCITY(a0)          ; Initialize with 0000.0000 velocity 
    move.l  d3, ENTITY_OFFSET_AABB(a0)          ; Set entity bounding box
    move.l  a1, ENTITY_OFFSET_BITMAP(a0)        ; Set bitmap address
    move.l  a2, ENTITY_OFFSET_UPDATE(a0)        ; Set update address
    rts


*---
* Initializes a list of entitie 
*
* a0 - Address to create entity list at
* d0 - Number of entities to initialize inclusive
*
* d0.b - 0 on success, 1 on error
*---
entity_ListNew
    sub.l   #1, d0  ; Offset by 1 to avoid having an extra entity
    move.l  d0, ENTITY_LIST_OFFSET_COUNT(a0)   ; Set entity count in header
    add.l   #ENTITY_LIST_START, a0
.loop
    clr.l   ENTITY_OFFSET_FLAGS(a0)     ; Set entity inUse = false
    add.l   #ENTITY_LIST_NEXT_ENT, a0   ; Move to next entity positions
    dbra    d0, .loop

    rts

*---
* Creates an entity header and fill entity data
* 
* a0 - Address of entity list
* a1 - Address of bitmap
* a2 - Address of Update
* d0 - Start flags 0x000[sunGen][isFriend][isDead][isStatic][input_unused_inUse]
* d1 - 0x[SunGen][Health]
* d2 - Position [XXXX][YYYY]
* d3 - Hitbox [WWWW][HHHH]
*
* a0 - Address of entity
* d0 - 0 on success, 1 on error
*---
entity_ListNewEntity
    movem.l   d3-d5, -(sp)
    move.l  ENTITY_LIST_OFFSET_COUNT(a0), d4
    add.l   #ENTITY_LIST_START, a0

.loop
    move.l (a0), d5
    btst   #0, d5   ; Skip entity if inUse = true
    bne     .skipEntity
    
    bsr     entity_New
    clr.l   d4
    bra     .done
    
.skipEntity
    add.l   #ENTITY_LIST_NEXT_ENT, a0   ; Move to next entity positions
    dbra    d4, .loop
    
.done
    movem.l  (sp)+, d3-d5
    rts

*---
* Updates all entities in the list
*
* a0 - Address of entity list
*
* d0.b - 0 on success, 1 on error
*---
entity_ListUpdate:
    movem.l   d3-d4, -(sp)
    move.l  ENTITY_LIST_OFFSET_COUNT(a0), d3
    add.l   #ENTITY_LIST_START, a0

.loop
    move.l (a0), d4
    btst   #0, d4   ; Skip entity if inUse = false
    beq     .skipEntity
    
    bsr     entity_Update   
    
.skipEntity
    add.l   #ENTITY_LIST_NEXT_ENT, a0   ; Move to next entity positions
    
    dbra    d3, .loop
    
    movem.l   (sp)+, d3-d4
    rts

*---
* Draws all entities in the list
*
* a0 - Address of entity list
*
* d0.b - 0 on success, 1 on error
*---
entity_ListDraw:
    movem.l   d3-d4, -(sp)
    move.l  ENTITY_LIST_OFFSET_COUNT(a0), d3
    add.l   #ENTITY_LIST_START, a0

.loop
    move.l  ENTITY_OFFSET_FLAGS(a0), d0
    btst    #ENTITY_BIT_IN_USE, d0
    beq     .skipEntity
    
    move.l  ENTITY_OFFSET_FLAGS(a0), d0
    btst    #ENTITY_BIT_DRAW, d0
    beq     .skipEntity
    
    bsr     entity_Draw   
    
.skipEntity
    add.l   #ENTITY_LIST_NEXT_ENT, a0   ; Move to next entity positions
    
    dbra    d3, .loop
    movem.l   (sp)+, d3-d4
    rts

entity_ListClear:
    movem.l   d3-d4, -(sp)
    move.l  ENTITY_LIST_OFFSET_COUNT(a0), d3
    add.l   #ENTITY_LIST_START, a0

.loop
    move.l  ENTITY_OFFSET_FLAGS(a0), d0
    btst    #ENTITY_BIT_IN_USE, d0
    beq     .skipEntity
    
    bsr     entity_Kill 
    
.skipEntity
    add.l   #ENTITY_LIST_NEXT_ENT, a0   ; Move to next entity positions
    
    dbra    d3, .loop
    movem.l   (sp)+, d3-d4
    rts

*---
* Updates an entity
*
* a0 - Address of entity to update
*
* d0.b - 0 on success, 1 on error
*---
entity_Update:
    move.l      ENTITY_OFFSET_POSITION(a0), d0
    
    cmp.w       #480, d0
    blt         .checkX
    move.l      #0, (a0)
    ;move.l      d0, ENTITY_OFFSET_POSITION(a0)
    rts
.checkX
    swap        d0
    cmp.w       #640, d0
    blt         .continue
   ; move.w      #0, d0
    ;swap        d0
   ; add.w       #30, d0
    move.l      #0, (a0)
    rts
.continue
    move.l      (a0), d0
    btst        #ENTITY_BIT_IS_DEAD, d0
    beq         .skipPhysics
    
    bsr         physics_UpdateEntity
    
    bra         .setDrawBit
    
.skipPhysics
    move.l      a0, -(sp)
    move.l      ENTITY_OFFSET_UPDATE(a0), a1    ; Move address offset into a1
    jsr         (a1)                            ; JSR to subroutine in value at a1
    move.l      (sp)+, a0
    move.l      ENTITY_OFFSET_PREV_POSITION(a0), d0
    cmp.l       ENTITY_OFFSET_POSITION(a0), d0
    bne         .setDrawBit
    move.l      (a0), d0
    bclr        #ENTITY_BIT_DRAW, d0
    move.l      d0, (a0)    
    rts
    
.setDrawBit
    move.l      (a0), d0
    bset        #ENTITY_BIT_DRAW, d0
    move.l      d0, (a0)
    rts
    

    
    

*---
* Draws  an entity
* **BITMAP**
* a0 - Address of entity to draw
* a1 - Address of background to redraw
*
* d0.b - 0 on success, 1 on error
*---
entity_Draw:
    lea     Background, a1 
    clr.l   d2
    move.l  ENTITY_OFFSET_PREV_POSITION(a0), d0
    sub.l   #1, d0
    move.l  ENTITY_OFFSET_AABB(a0), d1
    add.l   #1, d1
    move.w  #481, d2
    sub.l   ENTITY_OFFSET_PREV_POSITION(a0), d2
    sub.w   d1, d2
    swap    d1
    swap    d2
    sub.w   d1, d2
    swap d1
    swap d2
    bsr     bmp_draw
    
    move.l  ENTITY_OFFSET_FLAGS(a0), d0
    btst    #ENTITY_BIT_IS_PROJ, d0
    bne     .drawProjectile

    move.l  ENTITY_OFFSET_BITMAP(a0), a1
    move.l  ENTITY_OFFSET_POSITION(a0), d0
    move.l  ENTITY_OFFSET_AABB(a0), d1
    clr.l   d2
    bsr     bmp_Draw
    bra     .done
    
.drawProjectile
    movem.l   d3-d4, -(sp)
    
    move.l  #TASK_PEN_WIDTH, d0
    move.l  #0, d1
    trap    #15
    
    move.l	#PROJECTILE_STROKE_COLOR,d1
	move.b	#SET_PEN_COLOR_COMMAND,d0
	trap	#15
	
	move.l	#PROJECTILE_FILL_COLOR,d1
	move.b	#SET_FILL_COLOR_COMMAND,d0
	trap	#15
	
    move.l  ENTITY_OFFSET_POSITION(a0), d1    
       	
    move.w	d1,d2       ; Upper Y
	move.l	d2,d4       ; Move Upper Y into Lower Y  
    add.l	#PROJECTILE_DRAW_DIAMETER,d4      ; Add Height to Lower Y
    
    swap    d1          ; Left X
	move.l	d1,d3       ; Move Left X into Right X
	add.l	#PROJECTILE_DRAW_DIAMETER,d3		; Add width to Right X

   
	move.b	#DRAW_CIRCLE_COMMAND,d0
	trap	#15
	movem.l   (sp)+, d3-d4
	
.done
    move.l  ENTITY_OFFSET_POSITION(a0), d0
    move.l  d0, ENTITY_OFFSET_PREV_POSITION(a0)
    rts
    
*---
* Damages an entity
* 
* a0 - Entity to damage
* d0 - Damage to apply
*
* d0 - 0 = alive, 1 = killed
*---
entity_Damage:
    move.w  ENTITY_OFFSET_HEALTH(a0), d1
    sub.w   d0, d1
    cmp.w   #0, d1
    bgt     .survived
    bsr     entity_Kill
    move.b  #1, d0
    rts
.survived
    move.w  d1, ENTITY_OFFSET_HEALTH(a0)
    move.b  #0, d0
    rts
    
*---
* Kill an entity
* 
* a0 - Entity to kill
*---
entity_Kill:
    move.l  ENTITY_OFFSET_FLAGS(a0), d0
    btst    #ENTITY_BIT_IS_FRIEND, d0
    beq     .drawBG
    
    move.l  ENTITY_OFFSET_POSITION(a0), d0
    move.l  ENTITY_OFFSET_BITMAP(a0), a1
    move.l  a0, -(sp)
    lea     Background, a0
    lea     UnmodifiedBG, a2
    bsr     bmp_BackgroundRestore
    move.l  (sp)+, a0
.drawBG
    lea     Background, a1                          ; If this line is still here... pretend you didnt see it
    clr.l   d2                                      ;
    move.l  ENTITY_OFFSET_PREV_POSITION(a0), d0     ;*
    move.l  ENTITY_OFFSET_AABB(a0), d1              ;*
    move.w  #481, d2                                ;*
    sub.l   ENTITY_OFFSET_PREV_POSITION(a0), d2     ;*
    sub.w   d1, d2                                  ;*  Move to new subroutine or into draw
    swap    d1                                      ;*
    swap    d2                                      ;*
    sub.w   d1, d2                                  ;*
    swap d1                                         ;*
    swap d2                                         ;*
    bsr     bmp_draw                                ;*
    move.l  ENTITY_OFFSET_FLAGS(a0), d0
    btst    #ENTITY_BIT_IS_PROJ, d0
    beq     .disable
    
    bset    #ENTITY_BIT_IS_DEAD, d0
    move.l  d0, ENTITY_OFFSET_FLAGS(a0)
    move.l  #$FFFFFF60, ENTITY_OFFSET_VELOCITY(a0)
    
    bra     .done
.disable
    move.l  #0, ENTITY_OFFSET_FLAGS(a0)
.done
    ;move.l  #0, (a0)    ; Reset entity flags
    rts
    

















*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
