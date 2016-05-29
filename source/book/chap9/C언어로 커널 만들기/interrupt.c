#include "interrupt.h"
#include "process.h"

int trap;
extern TSS *tss;

int TimePastBoot;

void SetInterrupts()
{
	int i;

	TimePastBoot = 0;

	for(i=0; i<256; i++)
		PutIDT(i, (void *) &isr_ignore, 0x8E);		

	PutIDT(0x00, (void *) &isr_00, 0x8E);
	PutIDT(0x01, (void *) &isr_01, 0x8E);
	PutIDT(0x02, (void *) &isr_02, 0x8E);
	PutIDT(0x03, (void *) &isr_03, 0x8E);
	PutIDT(0x04, (void *) &isr_04, 0x8E);
	PutIDT(0x05, (void *) &isr_05, 0x8E);
	PutIDT(0x06, (void *) &isr_06, 0x8E);
	PutIDT(0x07, (void *) &isr_07, 0x8E);
	PutIDT(0x08, (void *) &isr_08, 0x8E);
	PutIDT(0x09, (void *) &isr_09, 0x8E);
	PutIDT(0x0A, (void *) &isr_10, 0x8E);
	PutIDT(0x0B, (void *) &isr_11, 0x8E);
	PutIDT(0x0C, (void *) &isr_12, 0x8E);
	PutIDT(0x0D, (void *) &isr_13, 0x8E);
	PutIDT(0x0E, (void *) &isr_14, 0x8E);
	PutIDT(0x0F, (void *) &isr_15, 0x8E);
	PutIDT(0x10, (void *) &isr_17, 0x8E);

	PutIDT(0x20, (void *) &isr_32_timer, 0x8E);
	PutIDT(0x21, (void *) &isr_33_keyboard, 0x8E);
	PutIDT(0x26, (void *) &isr_38_floppy, 0x8E);
	PutIDT(0x80, (void *) &isr_128_soft_int, 0xEE);

	LoadIDT();

	EnablePIC();
}

void PutIDT(int num, void *handler, unsigned char type)
{
	IDT_Desc *iDesc = (IDT_Desc *)IDT_BASE;
	unsigned int iHandler = (unsigned int) handler;

	iHandler |= KERNEL_OFFSET;
	
	iDesc[num].handler_low = (unsigned short) (iHandler & 0x0000FFFF);
	iDesc[num].cs = SysCodeSelector;
	iDesc[num].no_use = 0;
	iDesc[num].type = type;
	iDesc[num].handler_high = (unsigned short) (iHandler >> 16); 
}

void print_stack()
{
	unsigned int* esp_A;
	unsigned int* ebp_A;
	int i;

	__asm__ __volatile__ (
			"mov %%ebp, %%esp   \n\t"
			"pop %%ebp          \n\t"
			"mov %%esp, %0      \n\t"
			"mov %%ebp, %1      \n\t"
			: "=m"(esp_A), "=m"(ebp_A));

	printk(51, 0, "ESP      ");
	print_hex(51, 1, (unsigned int) esp_A);
	for(i=0; i<25; i++)	
		print_hex(60, i, esp_A[i]);

	printk(31, 0, "EBP      ");
	print_hex(31, 1, (unsigned int) ebp_A);
	for(i=0; i<25; i++)
		print_hex(40, i, ebp_A[i]);
	while(1);
}


void IgnorableInterrrupt()
{
	char *msg_H_isr_ignore = 
		"This is an ignorable interrupt";

	printk(0, 12, msg_H_isr_ignore);

	while(1);
}


void TimerHandler()
{
	char *s = "Time: "; 

	printk(0, 0, s);
	print_hex(6, 0, TimePastBoot);
	TimePastBoot++;
}

void delay(int TenMillisecond)
{
	int before = TimePastBoot;
	int after;

	while(1)
	{
		after = TimePastBoot;
		if(before > after)
		{
			before = TimePastBoot;
			continue;
		}

		if((before+TenMillisecond) == after)
			break;
	}
}

void KeyboardHandler(char scan)
{
	char *s = "Scan Code: ";
	printk(20, 0, s);
	print_hex(31, 0, (scan&0xFF));
	
	trap = 0;	
}




void SystemCallEntry()
{
	unsigned int eax_A, ebx_A;
	char* ecx_A;
	__asm__ __volatile__ (
			"mov %%eax, %0       \n\t"
			"mov %%ebx, %1       \n\t"
			"mov %%ecx, %2       \n\t"
			: "=m"(eax_A), "=m"(ebx_A), "=m"(ecx_A));

	printk(eax_A, ebx_A, ecx_A);
}

void H_isr_00()
{
	char *msg_H_isr_00_zero_devide = 
		"Zero Devide";

	printk(0, 12, msg_H_isr_00_zero_devide);

	while(1);
}


void H_isr_01()
{
	static unsigned int eip_A;

	char *msg_H_isr_01_debug = 
		"Debug";
	
	printk(0, 12, msg_H_isr_01_debug);

	while(1);
}


void H_isr_02()
{
	char *msg_H_isr_02_nmi = 
		"NMI";

	printk(0, 12, msg_H_isr_02_nmi);

	while(1);
}

void H_isr_03()
{

	char *msg_H_isr_03 = 
		"Int0";
	printk(0, 12, msg_H_isr_03);

	while(1);
}

void H_isr_04()
{
	char *msg_H_isr_04_into = 
		"INTO";
	printk(0, 12, msg_H_isr_04_into);

	while(1);
}

void H_isr_05()
{
	char *msg_H_isr_05_bound = 
		"Bound";

	printk(0, 12, msg_H_isr_05_bound);

	while(1);
}

void H_isr_06()
{
	char *msg_H_isr_06_opcode = 
		"Invalid Opcode";

	printk(0, 12, msg_H_isr_06_opcode);

	while(1);
}

void H_isr_07()
{
	char *msg_H_isr_07_coprocess = 
		"Coprocess Not Available";

	printk(0, 12, msg_H_isr_07_coprocess);

	while(1);
}

void H_isr_08()
{
	char *msg_H_isr_08_double_fault = 
		"Double Fault";

	printk(0, 12, msg_H_isr_08_double_fault);

	while(1);
}

void H_isr_09()
{
	char *msg_H_isr_09_coprocess_segment = 
		"Coprocess Segment Overrun";

	printk(0, 12, msg_H_isr_09_coprocess_segment);

	while(1);
}

void H_isr_10()
{
	char *msg_H_isr_10_bad_tss = 
		"Bad TSS";

	printk(0, 12, msg_H_isr_10_bad_tss);

	while(1);
}

void H_isr_11()
{
	char *msg_H_isr_11_segment_not_present = 
		"Segment Not Present";

	printk(0, 12, msg_H_isr_11_segment_not_present);

	while(1);
}

void H_isr_12()
{
	char *msg_H_isr_12_stack_fault = 
		"Stack Fault";

	printk(0, 12, msg_H_isr_12_stack_fault);

	while(1);
}

void H_isr_13()
{
	char *msg_H_isr_13_gpf = 
		"GPF";

	printk(0, 12, msg_H_isr_13_gpf);

	unsigned int esp_A;

	__asm__ __volatile__ (
			"mov %%esp, %0         \n\t"
			: "=m"(esp_A));
	printk(0, 11, "ESP ");
	print_hex(4, 11, esp_A);

	print_stack();

	while(1);
}

void H_isr_14()
{
	char *msg_H_isr_14_page_fault = 
		"Page Fault";

	unsigned int cr2_A;
	unsigned int esp_A;

	__asm__ __volatile__ (
			"mov %%cr2, %%eax      \n\t"
			"mov %%eax, %0         \n\t"
			"mov %%esp, %1         \n\t"
			: "=m"(cr2_A), "=m"(esp_A));
	printk(0, 10, "CR2 ");
	print_hex(4, 10, (unsigned int) cr2_A);
	printk(0, 11, "ESP ");
	print_hex(4, 11, esp_A);


	printk(0, 12, msg_H_isr_14_page_fault);

	while(1);
}

void H_isr_15()
{
	char *msg_H_isr_15_coprocessor_error = 
		"Coprocess Error";

	printk(0, 12, msg_H_isr_15_coprocessor_error);

	while(1);
}

void H_isr_17()
{
	char *msg_H_isr_17_alignment_check = 
		"Alignment Check";

	printk(0, 12, msg_H_isr_17_alignment_check);

	while(1);
}


