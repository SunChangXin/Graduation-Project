#ifndef _MYFIR_H_
#define _MYFIR_H_

#include "arm_math.h"

#define BLOCK_SIZE 1             /* 调用一次arm_fir_f32处理的采样点个数 */
#define TEST_LENGTH_SAMPLES 256 /* 采样点数 */
#define NUM_TAPS 29              /* 滤波器系数个数 */


extern float32_t testInput_f32_1024Hz[TEST_LENGTH_SAMPLES]; /* 采样点 */
extern float32_t testOutput[TEST_LENGTH_SAMPLES];          /* 滤波后的输出 */
extern float32_t firStateF32[BLOCK_SIZE + NUM_TAPS - 1];   /* 状态缓存，大小numTaps + blockSize - 1*/
void FIR(int Length ,int  BLOCKSIZE ,int BLen ,float32_t *input, float32_t *output, float *B);// Length 代表采的点数，BLOCK_SIZE大于1小于你的采样点数即可，BL代表滤波阶数，inout,output,代表输入数据和存储输出数据的数组，B是滤波系数。


void arm_fir_f32_lp(void);

#endif
