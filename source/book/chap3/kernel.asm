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
gdtr:
	dw gdt_end - gdt - 1	; GDT의 limit
	dd gdt+0x10000          ; GDT의 베이스 어드레스

gdt:
	dw 0			; limit 0~15 비트
	dw 0			; 베이스어드레스의 하위 두 바이트
	db 0			; 베이스어드레스 16~23 비트
	db 0			; 타입
	db 0			; limit 16~19 비트, 플래그
	db 0			; 베이스어드레스 31~24 비트

; 코드 세그먼트 디스크립터
SysCodeSelector	equ 0x08        ; equ : define constraint -> http://www.nasm.us/doc/nasmdoc3.html
				; SysCodeSelector = 0x08
        dw 0xFFFF               ; limit:0xFFFF
	dw 0x0000		; base 0~15 bit
	db 0x01			; base 16~23 bit
	db 0x9A			; P:1, DPL:0, Code, non-conforming, readable
				; P - paging과 관련 flag - 70p 중간 참조 
				; DPL - kernel/user flag - 70p
        db 0xCF                 ; G:1, D:1, limit 16~19 bit:0xF
	db 0x00			; base 24~32 bit

; 데이터 세그먼트 디스크립터
SysDataSelector	equ 0x0f	; 10진수 16 index
        dw 0xFFFF               ; limit 0xFFFF
	dw 0x0000		; base 0~15 bit
	db 0x01			; base 16~23 bit
	db 0x92			; P:1, DPL:0, data, expand-up, writable
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

