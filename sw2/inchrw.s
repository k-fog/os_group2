.include "defs.s"
.global inbyte

|inbyte(ch)	
.text
.even
inbyte:
	|chはスタックに積まれている
	link.w %FP, #-4
	movem.l %D1-%D3/%A0, -(%SP)
	move.l %SP, %A0
	add.l #20, %A0 |20=退避レジスタ数*4 + 4
inbyte_retry:
    move.l #SYSCALL_NUM_GETSTRING, %D0
    move.l (%A0), %D1 |ch代入
    move.l %FP, %D2
    subi.l #4, %D2
    move.l #1, %D3
    trap #0
    cmpi.l #1, %D0
    bne inbyte_retry
    clr.l %D0
    move.b -4(%FP), %D0
    movem.l (%SP)+, %D1-%D3/%A0
    unlk %FP
    rts
