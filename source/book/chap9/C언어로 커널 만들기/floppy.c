#include "floppy.h"

#define READ_SECTOR_HEAD_DRIVE 1
#define READ_SECTOR_TRACK 2
#define READ_SECTOR_HEAD 3
#define READ_SECTOR 4

#define SEEK_HEAD_DRIVE 1
#define SEEK_CYLINDER 2

unsigned int floppy_code_read_sector[9] =   // 한 섹터를 읽기 위한 프로그램 코드
{ 0x66, 0x00, 0x00, 0x00, 0x00, 0x02, 18, 0x1b, 0x00 };

unsigned int floppy_code_calibrate[2] =     // Calibrate 프로그램 코드
{ 0x07, 0x00 }; 

unsigned int floppy_code_seek[3] =          // Seek 프로그램 코드
{ 0x0F, 0x00, 0x00 };

unsigned int floppy_code_interrupt_status = 0x08;
                                            // 인터럽트 확인 프로그램 코드
int g_FloppyInterrupted = 0;
int cont = 0;

static int interrupt_count = 1;

char result_seek[7];

void ReadIt();

void ReadSector(int head, int track, int sector, unsigned char* source, unsigned char* destinity)
{
	int i;
	int page, offset;
	unsigned int src, dest;
	char result[7];

	src = (unsigned int) source;
	dest = (unsigned int) destinity;

	page = (int) (src >> 16);            // 페이지 번호
	offset = (int) (src & 0x0FFFF);      // 페이지 안에서의 오프셋

	FloppyMotorOn();                     // 드라이브 모터 ON
	delay(20);

	for(i=0; i<5; i++)
	{
		/* 5번의 시도에서 두가지 동작이 모두 
		 * 행해져야 한다.
		 * 하나라도 실패하면 다시 하며,
		 * 두 동작을 합쳐서 5번 시도를 하여
		 * 안되면 그냥 넘어감 */

		if(!FloppyCalibrateHead())   // Calibrate 
			continue;

		if(!FloppySeek(head, track)) // Seek
			continue;
		else 
			break;
	}

	initializeDMA(page, offset);     // DMA의 초기화

	// head, track, sector 등을 지정한다.
	floppy_code_read_sector[READ_SECTOR_HEAD_DRIVE] = head << 2;
	floppy_code_read_sector[READ_SECTOR_TRACK] = track;
	floppy_code_read_sector[READ_SECTOR_HEAD] = head;
	floppy_code_read_sector[READ_SECTOR] = sector;


	g_FloppyInterrupted = 0;
	
	for(i=0; i<9; i++)     
	{
		WaitFloppy();            // FDC가 준비 상태인지 확인
		FloppyCode(floppy_code_read_sector[i]);
		                         // 한 섹터를 읽는다.
	}

	while(!g_FloppyInterrupted);     // 인터럽트가 걸릴 때 까지 
	g_FloppyInterrupted = 0;         // 기다린다.
	
	delay(20);
	
	for(i=0; i<7; i++) 
	{
		WaitFloppy();
		result[i] = ResultFhase(); // 결과 값을 확인한다.
	}

	WaitFloppy();
	FloppyMotorOff();                 // 모터를 끈다.	

	for(i=0; i<512; i++)
		destinity[i] = source[i]; // DMA 로 읽어 들인 데이터를 
                                          // 사용하기 좋은 곳으로 
					  // 옮긴다.
	return 1;
}

int FloppyCalibrateHead()
{
	int i;
	char result[2];

	for(i=0; i<2; i++)
	{
		WaitFloppy();
		FloppyCode(floppy_code_calibrate[i]);
		                           // Calibrate 한다.
	}
	delay(20);

	WaitFloppy();
	FloppyCode(floppy_code_interrupt_status);
	                                   // 인터럽트가 걸렸는지
					   // 확인한다.

	WaitFloppy();
	result[0] = ResultFhase();         // 결과 값을 확인한다.
	WaitFloppy();
	result[1] = ResultFhase();
	
	if(result[0] != 0x20)              // 0x20이 나와야 한다. 
		return 0;
	else
		return 1;

}

int FloppySeek(int head, int cylinder)
{
	int i, j;
	char result[7];

	// cylinder와 head를 지정한다.
	floppy_code_seek[SEEK_CYLINDER] = cylinder;
	floppy_code_seek[SEEK_HEAD_DRIVE] = head << 2;

	g_FloppyInterrupted = 0;

	for(i=0; i<3; i++)
	{
		WaitFloppy();
		FloppyCode(floppy_code_seek[i]);
		                          // Seek 한다.
	}
	
	while(!g_FloppyInterrupted);      // 인터럽트를 기다린다.

	delay(20);

	WaitFloppy();
	FloppyCode(floppy_code_interrupt_status);
	                                  // FDC 레지스터로 
					  // 인터럽트를 확인한다.

	WaitFloppy();
	result[0] = ResultFhase();        // 결과 값을 확인한다.
	WaitFloppy();
	result[1] = ResultFhase();

	if(result[0] != 0x20)             // 0x20 이 나와야 한다.
		return 0;

	WaitFloppy();
	FloppyCode(0x4a);                 // Sector ID를 읽는다.
	WaitFloppy();
	FloppyCode((head << 2));
	for(i=0; i<7; i++)
	{
		WaitFloppy();
		result_seek[i] = ResultFhase();
	}


	if(result_seek[3] != cylinder)
		return 0;
	else
		return 1;

}

void FloppyCode(unsigned int code)
{
	outb(0x3F5, code);          // 0x3F5 레지스터에 한 바이트를 
	                            // 프로그램 한다.
}

void WaitFloppy()                   // FDC의 준비상태 여부를 확인.
{
	unsigned int result;

	while(1)
	{
		result = inb(0x3F4);  

		if((result & 0x80) == 0x80)
			break;
	}
}

void FloppyHandler()                // IRQ6의 인터럽트 핸들러
{
	g_FloppyInterrupted = 1;	
}
