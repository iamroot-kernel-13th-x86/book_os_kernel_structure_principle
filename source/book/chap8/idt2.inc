idt_exception00:
	dw isr_00
	dw 0x08
	db 0
	db 0x8E
	dw 0xC000

idt_exception01:
	dw isr_01
	dw 0x08
	db 0
	db 0x8E
	dw 0xC000

idt_exception02:
	dw isr_02
	dw 0x08
	db 0
	db 0x8E
	dw 0xC000

idt_exception03:
	dw isr_03
	dw 0x08
	db 0
	db 0x8E
	dw 0xC000

idt_exception04:
	dw isr_04
	dw 0x08
	db 0
	db 0x8E
	dw 0xC000

idt_exception05:
	dw isr_05
	dw 0x08
	db 0
	db 0x8E
	dw 0xC000

idt_exception06:
	dw isr_06
	dw 0x08
	db 0
	db 0x8E
	dw 0xC000

idt_exception07:
	dw isr_07
	dw 0x08
	db 0
	db 0x8E
	dw 0xC000

idt_exception08:
	dw isr_08
	dw 0x08
	db 0
	db 0x8E
	dw 0xC000

idt_exception09:
	dw isr_09
	dw 0x08
	db 0
	db 0x8E
	dw 0xC000

idt_exception10:
	dw isr_10
	dw 0x08
	db 0
	db 0x8E
	dw 0xC000

idt_exception11:
	dw isr_11
	dw 0x08
	db 0
	db 0x8E
	dw 0xC000

idt_exception12:
	dw isr_12
	dw 0x08
	db 0
	db 0x8E
	dw 0xC000

idt_exception13:
	dw isr_13
	dw 0x08
	db 0
	db 0x8E
	dw 0xC000

idt_exception14:
	dw isr_14
	dw 0x08
	db 0
	db 0x8E
	dw 0xC000

idt_exception15:
	dw isr_15
	dw 0x08
	db 0
	db 0x8E
	dw 0xC000

idt_exception17:
	dw isr_17
	dw 0x08
	db 0
	db 0x8E
	dw 0xC000

idt_ignore:	
	dw isr_ignore
	dw 0x08
	db 0
	db 0x8E
	dw 0xC000
	
idt_timer:
	dw isr_32_timer
	dw 0x08
	db 0
	db 0x8E
	dw 0xC000
	
idt_keyboard:
	dw isr_33_keyboard
	dw 0x08
	db 0
	db 0x8E
	dw 0xC000

idt_soft_int:
	dw isr_128_soft_int
	dw 0x08
	db 0
	db 0xEF
	dw 0xC000
