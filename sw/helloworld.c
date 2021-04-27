/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "sleep.h"

#define TIMER_REG (0)
#define IO_REG (1)
#define FIFO_DATA_REG (2)
#define FIFO_COUNT_REG (3)
u32 tmpbuf[4096]; // just a holding buffer for data

int main()
{
    volatile u32 *periph_base = (volatile u32 *)XPAR_VAL_CUSTOM_0_S00_AXI_BASEADDR;
    u32 start_time,stop_time,freq_hz;
	init_platform();

    print("Hello World\n\r");
    xil_printf("Welcome to Lab 8 designed by *Derek Val-Addo\r\n");
    xil_printf("To start, lets read from the input register.  The value in decimal is %d\r\n",*(periph_base+IO_REG));
    xil_printf("Now, lets test the output by writing 3 to the output register\r\n");
    *(periph_base+IO_REG)=3;
    xil_printf("Next, lets start some benchmarking...\r\n");
    start_time = *(periph_base+TIMER_REG);
    usleep(1000000);
    stop_time = *(periph_base+TIMER_REG);
    freq_hz = stop_time-start_time;
    printf("A rough approximation of the axi clock is %4.2f MHz\r\n",freq_hz/1000000.0);
    printf("Timing a read of 1024 words = 4096 bytes...\r\n");
    start_time = *(periph_base+TIMER_REG);
    for (int i=0;i<1024;i++)
    {
    	stop_time=*(periph_base); // reading this register is as good as any!
    }
    float elapsed_time = (float)(stop_time-start_time)/freq_hz;
    printf("This took %d clocks, or %f us\r\n",stop_time-start_time, 1e6*elapsed_time);
    printf("Total throughput = %f Mbytes/sec\r\n",4096.0/(elapsed_time*1e6));

    printf("*** Benchmarking Complete ***\r\n");
    printf("Now entering FIFO Test Loop, press BTN1 to write 2048 words to the FIFO, and I'll grab them as I see them...\r\n");

    while(1)
    {
    	int avail_in_fifo = *(periph_base+FIFO_COUNT_REG);
    	if (avail_in_fifo > 0)
    	{
    		printf("I see %d words in the FIFO! Reading now...\r\n",avail_in_fifo);
    		for (int i=0;i<avail_in_fifo;i++)
    			tmpbuf[i]=*(periph_base+FIFO_DATA_REG);
    		printf("The first word was %d, and the last word was %d\r\n",tmpbuf[0],tmpbuf[avail_in_fifo-1]);
    	}
    }

    cleanup_platform();
    return 0;
}
