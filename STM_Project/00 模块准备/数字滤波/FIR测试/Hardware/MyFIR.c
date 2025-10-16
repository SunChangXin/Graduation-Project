#include "MyFIR.h"
#include "arm_math.h"
#include "stdio.h"

#define BLOCK_SIZE 1             /* 调用一次arm_fir_f32处理的采样点个数 */

uint32_t blockSize = BLOCK_SIZE;
uint32_t numBlocks = TEST_LENGTH_SAMPLES / BLOCK_SIZE; /* 需要调用arm_fir_f32的次数 */

float32_t testInput_f32_1024Hz[TEST_LENGTH_SAMPLES]; /* 采样点 */
float32_t testOutput[TEST_LENGTH_SAMPLES];          /* 滤波后的输出 */
float32_t firStateF32[BLOCK_SIZE + NUM_TAPS - 1];   /* 状态缓存，大小numTaps + blockSize - 1*/

/* 低通滤波器系数 通过fadtool获取*/
const int BL = 29;
const float B[29] = {
  -0.001761333784,-0.001165639027,0.0007307335618, 0.004363354761, 0.007934480906,
   0.007002693135,-0.002558653709, -0.01947794482,  -0.0339184925, -0.03013479337,
   0.004847030155,  0.07122008502,   0.1520164758,    0.218659088,   0.2444858551,
      0.218659088,   0.1520164758,  0.07122008502, 0.004847030155, -0.03013479337,
    -0.0339184925, -0.01947794482,-0.002558653709, 0.007002693135, 0.007934480906,
   0.004363354761,0.0007307335618,-0.001165639027,-0.001761333784
};


void arm_fir_f32_lp(void)
{
    uint32_t i;
    arm_fir_instance_f32 S;
    float32_t *inputF32, *outputF32;
    /* 初始化输入输出缓存指针 */
    inputF32 = &(testInput_f32_1024Hz[0]);
    outputF32 = &(testOutput[0]);
    /* 初始化结构体S */
    arm_fir_init_f32(&S,
                     NUM_TAPS,
                     (float32_t *)&B[0],
                     &firStateF32[0],
                     blockSize);
    /* 实现FIR滤波，这里每次处理1个点 */
    for (i = 0; i < numBlocks; i++)
    {
        arm_fir_f32(&S, inputF32 + (i * blockSize), outputF32 + (i * blockSize), blockSize);
    }
}



