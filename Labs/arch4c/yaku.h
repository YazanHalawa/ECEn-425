
/* YAK kernel #defines that the application program can modify for
 specific applications.
 (c) James Archibald, Brigham Young University, October 2002 */

#define MAXTASKS 6        /* number of user tasks to be defined */
#define MAXSEMS  4        /* number of semaphores to be defined */
#define FLAGBITS 0x0200        /* Default flag values: only IF set*/
#define IDLESTKSIZE 1024    /* stack size for idle task */
#define MAXQUEUES 1        /* number of queues to be defined */
#define INITIMRMASK 0x00    /* 0: interrupt on, 1: masked */