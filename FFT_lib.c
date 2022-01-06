#include <stdio.h>
#include <system.h>

#define point0_input (*(volatile int*)    0x400000)   //point 0 of FFT input
#define point1_input (*(volatile int*)    0x400010)   //point 1 of FFT input
#define point2_input (*(volatile int*)    0x400020)   //point 2 of FFT input
#define point3_input (*(volatile int*)    0x400030)   //point 3 of FFT input

#define enable (*(volatile int*)    0x400040)           //bit 1:enable FFT
#define reset  (*(volatile int*)    0x400050)           //bit 1:reset FFT
#define done   (*(volatile int*)    0x400060)           //bit 1:done FFT calculation

#define point0_output (*(volatile int*)    0x400100)  //point 0 of FFT output
#define point1_output (*(volatile int*)    0x400110)  //point 1 of FFT output
#define point2_output (*(volatile int*)    0x400120)  //point 2 of FFT output
#define point3_output (*(volatile int*)    0x400130)  //point 3 of FFT output

typedef struct {
    int real;
    int imag;
} Complex

int FFT(int *array)
{
   Complex FFT_array[4];
    //feed data to FFT core
   point0_input= array[0];
   point1_input= array[1];
   point2_input= array[2];
   point3_input= array[3];

   //turn on FFT core
   enable = 1;
   reset  = 0;

   while(done==0);//check done calculation

   //extract data from FFT core and pass to structure
   FFT_array[0].real=point0_output>>16;
   FFT_array[0].imag=point0_output&0xFFFF;

   FFT_array[1].real=point1_output>>16;
   FFT_array[1].imag=point1_output&0xFFFF;

   FFT_array[2].real=point2_output>>16;
   FFT_array[2].imag=point2_output&0xFFFF;

   FFT_array[3].real=point3_output>>16;
   FFT_array[3].imag=point3_output&0xFFFF;

   //turn off FFT core
   enable = 0;
   reset  = 1;
   return FFT_array;
}
