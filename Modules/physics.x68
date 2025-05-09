GRAVITY     EQU 42 ; 4.5

*---
* Applies gravity to an entities velocity and position
* **PHYSICS**
* a0 - Entity to apply physics update to
*---
physics_UpdateEntity:
    move.l  #GRAVITY, d0
    move.l  ENTITY_OFFSET_VELOCITY(a0), d1  ; Get velocity
    
    add.w   d0, d1                          ; Add gravity to velocity
    move.l  d1, ENTITY_OFFSET_VELOCITY(a0)  ; Move fixed point velocity back into velocity
    asr.w   #4, d1                          ; Truncate fixed point to whole number
    
    add.l  d1, ENTITY_OFFSET_POSITION(a0)   ; Add velocity to position Y
    rts


*~Font name~Courier New~
*~Font size~16~
*~Tab type~1~
*~Tab size~4~
