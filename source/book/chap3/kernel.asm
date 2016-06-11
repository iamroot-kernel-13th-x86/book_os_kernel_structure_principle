[org 0]
[bits 16]

start:	
	mov ax,cs  		; CS 에는 0x1000 이 들어 있다.
	mov ds,ax
	xor ax,ax
	mov ss,ax

	cli                      ; 인터럽트  disable, lgdt 변경을 위해

	lgdt[gdtr]               ; lgdt register, gdtr 주소값
				 ; gtd 설정을 위한 명령어
				; 교재 77p 참조 

	mov eax, cr0		
	or eax, 0x00000001
	mov cr0, eax		; cr = control register 32bit로 변경 cr0 = 1
				; 88p

	jmp $+2			;파이프 라인에 들어있는 real mode용 명령어를 제거하기 위함 88p 
	nop			;nop: Pad out with NOP instructions. The only difference compared to the standard ALIGN macro is that NASM can still jump over a large padding area. The default jump threshold is 16.

	nop
				; cpu 입장에서는 32bit지만 nasm은 16bit로 컴파일하기 때문에 이런 식으로 처리함.
	db 0x66			 
	db 0x67			; 0x66, 0x67 prefix - CPU 16bit-> 32bit
	db 0xEA			; EA = jmp의16진수 값
	dd PM_Start		; 
	dw SysCodeSelector	;   PM_Start(??): SysCodeSelect(0x08):

;-------------------------------------------------------;
;**********여기부터 Protected Mode 입니다.**************;
;-------------------------------------------------------;
[bits 32]


PM_Start:
	
	mov bx, SysDataSelector ; SysDataSelect = 0x08 
	mov ds, bx
	mov es, bx
	mov fs, bx
	mov gs, bx
	mov ss, bx

	xor eax, eax		; 0 초기화-  mov 보다 빠를것으로 추정
	mov ax, VideoSelector	; 0x18 
	mov es, ax		
	mov edi, 80*2*10+2*10
	lea esi, [ds:msgPMode]	; msgPMode = We are in Protected Mode", 0
				; ds - segment selector로 사용됨.
				; 
	call printf
	
	jmp $






;-----------------------------------------;
;*************Sub Rutines*****************;
;-----------------------------------------;
printf:
	push eax
		
printf_loop:
	or al, al	
	jz printf_end
	mov al, byte [esi]	
	mov byte [es:edi], al	
	inc edi	
	mov byte [es:edi], 0x06 
	inc esi		
	inc edi	
	jmp printf_loop
	
printf_end:
	pop eax		
	ret	

msgPMode db "We are in Protected Mode", 0	


;------------------------------------------;
;*********** GDT Table ********************;
;------------------------------------------;
; descriptor table - Segment limit checking, Read-only and execute-only segment options, Four privilege levels
;		- 24bit baseaddress -> 16M 이상 표현


gdtr:
	dw gdt_end - gdt - 1	; GDT의 limit
	dd gdt+0x10000          ; GDT의 베이스 어드레스

gdt:
				; NULL descriptor - 없으면 에러가 발생
	dw 0			; limit 0~15 비트
	dw 0			; 베이스어드레스의 하위 두 바이트
	db 0			; 베이스어드레스 16~23 비트
	db 0			; 타입
	db 0			; limit 16~19 비트, 플래그
	db 0			; 베이스어드레스 31~24 비트

;0-15	00000000 00000000 		; limit
;16-31	00000000 00000000		; base address
;32-39	00000000			; base address

;40-43	000 (or 0000)			; TYPE <- 그림3-6을 보면 4bit임. 교재가 좀 이상함.... 40 accessed bit가 안보임.
;44	0				; S 
;45-46	00				; DPL
;47	0				; P

;48-51	0000				; limit
;52	0				; AVL
;53	0				; 0
;54	0				; D
;55	0				; G

;56-63	00000000			; base address
				; 참고 http://wiki.osdev.org/GDT

				; 참고 https://staktrace.com/nuggets/index.php?id=11&replyTo=0
				;Bits 63-56: Bits 31-24 of the base address 
				;Bit 55: Granularity bit (set means the limit gets multiplied by 4K) 
				;Bit 54: 16/32-bit segment (0=16-bit, 1=32-bit) 
				;Bit 53: Reserved, should be zero 
				;Bit 52: Reserved for OS 
				;Bits 51-48: Bits 19-16 of the segment limit 
				;Bit 47: The segment is present in memory (used for virtual memory stuff) 
				;Bits 46-45: Descriptor privilege level (0=highest, 3=lowest) 
				;Bit 44: Descriptor bit (0=system descriptor, 1=code/data descriptor) 
				;Bits 43-41: The descriptor type (see below for an enumeration of the types) 
				;Bit 40: Accessed bit (again, for use with virtual memory) 
				;Bits 39-16: Bits 23-0 of the base address 
				;Bits 15-0: Bits 15-0 of the segment limit 


				; type
				; Bit 43: executable (0=data segment, 1=code segment) 
				; Bit 42: expansion direction (for data segments), conforming (for code segments) 
				; Bit 41: read/write (for data segments: 0=RO, 1=RW) (for code segments: 0=Execute only, 1=Read/execute)

; 코드 세그먼트 디스크립터
SysCodeSelector	equ 0x08        ; equ : define constraint -> http://www.nasm.us/doc/nasmdoc3.html
				; SysCodeSelector = 0x08
        dw 0xFFFF               ; limit:0xFFFF
	dw 0x0000		; base 0~15 bit
	db 0x01			; base 16~23 bit
	db 0x9A			; 1001 1010
				; P:1, DPL:0, Code, non-conforming, readable
				; P - paging과 관련 flag - 70p 중간 참조 
				; DPL - kernel/user flag - 70p
        db 0xCF                 ; 1100 1111 
				; G:1, D:1, limit 16~19 bit:0xF
	db 0x00			; base 24~32 bit

; 데이터 세그먼트 디스크립터
;SysDataSelector	equ 0x0f	; 10진수 16 index
SysDataSelector	equ 0x10	; 10진수 16 index
        dw 0xFFFF               ; limit 0xFFFF
	dw 0x0000		; base 0~15 bit
	db 0x01			; base 16~23 bit
	db 0x92			; 1001 0010
				; P:1, DPL:0, data, expand-up, writable
        db 0xCF                 ; G:1, D:1, limit 16~19 bit:0xF
	db 0x00			; base 24~32 bit

; 비디오 세그먼트 디스크립터
VideoSelector	equ 0x18	; 10진수 24
        dw 0xFFFF               ; limit 0xFFFF
	dw 0x8000		; base 0~15 bit
	db 0x0B			; base 16~23 bit
	db 0x92			; P:1, DPL:0, data, expand-up, writable
        db 0x40                 ; G:0, D:1, limit 16~19 bit:0
	db 0x00			; base 24~32 bit
gdt_end:
;------------------------------------------------------------------------
;------------------------------------------------------------------------

