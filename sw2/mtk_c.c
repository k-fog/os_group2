#include "mtk_c.h"

int curr_task;
int new_task;
int next_task
int ready;
TCB_TYPE task_tab[NUMTASK + 1];
STACK_TYPE stacks[NUMTASK];
SEMAPHORE_TYPE semaphore[NUMSEMAPHORE];

void init_kernel() {
    for (int i = 0; i < NUMTASK; i++) {
        int task_id = i + 1;
        task_tab[task_id].stack_ptr = (void *)stacks[i].ustack;
        task_tab[task_id].status = TASK_UNDEF;
    }
}


