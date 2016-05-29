void FloppyMotorOn();
void FloppyMotorOff();
void WaitFloppy();
void initializeDMA(unsigned int page, unsigned int offset);
void FloppyCode(unsigned int code);
void ReadSector(int head, int track, int sector, unsigned char* src, unsigned char* dest);
int FloppyCalibrateHead();
int FloppySeek(int head, int cylinder);
void FloppyHandler();

