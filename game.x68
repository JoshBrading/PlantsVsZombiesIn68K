;
;   Register Index
;   ----------------------------------------
;   D0 - Valotile    |   A0 - Valotile
;   D1 - Valotile    |   A1 - Valotile
;   D2 - Valotile    |   A2 - Valotile
;   D3 - _           |   A3 - Shop
;   D4 - Cycle Count |   A4 - Plant List
;   D5 - Points      |   A5 - Zombie List
;   D6 - RowPosArrAdr|   A6 - Projectile List
;   D7 - ZombSpwnTime|
;   -----------------------------------------
;
;   Game States
;   -----------------------------------------
;   0 - Start       | Waiting for input
;   1 - Play        | Game is in play
;   2 - Pause       | Game is paused
;   3 - Lose        | Displays losing banner
;   4 - Win         | Displays winning banner
;   5 - Restart     | Cleans up scene and 
;                   | - moves to state 0
;   -----------------------------------------
    
    ORG     $1000
    
    INCLUDE "imports.x68"

DEBUG_RECT_RED          EQU     $000000FF
    
SET_PEN_COLOR_COMMAND   EQU     80
SET_FILL_COLOR_COMMAND  EQU     81
DRAW_CIRCLE_COMMAND     EQU     88

WINDOW_WIDTH            EQU 640
WINDOW_HEIGHT           EQU 480

PLANT_COUNT             EQU 28   ; Max number of plants at a time
ZOMBIE_COUNT            EQU 16    ; Max zombies at a time
PROJECTILE_COUNT        EQU 32   ; Max projectiles at a time

ZOMBIE_WAVE_COUNT       EQU 3

TASK_DOUBLE_BUFFER_MODE EQU 17
TASK_DRAW_MODE          EQU 92
TASK_SWAP_BUFFER        EQU 94
    
TASK_PRINT  EQU 13
TASK_RES    EQU 33


START:

    lea     RowPositionArray, a4
    move.l  a4, d6
    lea     PlantList, a4
    lea     ZombieList, a5
    lea     ProjectileList, a6

    bsr     mouse_Init  ; Init mouse IRQ

    move.b  #TASK_DRAW_MODE, d0             ;--------------------
    move.b  #TASK_DOUBLE_BUFFER_MODE, d1    ; Setup double buffer
    trap    #15                             ;--------------------
    
    movem.l d0/a1, -(sp)
    move.l  #73, d0
    lea     Music, a1
    trap    #15
    movem.l (sp)+, d0/a1 
    
restart

    lea     Zombie, a1    

    *** INIT ENTITY LISTS ***
    move.l  #PLANT_COUNT, d0        ;
    move.l  a4, a0                  ;   Initialize an entity list of PLANT_COUNT size
    bsr     entity_ListNew          ;
    
    move.l  #ZOMBIE_COUNT, d0       ;
    move.l  a5, a0                  ;   Initialize an entity list of ZOMBIE_COUNT size
    bsr     entity_ListNew          ;
    
    move.l  #PROJECTILE_COUNT, d0   ;
    move.l  a6, a0                  ;   Initialize an entity list of PROJECTILE_COUNT size
    bsr     entity_ListNew          ;
   
    *** RENDER BACKGROUND ***
    lea     Background, a1      ; If I have time this will be moved to an address, sorry :(
    clr.l   d0                  ; Draw background at 0,0
    move.w  #WINDOW_WIDTH, d1   ; Set background width
    swap    d1
    move.w  #WINDOW_HEIGHT, d1  ; Set background height
    clr.l   d2                  ; Draw background with no crop
    bsr     bmp_Draw
    
   ; bsr     projectile_New
    ;move.l  #2500, d6
    bsr     seedRandomNumber
    move.l  #1000, d7
    clr.l   d5
    
    move.l  #0, Score
    move.l  #0, ZombieKillCount
    clr.l   d0
    lea     ZombiesPerWave, a0
    move.b  (a0), d0
    move.l  d0, (a5)
    bsr     state_SetPlay
.loop


    
    move.l  #30, d0  
    trap    #15

    add.l   #2, Score
    
    cmp.l   #0, d7
    bgt     .skipSpawn
    
    bsr     zombie_Generator

    move.l  #1000, d7
.skipSpawn
    sub.l   #100, d7

    cmp.l   #STATE_PLAY, STATE
    bne     .skipGame
    bsr     game_Loop    
.skipGame

    cmp.l   #STATE_WIN, STATE
    bne     .skipWin
    bsr     game_Win
.skipWin

    cmp.l   #STATE_LOSE, STATE
    bne     .skipLose
    bsr     game_Lose
.skipLose

    cmp.l   #STATE_RESTART, STATE
    bne     .skipRestart
    bsr     game_Restart
.skipRestart

    move.b  #TASK_SWAP_BUFFER, d0   ; Swap Buffer
    trap    #15                     ;-----------------
    
.delayUpdate
    move.l  #31, d0
    trap    #15
    
    cmp.l   #600000, d1
    blt     .delayUpdate
    
    bra     .loop

.error
    moveq   #TASK_PRINT, d0
    lea     ErrorText, a1
    trap    #15

.done

    STOP    #$8000


game_Loop:

    cmp.b   #ZOMBIE_WAVE_COUNT, ZombieWave
    bne     .skipNewWave
.noWin

    clr.l   d0
    clr.l   d1    
    lea     ZombiesPerWave, a0
    move.b  ZombieKillCount, d0
    move.b  ZombieWave, d1
    add.l   d1, a0
    move.b  (a0), d1
    cmp.b   d1, d0
    bne     .skipNewWave
    add.b   #1, ZombieWave
    ;move.b  ZombieWave, d1
    add.l   #1, a0
    move.b  (a0), d1
    move.l  d1, (a5)
    ;move.b  #0, ZombieKillCount
.skipNewWave


    lea     Background, a1  

    *** DO ENTITY UPDATES ***
    move.l  a4, a0              ; Update Plants
    bsr     entity_ListUpdate   ;---------------------  
  
    move.l  a6, a0              ; Update Projectiles
    bsr     entity_ListUpdate   ;---------------------
    
    move.l  a5, a0              ; Update Zombies
    bsr     entity_ListUpdate   ;---------------------
    *** END ENTITY UPDATES ***
    
    
    
    
    *** DO ENTITY DRAWS ***
    move.l  a4, a0              ; Draw Plants
    bsr     entity_ListDraw     ;---------------------

    move.l  a5, a0              ; Draw Zombies
    bsr     entity_ListDraw     ;---------------------
    
    move.l  a6, a0              ; Draw Projectiles
    bsr     entity_ListDraw     ;---------------------
    *** END ENTITY DRAWS ***

    move.l  Score, d5
    cmp.l   #9999, d5
    ble     .skipScoreCap
    move.l  #9999, d5
.skipScoreCap
    move.l  #232, d0
    move.l  #38, d1
    bsr     seg_DrawScore
    rts
    
game_Lose:
    lea     LoseScreen, a1
    move.w  #212, d0
    move.w  #640, d1
    swap    d1
    move.w  #55, d1
    move.l  #0, d2
    bsr     bmp_Draw
    rts
    
    
game_Win:
    lea     WinScreen, a1
    move.w  #212, d0
    move.w  #640, d1
    swap    d1
    move.w  #55, d1
    move.l  #0, d2
    bsr     bmp_Draw
    rts
    
game_Restart:
    move.l  a4, a0
    bsr     entity_ListClear
    jmp     restart


Score           dc.l    0
ZombieKillCount dc.b    0
ZombieWave      dc.b    0
Music           dc.b    'music.wav',0
                ; Longword alignment
                ds.l    0
InputFile1      INCBIN  './assets/peashooter.bmp',0
Zombie          INCBIN  './assets/zombie.bmp',0
Background      INCBIN  './assets/bg.bmp',0
UnmodifiedBG    INCBIN  './assets/bg.bmp',0
LoseScreen      INCBIN  './assets/lose.bmp',0
WinScreen       INCBIN  './assets/win.bmp',0

                ; Longword alignment
                ds.l    0
PlantList       ds.b    (PLANT_COUNT*ENTITY_SIZE)+ENTITY_HEADER_SIZE        ; Reserve space for plant entity list and header
ZombieList      ds.b    (ZOMBIE_COUNT*ENTITY_SIZE)+ENTITY_HEADER_SIZE       ; Reserve space for zombie entity list
ProjectileList  ds.b    (PROJECTILE_COUNT*ENTITY_SIZE)+ENTITY_HEADER_SIZE   ; Reserve space for projectile entity list

RowPositionArray    dc.w    $FB, $5B, $AB, $14B
ZombiesPerWave       dc.b    5, 8, 15    
    
ErrorText   dc.b    'An error was encountered',0
    END START






























*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
