#include <stdio.h>
#include "mtk_c.h"

void dump() {
    printf("[DEBUG] dump current state\n");
    printf("curr_task = %d, next_task = %d\n", curr_task, next_task);
    printf("[DEBUG] dump ready queue\n");
    printf("ready queue: ");
    for (TASK_ID_TYPE id = ready; id != NULLTASKID; id = task_tab[id].next) {
        TCB_TYPE *cur = &task_tab[id];
        printf("%d(%d) -> ", id, (int) cur->task_addr);
    }
    printf("NULLTASKID\n");
    printf("[DEBUG] dump semaphore queue\n");
    for (int id = 0; id < NUMSEMAPHORE; id++) {
        SEMAPHORE_TYPE *sema = &semaphore[id];
        if (sema->task_list == NULLTASKID) continue;
        TASK_ID_TYPE task_id = sema->task_list;
        printf("semaphore #%d: ", id);
        do {
            printf("%d -> ", task_id);
            task_id = task_tab[task_id].next;
        } while (task_id != NULLTASKID);
        printf("NULLTASKID\n");
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
    dump();

    begin_sch();
}
