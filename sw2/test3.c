#include <stdio.h>
#include "mtk_c.h"

#define DRAW_SEMA 0
#define UPDATE_SEMA 1
#define TASK_SEMA 2

#define BOARD_W 40
#define BOARD_H 20
#define BAR_W    5

#define DRAW_INTERVAL 100
#define UPDATE_INTERVAL 1000

int ball_x, ball_y;
int ball_dx, ball_dy;
int bar1, bar2;

void setup() {
    ball_x = 0;
    ball_y = 0;
    ball_dx = 1;
    ball_dy = 1;
    bar1 = 15;
    bar2 = 15;
}

void update() {
    P(UPDATE_SEMA);
    ball_x += ball_dx;
    ball_y += ball_dy;
    if (ball_x < 0) {
        ball_x = 0;
        ball_dx *= -1;
    } else if (BOARD_W <= ball_x) {
        ball_x = BOARD_W - 1;
        ball_dx *= -1;
    }
    if (ball_y < 0) {
        ball_y = 0;
        ball_dy *= -1;
    } else if (BOARD_H <= ball_y) {
        ball_y = BOARD_H - 1;
        ball_dy *= -1;
    }
    V(UPDATE_SEMA);
}

void fdraw(FILE *com) {
    P(DRAW_SEMA);
    P(UPDATE_SEMA);
    for (int i = 0; i < BOARD_H; i++) {
        if (i == BOARD_H - 1) {
            for (int j = 0; j < BOARD_W; j++) {
                if (j < bar1) fprintf(com, " ");
                else if (bar1 <= j && j < bar1 + BAR_W) fprintf(com, "#");
                else {
                    fprintf(com, "\n");
                    break;
                }
            }
        }
        else if (ball_y != i) fprintf(com, "\n");
        else {
            for (int j = 0; j < BOARD_W; j++) {
                if (ball_x == j) fprintf(com, "O");
                else fprintf(com, " ");
            }
            fprintf(com, "\n");
        }
    }
    V(UPDATE_SEMA);
    V(DRAW_SEMA);
}

void task1() {
    int frame = 0;
    while (1) {
        if (frame++ % DRAW_INTERVAL == 0) fdraw(com0out);
    }	
}

void task2() {
    int frame = 0;
    while (1) {
        if (frame++ % DRAW_INTERVAL == 0) fdraw(com1out);
    }	
}

void task3() {
    int frame = 0;
    while (1) {
        if (frame++ % UPDATE_INTERVAL == 0) update();
    }
}

void task4() {
    while (1) {
        char input = inbyte(0);
        if (input == 'a') bar1--;
        else if (input == 'd') bar1++;
        if (bar1 + BAR_W <= 0) bar1 = BOARD_W - BAR_W;
        else if (BOARD_W < bar1) bar1 = 0;
    }
}

void task5() {
    while (1) {
        char input = inbyte(1);
        if (input == 'a') bar2--;
        else if (input == 'd') bar2++;
        if (bar2 + BAR_W <= 0) bar2 = BOARD_W - BAR_W;
        else if (BOARD_W < bar2) bar2 = 0;
    }
}

int main() {
    printf("BOOTING\n");
    fd_mapping();
    printf("[OK] fd_mapping\n");
    init_kernel();
    printf("[OK] init_kernel\n");

    setup();

    set_task(task1);
    set_task(task2);
    set_task(task3);
    set_task(task4);
    set_task(task5);
    
    begin_sch();
}
