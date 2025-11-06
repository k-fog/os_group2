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
    lea.l INPUT_BUF, %A1  | %A1 = buffer head
    jsr EVAL  | -> RESULT
    move.l %D0, %D1
    movea.l %A0, %A1
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
    movem.l %D1-%D2/%A1, -(%SP)

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
    movea.l %A1, %A0
    movem.l (%SP)+, %D1-%D2/%A1
    rts

/*
 * _LTOSTR: integer to string
 * %A1: address of buffer
 * %D1.L: integer
 * %D2.L: buffer size
 * %D0.L: return value; data count
 */
_LTOSTR:
    movem.l %D1/%A1, -(%SP)

    | tmp
    addi.b #'0', %D1
    move.b %D1, (%A1)
    moveq.l #1, %D0

    movem.l (%SP)+, %D1/%A1
    rts

/*
 * EVAL: evaluate source code
 * %A1: address of source code
 * %D0: return value
 */
EVAL:
    jsr _STRTOL
    rts

/*
 * PRINT: print the result
 * %A1: end of source code
 * %D1: result
 */
PRINT:
    movem.l %D0-%D3/%A0-%A2, -(%SP)
    movea.l %A1, %A2 | %A2 = end
    move.l %D1, %D3  | %D3 = result
    jsr _NEWLINE

    /* print "(" */
    lea.l PAREN_L, %A1
    move.l #1, %D1
    jsr _PRINT

    /* print source code */
    move.l %A2, %D1
    subi.l #INPUT_BUF+1, %D1
    lea.l INPUT_BUF, %A1
    jsr _PRINT

    /* print ")" */
    lea.l PAREN_R, %A1
    move.l #1, %D1
    jsr _PRINT

    /* print equal " = " */
    lea.l EQUAL, %A1
    move.l #3, %D1
    jsr _PRINT

    /* print the result */
    lea.l RESULT_BUF, %A1
    move.l %D3, %D1
    move.l #RESULT_BUF_SIZE, %D2
    jsr _LTOSTR
    move.l %D0, %D1
    jsr _PRINT
    jsr _NEWLINE
    movem.l (%SP)+, %D0-%D3/%A0-%A2
    rts

.section .data
PROMPT:
    .ascii "> "
    .even
EQUAL:
    .ascii " = "
    .even
PAREN_L:
    .ascii "("
    .even
PAREN_R:
    .ascii ")"
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
