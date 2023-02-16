#include "libdivide.h"
#include <stdio.h>

int sum_of_quotientsC(const int *numers, int count, int d);
int sum_of_quotientsLibDiv(const int *numers, size_t count, int d);

int main() {
  size_t count = 1000000000;

  int* inputArr = (int*)malloc(count*sizeof(int));
  for (int i = 0; i < count; i++)
    inputArr[i] = i;

  //printf("%i\n", sum_of_quotientsC(inputArr,count,10));
  printf("%i\n", sum_of_quotientsLibDiv(inputArr,count,10));
  return 0;
}

int sum_of_quotientsC(const int *numers, int count, int d) {
    int result = 0;
    for (int i=0; i < count; i++)
        result += numers[i] / d; //this division is slow!
    return result;
}

int sum_of_quotientsLibDiv(const int *numers, size_t count, int d) {
    int result = 0;
    struct libdivide_s32_t fast_d = libdivide_s32_gen(d);
    for (size_t i=0; i < count; i++)
        result += libdivide_s32_do(numers[i], &fast_d); // performs faster libdivide division
    return result;
}
