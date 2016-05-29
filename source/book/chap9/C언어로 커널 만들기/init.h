#define SysCodeSelector  0x08
#define SysDataSelector  0x10
#define VideoSelector	 0x18
#define TSSSelector      0x20
#define UserCodeSelector 0x28+3
#define UserDataSelector 0x30+3

#define IDT_BASE         0xC0002000
#define TSS_WHERE        0x90000
#define NUM_MAX_TASK     4
