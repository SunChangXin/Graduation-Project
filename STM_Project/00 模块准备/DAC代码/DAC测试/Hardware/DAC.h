#ifndef __DAC_H
#define __DAC_H	

void DAC_TriangularWave(uint16_t maxval, uint16_t dt, uint16_t samples, uint16_t n);
void DAC_SetVoltage(uint16_t voltage);
void DAC_InitConfig(void);

#endif 
