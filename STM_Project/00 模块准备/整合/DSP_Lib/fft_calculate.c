#include "fft_calculate.h"
#include "math.h"
#include "OLED.h"
#include "Delay.h"
#include "Serial.h"

long InBufArray[NPT]={0};
long OutBufArray[NPT/2];
long MagBufArray[NPT/2];
unsigned long maxMag;
unsigned long secondMaxMag;
int maxIndex;
int secondMaxIndex;


void GetPowerMag()
{
    signed short lX,lY;
    float X,Y,Mag;
    int i;
	maxMag = 0;
    secondMaxMag = 0;
    maxIndex = 0;
    secondMaxIndex = 0;
	
    for(i=1; i<NPT/2; i++)
    {
        lX  = (OutBufArray[i] << 16) >> 16;
        lY  = (OutBufArray[i] >> 16);
        
        
        X = NPT * ((float)lX) / 32768;
        Y = NPT * ((float)lY) / 32768;
        Mag = sqrt(X * X + Y * Y) / NPT;
		
		MagBufArray[i] = (unsigned long)(Mag * 65536);

        if (MagBufArray[i] > maxMag) {
            secondMaxMag = maxMag;
            secondMaxIndex = maxIndex;
            maxMag = MagBufArray[i];
            maxIndex = i;
        } else if (MagBufArray[i] > secondMaxMag) {
            secondMaxMag = MagBufArray[i];
            secondMaxIndex = i;
        }
		
		printf("\r\nMagBufArray[%d]=%d", i, (int)MagBufArray[i]);	
		
		
//		OLED_ShowNum(3, 1, MagBufArray[i], 6);
//		OLED_ShowNum(4, 1, i, 6);
        
    }
	
	printf("\r\nmaxIndex=%d", (int)maxIndex);
	printf("\r\nmaxMag=%d", (int)maxMag);
	printf("\r\nsecondMaxIndex=%d", (int)secondMaxIndex);
	printf("\r\nsecondMaxMag=%d", (int)secondMaxMag);
	
	OLED_ShowNum(1, 4, maxIndex, 5);
	OLED_ShowNum(2, 9, maxMag, 5);
	
}





