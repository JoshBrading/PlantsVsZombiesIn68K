
collision_MSB   EQU 15   
; **COLLISION**
*---
* Checks for collision between two position by radius
*
* d0.w - left
* d1.w - right
* d2 - Distance to check
*
* d0.b - 1 = collision, 0 = no collision
*---
collision_Distance:
    sub.w   d0, d1  ; right x - left x = distance
    clr.l   d0      
    move.w  d1, d0  ; move word into long 0000FFFF

    cmp.l   d2, d0       ; Is the calculated distance 
    bgt     .noCollision ; smaller than the check distance?
    move.b  #1, d0
    rts
.noCollision
    move.b  #0, d0
    rts

*---
* Checks if a value is between two numbers
*                   R---M---R = Collision
*                   M---R---R = No Collision
* d0.w - Range Start
* d1.w - Range End
* d2.w - Middle Point
*
* d0.b - 1 = collision, 0 = no collision
*---
collision_PointBtwn:
    cmp.w   d1, d0      ; Compare caller entity X pos to target entity X pos
    blt     .dontSwap   ; If caller X is less than target X, dont swap values
    
    exg     d1, d0  ; Swap d1 and d0 to avoid negatives
    
.dontSwap
    cmp.w   d2, d0
    bgt     .noCollision
    
    cmp.w   d2, d1
    blt     .noCollision
    
    move.b  #1, d0
    rts
.noCollision
    move.b  #0, d0
    rts


*---
* Checks if a point is within a rectangle
*
* d0 - Position [X][Y]
* d1 - Size     [W][H]
* d2 - Point    [X][Y]
*
* d0.b - 1 = collision, 0 = no collision
*---
collision_PointRect:
    move.l  d3, -(sp)
    move.l  d0, d3
    add.w   d0, d1
    bsr     collision_PointBtwn
    tst.b   d0
    beq     .noCollision
    
    move.l  d3, d0

    swap    d0
    swap    d1
    swap    d2
    add.w   d0, d1
    bsr     collision_PointBtwn
    beq     .noCollision
    move.l  d3, d0

    move.b  #1, d0
    bra     .done   
 
.noCollision
    move.b  #0, d0

.done
    move.l  (sp)+, d3
    rts   
    
*---
* Checks for collision between two position by radius
*
* d0 - Position 1 [X][Y]
* d1 - Position 2 [X][Y]
* d3 - Radius to check
*
* d0.b - 1 = collision, 0 = no collision
*---
collision_Radius:
    rts

*---
* Checks for collision between two positions
*
* d0 - Position 1 [X][Y]
* d1 - Position 2 [X][Y]
* d2 - [Width 1][Height 1] [Width 2][Height 2]
*
* d0.b - 1 = collision, 0 = no collision
*---
collision_AABB:
       
    rts







*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
