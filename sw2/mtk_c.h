#define NULLTASKID    0 // キューの終端
#define NUMTASK       5 // 最大タスク数
#define STKSIZE    1024 // スタックサイズ

#define TASK_UNDEF    0
#define TASK_CURRENT  1
#define TASK_FINISHED 2

typedef int TASK_ID_TYPE;

typedef struct {
    int count;
    int nst;
    TASK_ID_TYPE task_list;
} SEMAPHORE_TYPE;

typedef struct {
    void (*task_addr)();
    void *stack_ptr;
    int priority;
    int status;
    TASK_ID_TYPE next;
} TCB_TYPE;
extern TCB_TYPE task_tab[NUMTASK + 1];

typedef struct {
    char ustack[STKSIZE];
    char sstack[STKSIZE];
} STACK_TYPE;
extern STACK_TYPE stacks[NUMTASK];

extern int curr_task;
extern int new_task;
extern int next_task
extern int ready;
extern SEMAPHORE_TYPE semaphore[NUMSEMAPHORE];

/* multi task */
void init_kernel();
void set_task();
void init_stack();
void begin_sch();
void addq();
void removeq();
void sched();

/* semaphore */
void sleep();
void wakeup();
void p_body();
void v_body();
