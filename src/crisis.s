/*
 * Entry point for crisis
 * Authors Stefan Stancu, Josh Hartmann
*/

.global _start
_start:
    call _init

    game_loop:
        
        call update
        call _draw

        br game_loop

update:

    ret
