#ifndef __FFT_H
#define __FFT_H
#include "sys.h"

#define   NPT   1024
#define   N_TMD   7
extern u32 lBufInArray[NPT];
extern u32 lBufOutArray[NPT];
extern u32 lBufMagArray[NPT];
extern u32 Fs; 
extern float Fmax;
void GetPowerMag(void);
void InitBufInArray(void);
void InitBufInArray2(void);
void lcd_print_fft(unsigned int *p);
void lcd_show_fft(unsigned int *p);
void select_max(float *f,float *a,unsigned int ij,unsigned int *flag);
void wavedisplay(u16 *p);
void window();
void griddisplay();
void select_max_fft(unsigned int *p);
void show_ma();
int peak_count(unsigned int *a);
int peak_count2(unsigned int *a);
#endif
