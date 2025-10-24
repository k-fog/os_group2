/* レジスタ定義 */
.equ REGBASE, 0xfff000 | DMAP を使用．
.equ IOBASE, 0x00d00000

/* 割り込み関係のレジスタ*/
.equ IVR, REGBASE+0x300 | 割り込みベクタレジスタ
.equ IMR, REGBASE+0x304 | 割り込みマスクレジスタ
.equ ISR, REGBASE+0x30c | 割り込みステータスレジスタ
.equ IPR, REGBASE+0x310 | 割り込みペンディングレジスタ

/* タイマ関係のレジスタ */
.equ TCTL1, REGBASE+0x600  | タイマ１コントロールレジスタ
.equ TPRER1, REGBASE+0x602 | タイマ１プリスケーラレジスタ
.equ TCMP1, REGBASE+0x604  | タイマ１コンペアレジスタ
.equ TCN1, REGBASE+0x608   | タイマ１カウンタレジスタ
.equ TSTAT1, REGBASE+0x60a | タイマ１ステータスレジスタ

/* UART1（送受信）関係のレジスタ */
.equ USTCNT1, REGBASE+0x900 | UART1 ステータス/コントロールレジスタ
.equ UBAUD1, REGBASE+0x902  | UART1 ボーコントロールレジスタ
.equ URX1, REGBASE+0x904    | UART1 受信レジスタ
.equ UTX1, REGBASE+0x906    | UART1 送信レジスタ

/* LED */
.equ LED7, IOBASE+0x000002f | ボード搭載の LED 用レジスタ
.equ LED6, IOBASE+0x000002d | 使用法については付録 A.4.3.1
.equ LED5, IOBASE+0x000002b
.equ LED4, IOBASE+0x0000029
.equ LED3, IOBASE+0x000003f
.equ LED2, IOBASE+0x000003d
.equ LED1, IOBASE+0x000003b
.equ LED0, IOBASE+0x0000039

/* スタック */
.section .bss
.even
SYS_STK:.ds.b 0x4000
.even
SYS_STK_TOP: | システムスタック領域の最後尾

/* 初期化 */
.section .text
.even
boot:
    move.w #0x2700, %SR     | 割り込み禁止
    lea.l SYS_STK_TOP, %SP  | スタックポインタの設定

    /* 割り込みコントローラの初期化 */
    move.b #0x40, IVR       | ユーザ割り込みベクタ番号を0x40+levelに設定
    move.l #0x00ffffff, IMR | 全割り込みマスク

    move.l #uart1_interrupt, 0x110 | UART1の割り込みベクタを登録
    move.l #tmr1_interrupt, 0x118  | TIMER1の割り込みベクタを登録

    /* 送受信 (UART1) 関係の初期化 (割り込みレベルは 4 に固定されている) */
    move.w #0x0000, USTCNT1 | リセット
    * move.w #0xe100, USTCNT1 | 送受信可能, パリティなし, 1 stop, 8 bit, 送受割り込み禁止
    move.w #0xe108, USTCNT1 | 受信可能
    move.w #0x0038, UBAUD1  | baud rate = 230400 bps

    /* タイマ関係の初期化 (割り込みレベルは 6 に固定されている) */
    move.w #0x0004, TCTL1   | restart, 割り込み不可,
    | システムクロックの 1/16 を単位として計時，
    | タイマ使用停止

    move.l #0xff3ffb, IMR | UART1の割り込みを許可
    move.w #0x2000,%SR    | スーパーバイザモード・走行レベルは0
    bra MAIN

/* 現段階での初期化ルーチンの正常動作を確認するため，最後に ’a’ を
 * 送信レジスタ UTX1 に書き込む．’a’ が出力されれば，OK. */
.section .text
.even
MAIN:
    move.w #0x0800+'a', UTX1 | 0x0800 を足す理由については付録参照
LOOP:
    bra LOOP

/* 割り込みハンドラ */
uart1_interrupt:
    movem.l %D0-%D7/%A0-%A6,-(%SP)  | 使用するレジスタをスタックに保存
    move.w URX1, %D0                | 受信データをD0に格納
    ori #0x0800, %D0                | 送信データを用意
    addi #1, %D0
    move.w %D0, UTX1                | 送信
    movem.l (%SP)+, %D0-%D7/%A0-%A6 | レジスタを復帰
    rte

tmr1_interrupt:
    movem.l %D0-%D7/%A0-%A6,-(%SP)  | 使用するレジスタをスタックに保存
    /* TODO ここで割り込みの原因となった事象に対処する処理を行う． */
    movem.l (%SP)+, %D0-%D7/%A0-%A6 | レジスタを復帰
    rte
