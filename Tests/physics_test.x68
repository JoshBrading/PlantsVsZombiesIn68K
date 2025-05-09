
    ORG     $1000
    
    ;INCLUDE "memory.x68"
    ;INCLUDE "file.x68"
    
TASK_PRINT  EQU 13
TASK_RES    EQU 33
HEAP_BYTES  EQU $500000

START:
    move.l  #$04000400, d1
    moveq   #TASK_RES, d0
    trap    #15
    
    lea     EntityList, a4
    
    move.l  #1, d0
    move.l  a4, a0
    bsr     entity_ListNew
    
    lea     Background, a1      ; If I have time this will be moved to an address, sorry :(
    clr.l   d0                  ; Draw background at 0,0
    move.w  #WINDOW_WIDTH, d1   ; Set background width
    swap    d1
    move.w  #WINDOW_HEIGHT, d1  ; Set background height
    clr.l   d2                  ; Draw background with no crop
    bsr     bmp_Draw
    
    lea     Object, a1
   
    STOP    #$2000

InputFile1  INCBIN  './assets/peashooter.bmp',0
Background  INCBIN  '../assets/bg.bmp',0
Zombie      INCBIN  './assets/zombie.bmp',0
Object      INCBIN  '../assets/peashooter.bmp',0

                ds.l    0
EntityList       ds.b    (ENTITY_SIZE)+ENTITY_HEADER_SIZE        ; Reserve space for plant entity list and header

    END START













*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
