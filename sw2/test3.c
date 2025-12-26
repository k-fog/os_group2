#include <stdio.h>
#include <stdbool.h>
#include "mtk_c.h"

#define DRAW_SEMA 0
#define UPDATE_SEMA 1
#define TASK_SEMA 2

#define BOARD_W 40
#define BOARD_H 20
#define BAR_W    5

#define DRAW_INTERVAL 1
#define UPDATE_INTERVAL 1500

enum {GAME, RESULT} game_state;
#define GAME_END_POINT 3

int ball_x, ball_y;
int ball_prev_x[2];
int ball_prev_y[2];
int prev_top = 0;
int ball_dx, ball_dy;
int bar1, bar2;
int score1, score2;   // プレイヤ1/2のスコア
int update_frame = 0;

void reset_ball(bool toward_top) {
    ball_x = BOARD_W / 2;
    ball_y = BOARD_H / 2;
    ball_dx = update_frame % 2 == 0 ? -1 : 1;
    ball_dy = toward_top ? -1 : 1;
    for (int i = 0; i < 2; i++) {
        ball_prev_x[i] = -1;
        ball_prev_y[i] = -1;
    }
}

void setup() {
    game_state = GAME;
    score1 = 0;
    score2 = 0;

    reset_ball(0);   // 最初はプレイヤ1側へ
    bar1 = 15;       // 下（プレイヤ1）
    bar2 = 15;       // 上（プレイヤ2）
    update_frame = 0;
}

void update() {
    P(UPDATE_SEMA);

    ball_prev_x[prev_top] = ball_x;
    ball_prev_y[prev_top] = ball_y;
    prev_top = (prev_top + 1) % 2;
    ball_x += ball_dx;
    ball_y += ball_dy;

    // 左右の壁で反射
    if (ball_x < 0) {
        ball_x = 0;
        ball_dx *= -1;
    } else if (BOARD_W <= ball_x) {
        ball_x = BOARD_W - 1;
        ball_dx *= -1;
    }

    // 上側（プレイヤ2側）
    if (ball_dy < 0 && ball_y <= 0) {
        if (bar2 <= ball_x && ball_x < bar2 + BAR_W) {
            ball_y = 0;
            ball_dy = 1;
        } else {
            // P1の得点
            score1++;
            if (score1 == GAME_END_POINT) game_state = RESULT;
            reset_ball(true);   // 次は上方向へ
        }
    }

    // 下側（プレイヤ1側）
    if (ball_dy > 0 && ball_y >= BOARD_H - 1) {
        if (bar1 <= ball_x && ball_x < bar1 + BAR_W) {
            ball_y = BOARD_H - 1;
            ball_dy = -1;
        } else {
            // P2の得点
            score2++;
            if (score2 == GAME_END_POINT) game_state = RESULT;
            reset_ball(false);   // 次は下方向へ
        }
    }

    V(UPDATE_SEMA);
}

// player: 1 = プレイヤ1画面(com0out), 2 = プレイヤ2画面(com1out)
void fdraw(FILE *com, int player) {
    P(DRAW_SEMA);
    P(UPDATE_SEMA);

    // 画面クリア
    fprintf(com, "\033[2J\033[H");

    int my_score, enemy_score;
    if (player == 1) {
        my_score = score1;
        enemy_score = score2;
    } else {
        my_score = score2;
        enemy_score = score1;
    }
    fprintf(com, "You: %d   Enemy: %d\n", my_score, enemy_score);

    for (int screen_y = 0; screen_y < BOARD_H; screen_y++) {
        // プレイヤ2画面では上下反転
        int world_y;
        if (player == 1) {
            world_y = screen_y;                   // そのまま
        } else {
            world_y = BOARD_H - 1 - screen_y;     // 上下反転
        }

        for (int x = 0; x < BOARD_W; x++) {
            char ch = ' ';

            // 上バー（プレイヤ2）は world_y == 0
            if (world_y == 0 && bar2 <= x && x < bar2 + BAR_W) {
                ch = '#';
            }
            // 下バー（プレイヤ1）は world_y == BOARD_H - 1
            if (world_y == BOARD_H - 1 && bar1 <= x && x < bar1 + BAR_W) {
                ch = '#';
            }
            // 残像
            for (int i = 0; i < 2; i++) {
                if (ball_prev_x[i] == x && ball_prev_y[i] == world_y) {
                    ch = '.';
                }
            }
            // ボールは最優先
            if (ball_x == x && ball_y == world_y) {
                ch = 'O';
            }

            fputc(ch, com);
        }
        fputc('\n', com);
    }

    V(UPDATE_SEMA);
    V(DRAW_SEMA);
}

void fdraw_result(FILE *com, int player) {
    fprintf(com, "\033[2J\033[H");
    int my_score, enemy_score;
    if (player == 1) {
        my_score = score1;
        enemy_score = score2;
    } else {
        my_score = score2;
        enemy_score = score1;
    }
    fprintf(com, "You: %d   Enemy: %d\n", my_score, enemy_score);
    if (my_score > enemy_score) fprintf(com, "You Win\n");
    else fprintf(com, "You Lose\n");
    while(1); // 無限ループ
}

void task1() {
    int frame = 0;
    while (1) {
        if (frame++ % DRAW_INTERVAL == 0) {
            if (game_state == GAME) fdraw(com0out, 1);  // P1画面
            else fdraw_result(com0out, 1);
        }
    }
}

void task2() {
    int frame = 0;
    while (1) {
        if (frame++ % DRAW_INTERVAL == 0) {
            if (game_state == GAME) fdraw(com1out, 2);  // P2画面 (上下反転)
            else fdraw_result(com1out, 2);
        }
    }
}

void task3() {
    while (1) {
        if (update_frame++ % UPDATE_INTERVAL == 0) update();
    }
}

void task4() {
    // プレイヤ1（下）の操作：inbyte(0)
    while (1) {
        char input = inbyte(0);
        if (input == 'a') bar1--;
        else if (input == 'd') bar1++;

        if (bar1 + BAR_W <= 0) bar1 = BOARD_W - BAR_W;
        else if (BOARD_W < bar1) bar1 = 0;
    }
}

void task5() {
    // プレイヤ2（上）の操作：inbyte(1)
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

