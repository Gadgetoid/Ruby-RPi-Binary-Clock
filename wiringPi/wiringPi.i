%module wiringpi

extern int  wiringPiSetup   (void) ;
extern void pullUpDnControl (int pin, int pud) ;
extern void pinMode         (int pin, int mode) ;
extern void digitalWrite    (int pin, int value) ;
extern void pwmWrite        (int pin, int value) ;
extern int  digitalRead     (int pin) ;

%{
#include "wiringPi.h"
%}
