#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "sys/alt_irq.h"//包含中断API函数的头文件
#include "altera_avalon_uart_regs.h"

void Convert_Gen();

unsigned char buffer[1539];//对PC客户端发过来的数据进行缓冲

void Uart_INT(void* context)//中断服务程序，响应客户端的输入并进行缓冲
{
    static int index = 0;
    unsigned short int data,status;
    status = IORD_ALTERA_AVALON_UART_STATUS(UART_0_BASE);//读状态寄存器
    while (!(status & ALTERA_AVALON_UART_STATUS_RRDY_MSK))
        status = IORD_ALTERA_AVALON_UART_STATUS(UART_0_BASE);
    data =IORD_ALTERA_AVALON_UART_RXDATA(UART_0_BASE);
    buffer[index] = 0x00FF & data;//取出data寄存器低八位
    if(index == 1538)
    {
        index = 0;//计数器归零
        status = ALTERA_AVALON_UART_STATUS_TRDY_MSK;
        IOWR_ALTERA_AVALON_UART_STATUS(UART_0_BASE, status);
        IOWR_ALTERA_AVALON_UART_TXDATA(UART_0_BASE, 'e');
        IOWR_ALTERA_AVALON_UART_STATUS(UART_0_BASE, 0);
        Convert_Gen();
    }
    else
        index++;
}

int main()
{
	alt_ic_isr_register(UART_0_IRQ_INTERRUPT_CONTROLLER_ID,UART_0_IRQ,Uart_INT,0,0);//注册中断服务函数
    IOWR_ALTERA_AVALON_PIO_DATA(DPRAM_RDCLK_EN_BASE, 0x0);//禁止双口RAM读时钟使能
	IOWR_ALTERA_AVALON_PIO_DATA(DPRAM_WRCLK_EN_BASE, 0x1);//开启双口RAM写时钟使能
	IOWR_ALTERA_AVALON_PIO_DATA(DPRAM_WR_EN_BASE, 0x1);//双口RAM写使能
	int memadd;
	for(memadd=0;memadd<1023;memadd++)
	{
		IOWR_ALTERA_AVALON_PIO_DATA(DPRAM_WRCLK_BASE, 1);
		IOWR_ALTERA_AVALON_PIO_DATA(WRADDRESS_BASE, memadd);
        IOWR_ALTERA_AVALON_PIO_DATA(UART2DPRAM_BASE,2048);
		IOWR_ALTERA_AVALON_PIO_DATA(DPRAM_WRCLK_BASE, 0);
	}
    IOWR_ALTERA_AVALON_PIO_DATA(DPRAM_WR_EN_BASE, 0x0);//双口RAM写禁止
    IOWR_ALTERA_AVALON_PIO_DATA(DPRAM_WRCLK_EN_BASE, 0x0);//关闭双口RAM写时钟使能
    IOWR_ALTERA_AVALON_PIO_DATA(DPRAM_RDCLK_EN_BASE, 0x1);//开启双口RAM读时钟使能
    while(1);
    return 0;
}

void Convert_Gen()
{
    IOWR_ALTERA_AVALON_PIO_DATA(DPRAM_RDCLK_EN_BASE, 0x0);//禁止双口RAM读时钟使能
    IOWR_ALTERA_AVALON_PIO_DATA(DPRAM_WRCLK_EN_BASE, 0x1);//开启双口RAM写时钟使能
    IOWR_ALTERA_AVALON_PIO_DATA(DPRAM_WR_EN_BASE, 0x1);//双口RAM写使能
    int i;
    int memadd = 0;
    for(i=0;i<1536;i+=3)//循环写入双口ram
    {
        unsigned int tmp = 0;//8×3->12×2的缓存
        tmp = buffer[i]<<16;
        tmp |= (buffer[i+1]<<8);
        tmp |= buffer[i+2];
        IOWR_ALTERA_AVALON_PIO_DATA(DPRAM_WRCLK_BASE, 1);
        IOWR_ALTERA_AVALON_PIO_DATA(WRADDRESS_BASE, memadd);
        IOWR_ALTERA_AVALON_PIO_DATA(UART2DPRAM_BASE,tmp>>12);
        IOWR_ALTERA_AVALON_PIO_DATA(DPRAM_WRCLK_BASE, 0);
        memadd++;
        IOWR_ALTERA_AVALON_PIO_DATA(DPRAM_WRCLK_BASE, 1);
        IOWR_ALTERA_AVALON_PIO_DATA(WRADDRESS_BASE, memadd);
        IOWR_ALTERA_AVALON_PIO_DATA(UART2DPRAM_BASE,tmp);
        IOWR_ALTERA_AVALON_PIO_DATA(DPRAM_WRCLK_BASE, 0);
        memadd++;
    }
    int freq_word = 0;
    freq_word = buffer[1536]<<16;
    freq_word |= (buffer[1537]<<8);
    freq_word |= buffer[1538];
    IOWR_ALTERA_AVALON_PIO_DATA(FREQ_WORD_BASE, freq_word);
    IOWR_ALTERA_AVALON_PIO_DATA(DPRAM_WR_EN_BASE, 0x0);//双口RAM写禁止
    IOWR_ALTERA_AVALON_PIO_DATA(DPRAM_WRCLK_EN_BASE, 0x0);//关闭双口RAM写时钟使能
    IOWR_ALTERA_AVALON_PIO_DATA(DPRAM_RDCLK_EN_BASE, 0x1);//开启双口RAM读时钟使能
}

