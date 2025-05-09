
TASK_MOUSE_READ     EQU 61
TASK_SET_MOUSE_IRQ  EQU 60
SET_MOUSE_DOWN_CODE EQU $0101
SET_MOUSE_UP_CODE   EQU $0202

IRQ_MOUSE_DOWN      EQU $64    ; IRQ1 - Mouse Down
IRQ_MOUSE_UP        EQU $68    ; IRQ2 - Mouse Up

MOUSE_STATE_UP      EQU 1
MOUSE_STATE_DOWN    EQU 2

MOUSE_TILES_POS_X   EQU 0   ;---
MOUSE_TILES_POS_Y   EQU 85  ; Game board
MOUSE_TILES_W       EQU 500 ; Clickable area
MOUSE_TILES_H       EQU 320 ;---

MOUSE_STORE_POS_X   EQU 8   ;---
MOUSE_STORE_POS_Y   EQU 8   ; Store
MOUSE_STORE_W       EQU 177 ; Clickable area
MOUSE_STORE_H       EQU 57  ;---

; **INPUT**

mouse_Init:
    *** IRQ VECTORS ***
    move.l  #onMouseDown,   IRQ_MOUSE_DOWN  ; These are like event listeners
    move.l  #onMouseUp,     IRQ_MOUSE_UP    ; When the user clicks a mouse button, we jump to the given subroutine

    *** SET MOUSE IRQ ***
    move.b  #TASK_SET_MOUSE_IRQ,    d0
    move.w  #SET_MOUSE_DOWN_CODE,   d1
    trap    #15
    
    move.b  #TASK_SET_MOUSE_IRQ,    d0
    move.w  #SET_MOUSE_UP_CODE,     d1
    trap    #15

    rts


* IRQ handlers

; mouse down handler 
onMouseDown:
    movem.l d0-d1,-(a7)

   ; move.b  #61,d0                  ; read mouse
   ; move.b  #2,d1                   ; mouse down state
   ; trap    #15
       
    cmp.l   #STATE_LOSE, STATE
    bne     .done
    bsr     state_SetRestart
    
.done
    
    movem.l (a7)+,d0-d1
    rte

; mouse up handler
onMouseUp:
    movem.l d0-d7/a0-a2,-(a7) *** Since this will interrupt our code we need to save even our volatile registers

    cmp.l   #100, Score
    blt     .outOfBounds
    sub.l   #100, Score

    move.b  #TASK_MOUSE_READ,d0 ; read mouse
    move.b  #1,d1               ; mouse up state
    trap    #15
    
    ;----------- ROUND MOUSE POSITION ------------------
    ;---------------------------------------------------
    clr.l   d2              ;                           |
    move.w  d1, d2          ; Move mouse Y, X into d2   |
                            ;                           |
    divs    #80, d2         ;                           |
    muls    #80, d2         ; Round to lower 80 pos     |
    add.w   #11, d2         ;                           |
                            ;                           |
    swap    d2              ; Swap to mouse X, Y        |
                            ;                           |
    and.l  #$FFFF0000, d1   ; Mask X                    |
    swap    d1              ;                           |
                            ;                           |
    divs    #80, d1         ;                           |
    muls    #80, d1         ; Round to lower 80 pos     |
    add.w   #11, d1         ;                           |
    ;---------------------------------------------------
    move.l  d1, d0
    
    bsr     mouse_CheckGameBoard                                    
    tst.b   d0                          ; is on game board
    beq     .outOfBounds                ; else skip
    
    move.l  d3, d0                 
    bsr     mouse_CheckTileUsed
    tst.b   d0
    bne     .outOfBounds
    
    lea     Background, a0
    lea     InputFile1, a1
    move.l  d3, d0
    bsr     bmp_Imprint
    clr.l   d0
    ;------------------------- SPAWN PLANT -----------------------------   
    ;-------------------------------------------------------------------
    move.l  d3, d2                  ; Restore offset click position     |
    lea     InputFile1, a1          ; Set bitmap                        |
    lea     PlantList, a0           ; Set plant list as entity list     |
    btst    #1, d0                  ;                                   |
    move.w  #20, d1               ; Set timer                         |
    swap    d1                      ;                                   |
    move.w  #100, d1                ;                                   |
    move.w  #58, d3                 ; Set width                         |
    swap    d3                      ;                                   |
    move.w  #58, d3                 ; Set height                        |
                                    ;                                   |
    lea     plant_Update, a2        ; Set update                        |
                                    ;                                   |
    bsr     entity_ListNewEntity    ; Spawn Plant                       |
    move.l  #$FFFFFE70, ENTITY_OFFSET_VELOCITY(a0)
    move.l  ENTITY_OFFSET_FLAGS(a0), d0
    bset    #ENTITY_BIT_IS_FRIEND, d0
    move.l  d0, ENTITY_OFFSET_FLAGS(a0)
    ;-------------------------------------------------------------------
.outOfBounds    
    movem.l (a7)+,d0-d7/a0-a2
    rte 

*---
* Check if mouse click is within game board
*
* d0 - click position [X][Y]
*
* d0.b - 0 
mouse_CheckGameBoard:
    move.w  d0, d2                      ; Set point position            
    move.l  d2, d3                      ; Save offset click position    
    move.w  #MOUSE_TILES_POS_X, d0      ; Set X position                
    swap    d0                          
    move.w  #MOUSE_TILES_POS_Y, d0      ; Set Y position                
                                                                       
    move.w  #MOUSE_TILES_W, d1          ; Set Width                     
    swap    d1                          
    move.w  #MOUSE_TILES_H, d1          ; Set Height                    
    bsr     collision_PointRect         ; Check if mouse click
    rts

*---
* Check if mouse click is on a plant tile
*
* d0 - click position [X][Y]
*
* d0.b - 0 
mouse_CheckTileUsed:
    move.l  a4, a0
    move.l  ENTITY_LIST_OFFSET_COUNT(a0), d1
    add.l   #ENTITY_LIST_START, a0

.loop
    move.l (a0), d2
    btst   #0, d2   ; Skip entity if inUse = true
    beq     .skipEntity
    
    move.l  ENTITY_OFFSET_POSITION(a0), d2
    cmp.l   d2, d0
    bne     .skipEntity
    
    move.l  #1, d0
    bra     .done
    
.skipEntity
    add.l   #ENTITY_LIST_NEXT_ENT, a0
    dbra    d1, .loop
    move.l  #0, d0
.done
    rts
cursorX dc.w    0
cursorY dc.w    0


















*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
