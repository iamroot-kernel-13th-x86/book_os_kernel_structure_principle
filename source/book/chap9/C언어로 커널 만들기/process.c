#include "init.h"
#include "process.h"

TSS *tss;
UserRegisters uRegisters[NUM_MAX_TASK];
int CurrentTask;

void init_task()
{
	int i, eip;

	// TSS_WHERE 는 TSS 의 주소가 들어 있는 주소이다.
	unsigned int* tss_where = (unsigned int*) TSS_WHERE;	
	tss = (TSS *) *tss_where; 

	eip = 0x80000000;

	for(i=0; i<5; i++)
	{
		/* 레지스터 값을 담아 놓은 구조체에
		 * 초기값을 넣어 놓는다. */
		uRegisters[i].eip = eip;
		uRegisters[i].cs = UserCodeSelector;
		uRegisters[i].eflags = 0x200;
	        uRegisters[i].esp = eip+0xFFF;
		uRegisters[i].ss = UserDataSelector;

		uRegisters[i].ds = UserDataSelector;
		uRegisters[i].es = UserDataSelector;
		uRegisters[i].fs = UserDataSelector;
		uRegisters[i].gs = UserDataSelector;

		eip += 0x1000;   // 0x80000000, 0x80001000, ...
	}

	CurrentTask = 0;	
}

void schedule()
{
	static unsigned int* ebp_A;
	static int NextTask;
	static unsigned int* CurrentTaskURegisters;
	static unsigned int* NextTaskURegisters;
	static unsigned int* RegistersInStack;

	static int i;
	
	__asm__ __volatile__ (
			"mov %%ebp, %0"
			:"=m"(ebp_A));
	/* 현재 쌓여 있는 스택 값들을
	 * 조사하기 위해서 
	 * EBP 레지스터에 있는 주소값을
	 * 사용한다. */
	if((ebp_A[15] & 0x00000003) == 0) 
		return;	

	/* 다음 태스크를 선택한다.
	 * 모든 태스크를 실행했으면,
	 * 0 번 태스크 부터 다시 실행한다. */
	NextTask = CurrentTask+1; 
	if(NextTask == NUM_MAX_TASK) NextTask = 0;
		
	RegistersInStack = &ebp_A[2];

	CurrentTaskURegisters =
	       	(unsigned int*) &(uRegisters[CurrentTask]);

	// 다음 태스크가 현재 태스크가 되었다.
	CurrentTask = NextTask;

	/* 현재 스택에 쌓여 있는 값들을
	 * 이전 태스크의 레지스터 구조체에
	 * 복사하여 저장한다. */
	for(i=0; i<17; i++)
		CurrentTaskURegisters[i] = RegistersInStack[i];

	NextTaskURegisters =
	       	(unsigned int *) &(uRegisters[NextTask]);

	__asm__ __volatile__ (
			"mov %%ebp, %%esp       \n\t"
        		"pop %%ebp              \n\t"
			"add $4, %%esp          \n\t"
			"add $68, %%esp         \n\t"
		        "mov %%esp, %0          \n\t"
			"mov %1, %%esp          \n\t"
			"popal                  \n\t"
			"pop %%ds               \n\t"
			"pop %%es               \n\t"
			"pop %%fs               \n\t"
			"pop %%gs               \n\t"
			"iret                   \n\t"
			: "=m"(tss->esp0)	
		       	: "m"(NextTaskURegisters));
}

