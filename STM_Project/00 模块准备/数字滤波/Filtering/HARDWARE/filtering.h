#ifndef __FILTERING_H
#define __FILTERING_H

#include "main.h"

int firstOrderFilter(int newValue, int oldValue, float a);
int middleValueFilter(int N);
int averageFilter(int N);
int moveAverageFilter();
int LAverageFilter();
int KalmanFilter(int inData);

#endif