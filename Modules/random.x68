ALL_REG                 REG     D0-D7/A0-A6

GET_TIME_COMMAND        equ     8


seedRandomNumber
        movem.l ALL_REG,-(sp)           ;; What does this do?
        clr.l   d6
        move.b  #GET_TIME_COMMAND,d0    ;; What if you used the same seed?
        TRAP    #15

        move.l  d1,RANDOMVAL
        movem.l (sp)+,ALL_REG
        rts

*---
* Get a random byte in range
* 
* d0 - Start
* d1 - End
*
* d0 - random byte in range
*---
random_ByteRange
        movem.l d0,-(sp)
        movem.l d1,-(sp)
        move.l  RANDOMVAL,d0
       	moveq	#$AF-$100,d1
       	moveq	#18,d2
Ninc0	
    	add.l	d0,d0
    	bcc	Ninc1
    	eor.b	d1,d0
Ninc1
    	dbf	d2,Ninc0
	
    	move.l	d0,RANDOMVAL
    	clr.l	d2
    	move.b	d0,d2
	
        movem.l (sp)+,d1
        movem.l (sp)+,d0
        
        divu    d1, d2
        swap    d2
        add.b   d0, d2
        clr.l   d0
        move.b  d2, d0
        
        rts

RANDOMVAL       ds.l    1






*~Font name~Courier New~
*~Font size~16~
*~Tab type~1~
*~Tab size~4~
