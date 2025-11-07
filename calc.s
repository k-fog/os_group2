.section .text

.equ BUF_SIZE, 256
.equ RESULT_BUF_SIZE, 16
.equ STACK_SIZE, 16

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
 * //TODO %D2.L: buffer size
 * %D0.L: return value; data count
 */
_LTOSTR:
/*
    int val = D1
    int count = D2
    if (val < 0) {
        *A1++ = '-';
        val = -val;
    }
    int div = 1;
    while (10 <= val / div) div *= 10;
    while (0 < div && 0 < count) {
        int tmp = val / div;
        tmp += '0';
        *A1++ = tmp;
        val %= div;
        div /= 10;
        count--;
    }
*/
    movem.l %D1-%D4/%A1-%A2, -(%SP)

    | %D1(val), %D2(count), %A2(buf_head)
    movea.l %A1, %A2
    cmpi.l #0, %D1   | check val < 0
    bge _LTOSTR_SKIP_REVERSE
    move.b #'-', (%A1)+
    neg.l %D1
_LTOSTR_SKIP_REVERSE:

    move.w #1, %D3   | %D3.W(div) = 1
_LTOSTR_WHILE_0:
    move.l %D1, %D4  | %D4(val_tmp) = val
    divu %D3, %D4    | val_tmp /= div
    cmpi.w #10, %D4  | check 10 <= val_tmp
    bcs _LTOSTR_BREAK_0
    mulu #10, %D3
    bra _LTOSTR_WHILE_0
_LTOSTR_BREAK_0:
_LTOSTR_WHILE_1:
    cmpi.w #0, %D3   | check 0 < div
    bls _LTOSTR_BREAK_1
    move.l %D1, %D4  | %D4(tmp) = val
    divu %D3, %D4    | tmp /= div
    addi.b #'0', %D4 | tmp += '0'
    move.b %D4, (%A1)+
    lsr.l #8, %D4
    lsr.l #8, %D4    | tmp = val % div
    move.l %D4, %D1  | val = tmp = val % div
    divu #10, %D3    | div /= 10
    bra _LTOSTR_WHILE_1
_LTOSTR_BREAK_1:
    clr.l %D0
    suba.l %A2, %A1  | %A1 -= %A2(buf_head)
    move.l %A1, %D0
    movem.l (%SP)+, %D1-%D4/%A1-%A2
    rts


/*
 * _SKIP_SPACE
 * %A1: string
 */
_SKIP_SPACE:
    cmpi.b #' ', (%A1)
    bne _SKIP_SPACE_END
    adda.l #1, %A1
    bra _SKIP_SPACE
_SKIP_SPACE_END:
    rts


/*
 * _PUSH: push to stack
 * %D1.L: data to push
 */
_PUSH:
    movem.l %D2/%A1, -(%SP)
    lea.l STACK, %A1
    move.l (STACK_TOP), %D2
    mulu #4, %D2
    adda.l %D2, %A1
    move.l %D1, (%A1)
    addi.l #1, (STACK_TOP)
    movem.l (%SP)+, %D2/%A1
    rts


/*
 * _POP: pop from stack
 * %D0.L: data
 */
_POP:
    movem.l %D2/%A1, -(%SP)
    lea.l STACK, %A1
    subi.l #1, (STACK_TOP)
    move.l (STACK_TOP), %D2
    mulu #4, %D2
    adda.l %D2, %A1
    move.l (%A1), %D0
    movem.l (%SP)+, %D2/%A1
    rts


_RESET_STACK:
    move.l #0, (STACK_TOP)
    rts


/*
 * calc_main: main routine
 */
CALC_MAIN:
    lea.l PROMPT, %a1
    move.l #2, %d1
    jsr _PRINT           | print PROMPT "> "

    lea.l INPUT_BUF, %a1 | %a1 = buffer head
READ_LOOP:
    jsr _READ_ONE_CHAR
    cmpi.l #0, %d0       | if <num of read char> == 0 then loop
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

    jsr _RESET_STACK
    bra CALC_MAIN


/*
 * EVAL: evaluate source code
 * %A1: address of source code
 * %D0: return value
 */
EVAL:
/*
    while (*A1 != '\r') {
        skip_space(A1)
        if (*A1 == '+') {
            int x = pop();
            int y = pop();
            int ans = x + y;
            push(ans);
        } else if (*A1 == '-') {
            int x = pop();
            int y = pop();
            int ans = x - y;
            push(ans);
        // * /
        } else {
            D0 = strtol(A1);
            push(D0);
        }
    }
    D0 = pop();
*/
    movem.l %D1-%D2/%A1, -(%SP)
EVAL_WHILE:
    jsr _SKIP_SPACE
    cmpi.b #'\r', (%A1)
    beq EVAL_WHILE_END
    cmpi.b #'+', (%A1)
    beq EVAL_PLUS
    cmpi.b #'-', (%A1)
    beq EVAL_MINUS
    cmpi.b #'*', (%A1)
    beq EVAL_MUL
    cmpi.b #'/', (%A1)
    beq EVAL_DIV
    cmpi.b #'0', (%A1)
    bcs EVAL_END | error
    cmpi.b #'9', (%A1)
    bhi EVAL_END | error
    bra EVAL_VAL
    | TODO: minus value
EVAL_PLUS:
    adda.l #1, %A1
    jsr _POP
    move.l %D0, %D2
    jsr _POP
    move.l %D0, %D1
    add.l %D2, %D1
    jsr _PUSH
    bra EVAL_WHILE
EVAL_MINUS:
    adda.l #1, %A1
    jsr _POP
    move.l %D0, %D2
    jsr _POP
    move.l %D0, %D1
    sub.l %D2, %D1
    jsr _PUSH
    bra EVAL_WHILE
EVAL_MUL:
    adda.l #1, %A1
    jsr _POP
    move.l %D0, %D2
    jsr _POP
    move.l %D0, %D1
    muls %D2, %D1
    jsr _PUSH
    bra EVAL_WHILE
EVAL_DIV:
    adda.l #1, %A1
    jsr _POP
    move.l %D0, %D2
    jsr _POP
    move.l %D0, %D1
    divs %D2, %D1
    andi.l #0x0000FFFF, %D1
    jsr _PUSH
    bra EVAL_WHILE
EVAL_VAL:
    jsr _STRTOL
    move.l %D0, %D1
    jsr _PUSH
    movea.l %A0, %A1
    bra EVAL_WHILE
EVAL_WHILE_END:
    jsr _POP
EVAL_END:
    movem.l (%SP)+, %D1-%D2/%A1
    rts


/*
 * PRINT: print the result
 * %A1: end of source code
 * %D1: result
 */
PRINT:
    movem.l %D0-%D3/%A0-%A2, -(%SP)
    move.l %D1, %D3  | %D3 = result
    jsr _NEWLINE

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
STACK_TOP:
    .dc.l 0
    .even


.section .bss
INPUT_BUF:
    .ds.b BUF_SIZE
    .even
RESULT_BUF:
    .ds.b RESULT_BUF_SIZE
    .even
STACK:
    .ds.l STACK_SIZE
    .even
