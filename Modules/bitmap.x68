

TASK_PIXEL_COLOR    EQU     80   
TASK_DRAW_PIXEL     EQU     82

BMP_SIGNATURE       EQU     $424D
MAX_FILE_SIZE       EQU     $400038

BMP_BITOFFS         EQU     10
BMP_HEADER_OFFS     EQU     $36
BMP_RES_OFFS        EQU     $12    

*---
* Swaps endian
*
* d0.l - Value to convert
* 
* d0.l - Converted value   
swapEndianLong:
    rol.w   #8, d0
    swap    d0
    rol.w   #8, d0
    rts
 
*---
* Draws a bitmap to a rect on screen
*
* a1 - Start address of bitmap to draw
* d0 - Draw position        [XXXX][YYYY]
* d1 - Draw Width/Height    [WWWW][HHHH]
* d2 - Pixel start position [XXXX][YYYY]
*---
bmp_Draw:
    movem.l   d2-d7/a2, -(sp)

    move.l  d0, -(sp)
    
    swap    d0
    move.w  d0, d4  ; Draw X offset
    
    move.l  BMP_BITOFFS(a1), d0     ;----------
    bsr     swapEndianLong          ;   Get pixel offset
    ;move.l  d0, bmpPixelOffset      ;--------------------
    
    move.l  a1, a2                  ;   Move a2 to start of pixel array
    add.l   d0, a2                  ;--------------------
        
    move.l  BMP_RES_OFFS(a1), d0    ;----------
    bsr     swapEndianLong          ;   Image width - D6
    move.l  d0, d6                  ;--------------------
    
    add.l   #4, a1
    move.l  BMP_RES_OFFS(a1), d0    ;----------
    bsr     swapEndianLong          ;   Image height - D7
    move.l  d0, d7                  ;--------------------
    sub.l   #4, a1
    
    clr.l   d0

   
    move.w  d2, d0  ;   Get row offset
    mulu.w  d6, d0  ;   Convert row offset to index
    swap    d2      ;   
    add.w   d2, d0  ;   Add col offset to index
    lsl.l   #2, d0  ;   Shift byte index to long index
    add.l   d0, a2  ;   Shift address to start of offset pixel array
        
    move.w  d1, d2  ; Draw Height - D2
    sub.w   #1, d2
    swap    d1      ; Move draw width into d1.w
        
    move.w  d6, d5  ; Image width
    sub.w   d1, d5  ; Width - Draw width
    lsl.l   #2, d5  ; x4(Offset to next row - D5)

    move.l  (sp)+, d0

    sub.w   #1, d1


.outerLoop
    add.w   d0, d2
    move.w  d1, d3 ; Set width
    move.l  d1, -(sp)
    move.l  d0, -(sp)

.innerLoop
    move.l  (a2)+, d1               ;----------
   ; cmp.w   #1, d1
   ; beq     .skipPixel
    move.l  #TASK_PIXEL_COLOR, d0   ;   Set pen color
    trap    #15                     ;--------------------

                                    ;----------
    move.w  d3,d1                   ;   X pos - yes this draws mirrored, no I dont plan on fixing it
    add.w   d4, d1                  ;
    ;move.l  d4,d2                  ;   Y pos 
    move.l  #TASK_DRAW_PIXEL,d0     ;   Draw pixel at location
    trap    #15                     ;--------------------
    
.skipPixel
    dbra    d3, .innerLoop
    *** END INNER LOOP ***
    
    move.l  (sp)+, d0
    move.l  (sp)+, d1

    add.l   d5, a2

    sub.w   d0, d2
    dbra    d2, .outerLoop
    bra     .exit

.exit
    movem.l   (sp)+, d2-d7/a2
    rts



*---
* Imprints a bitmap onto a "base" bitmap from the  
* base bitmaps local pixel coordinate spac
*
* a0 - Start address of base bitmap
* a1 - Start address of bitmap to imprint
*
* a0 - Modified base bmp with imprinted bmp
*---
bmp_Imprint:
    movem.l   d0-d7/a0-a7, -(sp)
    move.l  d0, -(sp)  ; Save imprint position
    move.l  a1, a2
    
    *** GET BASE BMP DATA ***
    move.l  BMP_BITOFFS(a0), d0     ;   Get pixel offset
    bsr     swapEndianLong          ;-------------------- 
    
    move.l  a0, a1                  ;   Move a1 to start of pixel array
    add.l   d0, a1                  ;--------------------
        
    move.l  BMP_RES_OFFS(a0), d0    ;----------
    bsr     swapEndianLong          ;   Base image width - D4
    move.l  d0, d4                  ;--------------------
    
    add.l   #4, a0
    move.l  BMP_RES_OFFS(a0), d0    ;----------
    bsr     swapEndianLong          ;   Base image height - D5
    move.l  d0, d5                  ;--------------------
    sub.l   #4, a0
    
    *** GET IMPRINT BMP DATA ***    
    move.l  BMP_BITOFFS(a0), d0     ;   Get pixel offset
    bsr     swapEndianLong          ;-------------------- 
    
    move.l  a2, a3                  ;   Move a3 to start of pixel array
    add.l   d0, a3                  ;--------------------
        
    move.l  BMP_RES_OFFS(a2), d0    ;----------
    bsr     swapEndianLong          ;   Imprint image width - D6
    move.l  d0, d6                  ;--------------------
    
    add.l   #4, a2
    move.l  BMP_RES_OFFS(a2), d0    ;----------
    bsr     swapEndianLong          ;   Imprint image height - D7
    move.l  d0, d7                  ;--------------------
    sub.l   #4, a0
    
    move.l  (sp)+, d0  ; Restore imprint position
    clr.l   d1
    
    *** OFFSET BASE BMP PIXEL ARRAY ***
   ; move.w  d0, d1      ; Y offset
    add.w   d7, d0
    move.w  d5, d1
    sub.w   d0, d1
    
    mulu.w  d4, d1      ; Y * base width = index offset
    swap    d0
    
    add.w   d6, d0
    move.l  d4, d2
    sub.w   d0, d2
   ; add.w   d6, d0
   ; add.w   d0, d2      ; Index offset + X offset = byte index offset
   ; sub.w   d4, d2
    add.w   d2, d1
    lsl.l   #2, d1      ; Byte index offset -> Long index offset
    add.l   d1, a1      ; Move start pixel array to index offset 
    
    move.l  d4, d0
    sub.l   d6, d0
    lsl.l   #2, d0
    
    sub.l   #1, d7
    sub.l   #1, d6
.outerLoop
    move.l  d6, d2  ; Set width
.innerLoop
    move.l  (a3)+, (a1)+
    dbra    d2, .innerLoop
    add.l   d0, a1
    dbra    d7, .outerLoop
    movem.l   (sp)+, d0-d7/a0-a7
    rts

*---
* Imprints a bitmap onto a "base" bitmap from the  
* base bitmaps local pixel coordinate spac
*
* a0 - Start address of base bitmap
* a1 - Start address of bitmap to remove
* a2 - Start address of unmodified bmp
*
* a0 - Modified base bmp with restored pixel data
*---
bmp_BackgroundRestore:
    movem.l   d0-d7/a0-a7, -(sp)
    move.l  d0, -(sp)  ; Save imprint position
    move.l  a2, a4
    move.l  a1, a2
    
    *** GET BASE BMP DATA ***
    move.l  BMP_BITOFFS(a0), d0     ;   Get pixel offset
    bsr     swapEndianLong          ;-------------------- 
    
    move.l  a0, a1                  ;   Move a1 to start of pixel array
    add.l   d0, a1                  ;--------------------
    add.l   d0, a4 ; Move unmodified bmp addr to start of pixel array
        
    move.l  BMP_RES_OFFS(a0), d0    ;----------
    bsr     swapEndianLong          ;   Base image width - D4
    move.l  d0, d4                  ;--------------------
    
    add.l   #4, a0
    move.l  BMP_RES_OFFS(a0), d0    ;----------
    bsr     swapEndianLong          ;   Base image height - D5
    move.l  d0, d5                  ;--------------------
    sub.l   #4, a0
    
    *** GET IMPRINT BMP DATA ***    
    move.l  BMP_BITOFFS(a0), d0     ;   Get pixel offset
    bsr     swapEndianLong          ;-------------------- 
    
    move.l  a2, a3                  ;   Move a3 to start of pixel array
    add.l   d0, a3                  ;--------------------
        
    move.l  BMP_RES_OFFS(a2), d0    ;----------
    bsr     swapEndianLong          ;   Imprint image width - D6
    move.l  d0, d6                  ;--------------------
    
    add.l   #4, a2
    move.l  BMP_RES_OFFS(a2), d0    ;----------
    bsr     swapEndianLong          ;   Imprint image height - D7
    move.l  d0, d7                  ;--------------------
    sub.l   #4, a0
    
    move.l  (sp)+, d0  ; Restore imprint position
    clr.l   d1
    
    *** OFFSET BASE BMP PIXEL ARRAY ***
   ; move.w  d0, d1      ; Y offset
    add.w   d7, d0
    move.w  d5, d1
    sub.w   d0, d1
    
    mulu.w  d4, d1      ; Y * base width = index offset
    swap    d0
    
    add.w   d6, d0
    move.l  d4, d2
    sub.w   d0, d2
   ; add.w   d6, d0
   ; add.w   d0, d2      ; Index offset + X offset = byte index offset
   ; sub.w   d4, d2
    add.w   d2, d1
    lsl.l   #2, d1      ; Byte index offset -> Long index offset
    add.l   d1, a1      ; Move start pixel array to index offset 
    add.l   d1, a4
    
    move.l  d4, d0
    sub.l   d6, d0
    lsl.l   #2, d0
    
    sub.l   #1, d7
    sub.l   #1, d6
.outerLoop
    move.l  d6, d2  ; Set width
.innerLoop
    move.l  (a4)+, (a1)+
    dbra    d2, .innerLoop
    add.l   d0, a1
    add.l   d0, a4
    dbra    d7, .outerLoop
    movem.l   (sp)+, d0-d7/a0-a7
    rts


*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
