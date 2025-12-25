#include <stdio.h>
#include "mtk_c.h"

#define BOARD_W 8
#define BOARD_H 8
#define AT(x, y) ((x) + ((y) * BOARD_W))

typedef enum { EMPTY, WHITE, BLACK, } Cell;
Cell board[BOARD_W * BOARD_H];

// ボードを描画
void fdraw(FILE *com) {
    P(0);
    fprintf(com, "   ");
    for (int j = 0; j < BOARD_W; j++) {
        fprintf(com, "% 2d", j);
    }
    fprintf(com, "\n");
    for (int i = 0; i < BOARD_H; i++) {
        fprintf(com, "% 2d|", i);
        for (int j = 0; j < BOARD_W; j++) {
            switch (board[AT(j, i)]) {
                case EMPTY: fprintf(com, "  "); break;
                case WHITE: fprintf(com, " O"); break;
                case BLACK: fprintf(com, " X"); break;
            }
        }
        fprintf(com, "\n");
    }
    V(0);
}

// ボードにコマを置く。連続するコマの数を返す
// 負の値を返すときはエラー
int put(Cell c, int x, int y) {
    P(0);
    int dxs[] = {-1, 0, 1, 1};
    int dys[] = {-1, -1, -1, 0};
    if (x < 0 || BOARD_W <= x) return -1;
    if (y < 0 || BOARD_H <= y) return -1;
    if (board[AT(x, y)] != EMPTY) return -1;
    board[AT(x, y)] = c;
    int count_max = -1;
    for (int i = 0; i < 4; i++) {
        int dx = dxs[i], dy = dys[i];
        int count = 1;
        int nx = x + dx;
        int ny = y + dy;
        while ((0 <= nx && nx < BOARD_W) && (0 <= ny && ny < BOARD_H) && (board[AT(nx, ny)] == c)) {
            count++;
            nx += dx;
            ny += dy;
        }
        dx = -dx, dy = -dy;
        nx = x + dx;
        ny = y + dy;
        while ((0 <= nx && nx < BOARD_W) && (0 <= ny && ny < BOARD_H) && (board[AT(nx, ny)] == c)) {
            count++;
            nx += dx;
            ny += dy;
        }
        count_max = count_max < count ? count : count_max;
    }
    V(0);
    return count_max;
}

void user_input(FILE *in, FILE *out, int *x, int *y) {
    fprintf(out, "please input (x y) => ");
    fscanf(in, "%d %d", x, y);
}

void hikiwake() {
    fprintf(com0out, "DRAW\n");
    fprintf(com1out, "DRAW\n");
    while (1);
}

int turn = 0;

void task1() {
    int x, y, n;
    while (1) {
        fdraw(com0out);
        do {
            user_input(com0in, com0out, &x, &y);
            P(1);
            if (turn % 2 != 0) {
                fprintf(com0out, "please wait...\n");
                n = -1;
            }
            else n = put(BLACK, x, y);
            V(1);
        } while (n < 0);
        fprintf(com0out, "n: %d\n", n);
        if (n == 5) {
            fprintf(com0out, "WIN\n");
            fprintf(com1out, "LOSE\n");
            while (1);
        }
        fdraw(com0out);
        if (++turn == BOARD_W * BOARD_H) hikiwake();
    }	
}

void task2() {
    int x, y, n;
    while (1) {
        fdraw(com1out);
        do {
            user_input(com1in, com1out, &x, &y);
            P(1);
            if (turn % 2 != 1) {
                fprintf(com1out, "please wait...\n");
                n = -1;
            }
            else n = put(WHITE, x, y);
            V(1);
        } while (n < 0);
         fprintf(com1out, "n: %d\n", n);
        if (n == 5) {
            fprintf(com1out, "WIN\n");
            fprintf(com0out, "LOSE\n");
            while (1);
        }
        fdraw(com1out);
        if (++turn == BOARD_W * BOARD_H) hikiwake();
    }	
}

int main() {
    printf("BOOTING\n");
    fd_mapping();
    printf("[OK] fd_mapping\n");
    init_kernel();
    printf("[OK] init_kernel\n");

    set_task(task1);
    set_task(task2);
    
    begin_sch();
}
