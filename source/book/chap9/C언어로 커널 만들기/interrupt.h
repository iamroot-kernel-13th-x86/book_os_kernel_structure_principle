#define IDT_BASE 0xC0002000
#define KERNEL_OFFSET 0xC0000000
#define SysCodeSelector  0x08

// interrupt.asm 에서 정의된 함수들
void LoadIDT();
void EnablePIC();
void print_stack();

void isr_32_timer();
void isr_33_keyboard();
void isr_38_floppy();
void isr_ignore();
void isr_128_soft_int();
void isr_00();
void isr_01();
void isr_02();
void isr_03();
void isr_04();
void isr_05();
void isr_06();
void isr_07();
void isr_08();
void isr_09();
void isr_10();
void isr_11();
void isr_12();
void isr_13();
void isr_14();
void isr_15();
void isr_17();

// 이 파일에서 사용하는 함수들
void SetInterrupts();
void PutIDT(int num, void *handler, unsigned char access);
void TimerHandler();
void FloppyHandler();
void printk(int x, int y, char* str);
void print_hex(int x, int y, int num);
void delay(int TenMillisecond);

typedef struct _IDT_Desc
{
	 unsigned short handler_low;
	 unsigned short cs;
	unsigned char no_use;
	unsigned char type;
	 unsigned short handler_high;	
}IDT_Desc;

