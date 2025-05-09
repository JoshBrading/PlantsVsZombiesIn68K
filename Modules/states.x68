STATE_START     EQU     0
STATE_PLAY      EQU     1
STATE_PAUSE     EQU     2
STATE_LOSE      EQU     3
STATE_WIN       EQU     4
STATE_RESTART   EQU     5

*---
* Set game state
*
* d0 - State to set
*---
state_Set:
    move.l  d0, STATE
    rts
*---
* Set game state to start
*---
state_SetStart:
    move.l  #STATE_START, STATE    
    rts
    
*---
* Set game state to play
*---
state_SetPlay:
    move.l  #STATE_PLAY, STATE
    rts 
    
*---
* Set game state to pause
*---
state_SetPause:
    move.l  #STATE_PAUSE, STATE
    rts
    
*---
* Set game state to lose
*---
state_SetLose:
    move.l  #STATE_LOSE, STATE
    rts
    
*---
* Set game state to win
*---
state_SetWin:
    move.l  #STATE_WIN, STATE
    rts    
    
*---
* Set game state to restart
*---
state_SetRestart:
    move.l  #STATE_RESTART, STATE
    rts    
    
STATE   dc.l    0
*~Font name~Courier New~
*~Font size~16~
*~Tab type~1~
*~Tab size~4~
