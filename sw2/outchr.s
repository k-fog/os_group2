.include "defs.s"
.global outbyte

|outbyte(ch, c)	
.text
.even
outbyte:
	# link.w %FP, #0
	movem.l %D1-%D3/%A0, -(%SP)
	move.l %SP, %A0
	add.l #20, %A0 |20=退避レジスタ数*4 + 4
outbyte_retry:
	move.l #SYSCALL_NUM_PUTSTRING, %D0
	move.l (%A0), %D1 |ch代入
	#move.l #0, %D1
	# move.l %FP, %D2
	# addi.l #11, %D2
	move.l %SP, %D2
	addi.l #27, %D2 |27 = 20 + 4(ここがcの末尾) + 3
	move.l #1, %D3
	trap #0
	cmpi.l #0, %D0
	beq outbyte_retry
	movem.l (%SP)+, %D1-%D3/%A0
	# unlk %FP
	rts
