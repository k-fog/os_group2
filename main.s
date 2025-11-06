****************************************************************
*** プログラム領域
****************************************************************
.section .text
.even
MAIN:
    ** 走行モードとレベルの設定 (「ユーザモード」への移行処理)
    move.w #0x0000, %SR   | USER MODE, LEVEL 0
    lea.l USR_STK_TOP,%SP | user stack の設定

    bra CALC_MAIN
.include "calc.s"

.section .bss
USR_STK:
    .ds.b 0x4000 | ユーザスタック領域
    .even
USR_STK_TOP:     | ユーザスタック領域の最後尾
