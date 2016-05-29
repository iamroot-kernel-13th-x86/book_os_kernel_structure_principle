#include "print_string.h"

void print_string(int x, int y, char* str) 
{
	__asm__ __volatile__ (
			"push %%eax          \n\t"
			"push %%ebx          \n\t"
			"push %%ecx          \n\t"
			"mov %0, %%eax       \n\t"
			"mov %1, %%ebx       \n\t"
			"mov %2, %%ecx       \n\t"
			"int $0x80           \n\t"
			"pop %%ecx           \n\t"
			"pop %%ebx           \n\t"
			"pop %%eax           \n\t"
			:
			: "m"(x), "m"(y), "m"(str));
}
