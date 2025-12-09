#include <stdio.h>
#include "mtk_c.h"

void dump_queue() {
    printf("[DEBUG] dump ready queue\n");
    for (TASK_ID_TYPE id = ready; id != NULLTASKID; id = task_tab[id].next) {
        TCB_TYPE *cur = &task_tab[id];
        printf("[DEBUG] task id = %d, task_addr = %d\n", id, (int) cur->task_addr);
    }
}

void task1() {
    printf("task1 started\n");
    P(1);
    while (1) {
        printf("task1\n");
        V(2);
        P(1);
    }
}

void task2() {
    printf("task2 started\n");
    V(1);
    P(2);
    while (1) {
        printf("task2\n");
        V(1);
        P(2);
    }
}

int main() {
    printf("BOOTING\n");
    init_kernel();
    printf("[OK] init_kernel\n");

    semaphore[1].count = 0; 
    semaphore[2].count = 0;
    
    set_task(task1);
    set_task(task2);

    if (DEBUG) printf("[DEBUG] sizeof TCB_TYPE = %ld\n", sizeof(TCB_TYPE));
    if (DEBUG) printf("[DEBUG] ready = %d\n", ready);
    dump_queue();

    begin_sch();
}
