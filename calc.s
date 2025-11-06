.section .text

.equ BUF_SIZE, 256
.equ RESULT_BUF_SIZE, 16

/*
 * _READ_ONE_CHAR
 * %A1: address of the buffer.
 * %D0: return value. number of read char; 0, 1
 */
_READ_ONE_CHAR:
    movem.l %D1-%D3, -(%SP)
    move.l #SYSCALL_NUM_GETSTRING, %D0
    move.l #0, %D1
    move.l %A1, %D2
    move.l #1, %D3
    trap #0
    movem.l (%SP)+, %D1-%D3
    rts

/*
 * _PRINT_ONE_CHAR
 * %A1: address of the buffer.
 */
_PRINT_ONE_CHAR:
    movem.l %D0-%D3, -(%SP)
    move.l #SYSCALL_NUM_PUTSTRING, %D0
    move.l #0, %D1
    move.l %A1, %D2
    move.l #1, %D3
    trap #0
    movem.l (%SP)+, %D0-%D3
    rts

/*
 * _PRINT
 * %A1: address of the buffer.
 * %D1: size
 */
_PRINT:
    movem.l %D0-%D3, -(%SP)
    move.l %D1, %D3
    move.l #SYSCALL_NUM_PUTSTRING, %D0
    move.l #0, %D1
    move.l %A1, %D2
    trap #0
    movem.l (%SP)+, %D0-%D3
    rts

/*
 * _NEWLINE
 */
_NEWLINE:
    movem.l %D0-%D3, -(%SP)
    move.l #SYSCALL_NUM_PUTSTRING, %D0
    move.l #0, %D1
    move.l #CRLF, %D2
    move.l #2, %D3
    trap #0
    movem.l (%SP)+, %D0-%D3
    rts

/*
 * CALC_MAIN: main routine
 */
CALC_MAIN:
    lea.l PROMPT, %A1
    move.l #2, %D1
    jsr _PRINT           | print prompt "> "

    lea.l INPUT_BUF, %A1 | %A1 = buffer head
READ_LOOP:
    jsr _READ_ONE_CHAR
    cmpi.l #0, %D0       | if <num of read char> == 0 then loop
    beq READ_LOOP

    move.b (%A1), %D0
    cmpi.b #'\r', %D0
    beq READ_LOOP_END    | if <read char> == '\r' then break

    jsr _PRINT_ONE_CHAR
    addq.l #1, %A1
    bra READ_LOOP

READ_LOOP_END:
    jsr EVAL   | -> RESULT
    jsr PRINT  | -> output
    bra CALC_MAIN


/*
 * _STRTOL: string to integer (long)
 * %A1: address of string
 * %D0.L: integer
 * %A0: end pointer
 */
_STRTOL:
/*
    int D0 = 0;
    while('0' <= *src && *src <= '9') {
        D0 *= 10;
        D0 += *src - '0';
        src++;
    }
*/
    movem.l %D1-%D2, -(%SP)

    clr.l %D0
    move.l #10, %D2
_STRTOL_WHILE:
    move.b (%A1)+, %D1 | %D1 = *src
    cmpi.b #'0', %D1
    bcs _STRTOL_END
    cmpi.b #'9', %D1
    bhi _STRTOL_END
    mulu.w %D2, %D0  | %D0 *= 10
    subi.b #'0', %D1 | %D1 -= '0'
    add.l %D1, %D0
    bra _STRTOL_WHILE
_STRTOL_END:
    movem.l (%SP)+, %D1-%D2
    rts

_LTOSTR:

/*
 * EVAL: evaluate source code
 * %A1: address of source code
 * %D0: return value
 */
EVAL:
    move.b #'0', RESULT
    rts

/*
 * PRINT: print the result
 * %A1: source code
 * %D0: result
 */
PRINT:
    jsr _NEWLINE
    move.l %A1, %D1
    subi.l #INPUT_BUF, %D1
    lea.l INPUT_BUF, %A1
    jsr _PRINT           | print source code
    lea.l EQUAL, %A1
    move.l #3, %D1
    jsr _PRINT           | print equal " = "
    lea.l RESULT, %A1
    move.l #1, %D1
    jsr _PRINT           | print result
    jsr _NEWLINE
    rts

.section .data
PROMPT:
    .ascii "> "
    .even
EQUAL:
    .ascii " = "
    .even
CRLF:
    .ascii "\r\n"
    .even

.section .bss
INPUT_BUF:
    .ds.b BUF_SIZE
    .even
RESULT_BUF:
    .ds.b RESULT_BUF_SIZE
    .even
