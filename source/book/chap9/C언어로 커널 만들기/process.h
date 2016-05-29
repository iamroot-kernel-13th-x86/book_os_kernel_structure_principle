typedef struct _TSS
{
	unsigned short BackLink;
	unsigned short BackLink2;

	unsigned int esp0;
	unsigned short ss0;
	unsigned short reserved0;

	unsigned int esp1;
	unsigned short ss1;
	unsigned short reserved1;

	unsigned int esp2;
	unsigned short ss2;
	unsigned short reserved2;

	unsigned int cr3;
	unsigned int eip;
	unsigned int eflags;
	unsigned int eax;
	unsigned int ecx;
	unsigned int edx;
	unsigned int ebx;
	unsigned int esp;
	unsigned int ebp;
	unsigned int esi;
	unsigned int edi;

	unsigned short es;
	unsigned short es_reserved;

	unsigned short cs;
	unsigned short cs_reserved;
	
	unsigned short ss;
	unsigned short ss_reserved;
	
	unsigned short ds;
	unsigned short ds_reserved;
	
	unsigned short fs;
	unsigned short fs_reserved;
	
	unsigned short gs;
	unsigned short gs_reserved;

	unsigned short ldt;
	unsigned short ldt_reserved;

	unsigned short t_bit;
	unsigned short io_perm;
}TSS;

typedef struct _UserRegisters
{
	unsigned int  edi;
	unsigned int  esi;
	unsigned int  ebp;
	unsigned int  espA;
	unsigned int  edx;
	unsigned int  ecx;
	unsigned int  ebx;
	unsigned int  eax;

	unsigned short ds;
	unsigned short ds_reserved;
	unsigned short es;
	unsigned short es_reserved;
	unsigned short fs;
	unsigned short fs_reserved;
	unsigned short gs;
	unsigned short gs_reserved;

	unsigned int eip;
	unsigned short cs;
	unsigned short cs_reserved;
	unsigned int eflags;
	unsigned int esp;
	unsigned short ss;
	unsigned short ss_reserved;

}UserRegisters;

void init_task();
void schedule();
