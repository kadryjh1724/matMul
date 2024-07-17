#ifndef JH_TIMER_H
#define JH_TIMER_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>

#define MAX_TIMER_NAME 50

typedef struct {
    char name[MAX_TIMER_NAME];
    struct timeval start_time;
    double elapsed_time;
    int is_running;
} Timer;

typedef struct {
    Timer* timers;
    int count;
} JH_timer;

JH_timer timer_init(int N);
void setTimerName(JH_timer* timer, int idx, const char* name);
void onTimer(JH_timer* timer, int idx);
void offTimer(JH_timer* timer, int idx);
void printLog(JH_timer* timer, const char* filename);
void timer_cleanup(JH_timer* timer);

#endif