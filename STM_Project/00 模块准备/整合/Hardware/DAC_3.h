#ifndef __DAC_3_H
#define __DAC_3_H	

void dac_dma_wave_init(void);
void dac_dma_wave_enable(uint16_t cndtr, uint16_t arr, uint16_t psc);
void dac_creat_sin_buf(uint16_t maxval, uint16_t samples);

#endif 
