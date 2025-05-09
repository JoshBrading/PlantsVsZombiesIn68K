
    ORG     $1000
    
    ;INCLUDE "memory.x68"
    ;INCLUDE "file.x68"
    INCLUDE "../modules/bitmap.x68"
    
TASK_PRINT  EQU 13
TASK_RES    EQU 33
HEAP_BYTES  EQU $500000

START:
    move.l  #$04000400, d1
    moveq   #TASK_RES, d0
    trap    #15
    
    lea     InputFile1, a1   ;   Load BMP

    move.w  #0, d0
    swap    d0
    move.w  #0, d0
    move.w  #640, d1
    swap    d1
    move.w  #480, d1
    
    move.w  #0, d2
    swap    d2
    move.w  #0, d2
;    bsr     bmp_Draw

    move.l  #3147384, d0
    divu  #10000, d0


    lea     InputFile1, a0   ;   Load BMP
    lea     Imprint, a1
    clr.l   d1
    move.w  #32, d0
    swap    d0
    move.w  #32, d0
    bsr     bmp_Imprint

    lea     InputFile1, a1  ;   Load BMP

    move.w  #0, d0
    swap    d0
    move.w  #0, d0
    move.w  #640, d1
    swap    d1
    move.w  #480, d1
    
    move.w  #0, d2
    swap    d2
    move.w  #0, d2
    bsr     bmp_Draw
   
    lea     InputFile1, a0   ;   Load BMP
    lea     Imprint, a1
    lea     Unmod, a2
    clr.l   d1
    move.w  #32, d0
    swap    d0
    move.w  #32, d0
    bsr     bmp_BackgroundRestore
    
    lea     InputFile1, a1  ;   Load BMP

    move.w  #0, d0
    swap    d0
    move.w  #500, d0
    move.w  #640, d1
    swap    d1
    move.w  #480, d1
    
    move.w  #0, d2
    swap    d2
    move.w  #0, d2
    bsr     bmp_Draw
 
    bra     .done
.error
    moveq   #TASK_PRINT, d0
    lea     ErrorText, a1
    trap    #15

.done

    STOP    #$2000


;            ds.l    0
;StartOfMem
;            dcb.b   HEAP_BYTES,0
            
;InputFile0  dc.b    'gradient32.bmp',0
InputFile1  INCBIN  '../assets/bg.bmp',0
Unmod       INCBIN  '../assets/bg.bmp',0
Imprint     INCBIN  '../assets/peashooter.bmp',0

ErrorText   dc.b    'An error was encountered',0
    END START












*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
