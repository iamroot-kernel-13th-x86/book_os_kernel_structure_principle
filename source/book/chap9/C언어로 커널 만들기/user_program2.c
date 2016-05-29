#include "print_string.h"

void print_it();

int main()
{
	print_it();
}

void print_it()
{
	char *str1 = "This is User2"; 
	char *str2 = ".I'm running now.";

	while(1)
	{
		print_string(25, 10, str1);
		print_string(25, 11, str2);
		str2[0]++;
	}
}
