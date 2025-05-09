; **7SEG**

SEG_OFFSET_RIGHT    EQU     20
SEG_OFFSET_MIDDLE   EQU     20
SEG_OFFSET_BOTTOM   EQU     20
SEG_SPACE_BETWEEN   EQU     25

SEG_COLOR           EQU     $00FFFFFF
SEG_BG_COLOR        EQU     $00213A8D
SEG_STROKE_WIDTH    EQU     2
SEG_HEIGHT          EQU     10
SEG_WIDTH           EQU     10

SEG_RECT_W          EQU     85
SEG_RECT_H          EQU     25

TASK_PEN_WIDTH      EQU     93
TASK_DRAW_LINE      EQU     84
TASK_PEN_COLOR      EQU     80
TASK_FILL_COLOR     EQU     81
TASK_DRAW_RECT      EQU     87

seg_DrawScore:
    movem.l   d3-d7, -(sp)
    move.l  d0, d6
    move.l  d1, d7
    move.l  #TASK_PEN_WIDTH, d0
    move.l  #SEG_STROKE_WIDTH, d1
    trap    #15

    move.l  #TASK_FILL_COLOR, d0
    move.l  #SEG_BG_COLOR, d1
    trap    #15
        
    move.l  #TASK_PEN_COLOR, d0
    move.l  #SEG_BG_COLOR, d1
    trap    #15
        
    move.l  d6, d1
    move.l  d7, d2
        
    move.l  d1, d3
    add.l   #SEG_RECT_W, d3
    
    move.l  d2, d4
    add.l   #SEG_RECT_H, d4
    
    move.l  #TASK_DRAW_RECT, d0
    trap    #15    


    
    move.l  #TASK_PEN_COLOR, d0
    move.l  #SEG_COLOR, d1
    trap    #15
    
    move.l  d6, d1
    move.l  d7, d2
    
    sub.l   #SEG_SPACE_BETWEEN, d6

        
    move.l  d5, d0  ; Move score
    ;move.l  #8899, d0
    divu.w  #10, d0
    swap    d0
    
    move.l  #SEG_SPACE_BETWEEN, d1
    mulu    #4, d1
    
    add.l   d1, d6
    
    move.l  d6, d1
    move.l  d7, d2
    
    sub.l   #SEG_SPACE_BETWEEN, d6
    bsr     seg_Draw
    
    move.w  #0, d0
    swap    d0
    divu.w  #10, d0
    swap    d0
    
    move.l  d6, d1
    move.l  d7, d2
    
    sub.l   #SEG_SPACE_BETWEEN, d6
  
    bsr     seg_Draw
    
    move.w  #0, d0
    swap    d0
    divu.w  #10, d0
    swap    d0
    
    move.l  d6, d1
    move.l  d7, d2
    
    sub.l   #SEG_SPACE_BETWEEN, d6
    
    bsr seg_Draw
    
    move.w  #0, d0
    swap    d0
    divu.w  #10, d0
    swap    d0
     
    move.l  d6, d1
    move.l  d7, d2
    
    sub.l   #SEG_SPACE_BETWEEN, d6
    
    bsr seg_Draw  
    
    movem.l   (sp)+, d3-d7
    rts
seg_Draw:

    
    move.l  d0, -(sp)
    lea nums, a1
    move.b  (a1, d0), d5
.seg_DrawTop
    btst    #0, d5
    beq     .seg_DrawRightTop
    movem.l   d1-d2, -(sp)

    move.l  d1, d3
    add.l   #SEG_WIDTH, d1
    
    move.l  d2, d4

    move.l  #TASK_DRAW_LINE, d0 
    trap    #15
    movem.l   (sp)+, d1-d2

.seg_DrawRightTop
    
    lsr.l   #1, d5
    btst    #0, d5
    beq     .seg_DrawRightBottom
        movem.l   d1-d2, -(sp)

    add.l   #SEG_WIDTH, d1
    move.l  d1, d3
    
    move.l  d2, d4
    add.l   #SEG_HEIGHT, d4

    move.l  #TASK_DRAW_LINE, d0 
    trap    #15
    movem.l   (sp)+, d1-d2

.seg_DrawRightBottom
      
    lsr.l   #1, d5
    btst    #0, d5
    beq     .seg_DrawBottom
      movem.l   d1-d2, -(sp)

    add.l   #SEG_WIDTH, d1
    move.l  d1, d3
    
    add.l   #SEG_HEIGHT, d2
    move.l  d2, d4
    add.l   #SEG_HEIGHT, d4

    move.l  #TASK_DRAW_LINE, d0 
    trap    #15
    movem.l   (sp)+, d1-d2

.seg_DrawBottom
    
    lsr.l   #1, d5
    btst    #0, d5
    beq     .seg_DrawLeftBottom
        movem.l   d1-d2, -(sp)

    move.l  d1, d3
    add.l   #SEG_WIDTH, d3
        
    add.l   #SEG_HEIGHT, d2
    add.l   #SEG_HEIGHT, d2
    move.l  d2, d4


    move.l  #TASK_DRAW_LINE, d0 
    trap    #15
    movem.l   (sp)+, d1-d2

    
.seg_DrawLeftBottom
    
    lsr.l   #1, d5
    btst    #0, d5
    beq     .seg_DrawLeftTop
       movem.l   d1-d2, -(sp)

    move.l  d1, d3
        
    add.l   #SEG_HEIGHT, d2
    move.l  d2, d4
    add.l   #SEG_HEIGHT, d4

    move.l  #TASK_DRAW_LINE, d0 
    trap    #15
    movem.l   (sp)+, d1-d2
    
.seg_DrawLeftTop
   
    lsr.l   #1, d5
    btst    #0, d5
    beq     .seg_DrawMiddle
       movem.l   d1-d2, -(sp)

    move.l  d1, d3
        
    move.l  d2, d4
    add.l   #SEG_HEIGHT, d4

    move.l  #TASK_DRAW_LINE, d0 
    trap    #15
    movem.l   (sp)+, d1-d2
    
.seg_DrawMiddle
    
    lsr.l   #1, d5
    btst    #0, d5
    beq     .done  
    movem.l   d1-d2, -(sp)

    move.l  d1, d3
    add.l   #SEG_WIDTH, d3

    add.l   #SEG_HEIGHT, d2
    move.l  d2, d4

    move.l  #TASK_DRAW_LINE, d0 
    trap    #15
    movem.l   (sp)+, d1-d2

.done
    move.l  (sp)+, d0
    rts
    
;   -- 0 --
;  |       |
;  5       1
;  |       |
;   -- 6 --
;  |       |
;  4       2
;  |       |
;   -- 3 --
             ;0         1         2         3         4         5         6         7         8         9
nums dc.b     %0111111, %0000110, %1011011, %1001111, %1100110, %1101101, %1111101, %0000111, %1111111, %1100111







*~Font name~Courier New~
*~Font size~16~
*~Tab type~1~
*~Tab size~4~
