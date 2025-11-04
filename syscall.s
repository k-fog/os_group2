.equ SYSCALL_NUM_GETSTRING,   1
.equ SYSCALL_NUM_PUTSTRING,   2
.equ SYSCALL_NUM_RESET_TIMER, 3
.equ SYSCALL_NUM_SET_TIMER,   4

/*
 * syscall_handler
 * %d0: syscall number
 * %dx: syscall argument
 */
syscall_handler:
    movem.l %D1-%D7/%A0-%A6, -(%SP)

    cmpi.l #SYSCALL_NUM_GETSTRING, %D0
    jsr GETSTRING
    bra END_SYSCALL_HNDR

    cmpi.l #SYSCALL_NUM_PUTSTRING, %D0
    jsr PUTSTRING
    bra END_SYSCALL_HNDR

    cmpi.l #SYSCALL_NUM_RESET_TIMER, %D0
    jsr RESET_TIMER
    bra END_SYSCALL_HNDR

    cmpi.l #SYSCALL_NUM_SET_TIMER, %D0
    jsr SET_TIMER
    bra END_SYSCALL_HNDR
END_SYSCALL_HNDR:
    movem.l (%SP)+, %D1-%D7/%A0-%A6
    rte
