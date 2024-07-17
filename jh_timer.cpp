#include "jh_timer.h"

JH_timer timer_init(int N)
{
    JH_timer timer;
    timer.count = N;
    timer.timers = (Timer*)malloc(N * sizeof(Timer));
    for (int i = 0; i < N; i++)
    {
        strcpy(timer.timers[i].name, "unnamed");
        timer.timers[i].elapsed_time = 0;
        timer.timers[i].is_running = 0;
    }
    return timer;
}

void setTimerName(JH_timer* timer, int idx, const char* name) {
    if (idx >= 0 && idx < timer->count) {
        strncpy(timer->timers[idx].name, name, MAX_TIMER_NAME - 1);
        timer->timers[idx].name[MAX_TIMER_NAME - 1] = '\0';
    }
}

void onTimer(JH_timer* timer, int idx) {
    if (idx >= 0 && idx < timer->count) {
        if (timer->timers[idx].is_running) {
            fprintf(stderr, "Error: Timer %d is already running.\n", idx);
            exit(1);
        }
        gettimeofday(&timer->timers[idx].start_time, NULL);
        timer->timers[idx].is_running = 1;
    }
}

void offTimer(JH_timer* timer, int idx) {
    if (idx >= 0 && idx < timer->count) {
        if (!timer->timers[idx].is_running) {
            fprintf(stderr, "Error: Timer %d is not running.\n", idx);
            exit(1);
        }
        struct timeval end_time;
        gettimeofday(&end_time, NULL);
        timer->timers[idx].elapsed_time += 
            (end_time.tv_sec - timer->timers[idx].start_time.tv_sec) * 1000.0 +
            (end_time.tv_usec - timer->timers[idx].start_time.tv_usec) / 1000.0;
        timer->timers[idx].is_running = 0;
    }
}

void printLog(JH_timer* timer, const char* filename) {
    FILE* output = filename ? fopen(filename, "w") : stdout;
    if (!output) {
        fprintf(stderr, "Error: Unable to open file for writing.\n");
        return;
    }

    for (int i = 0; i < timer->count; i++) {
        fprintf(output, "Timer %d (%s): %.2f ms\n", i, timer->timers[i].name, timer->timers[i].elapsed_time);
    }

    if (filename) {
        fclose(output);
    }
}

void timer_cleanup(JH_timer* timer) {
    free(timer->timers);
}