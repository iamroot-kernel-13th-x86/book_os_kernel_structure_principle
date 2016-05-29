[org 0]
[bits 16]

start:	
	mov ax,cs  		; CS 에는 0x1000 이 들어 있다.
	mov ds,ax
	xor ax,ax
	mov ss,ax

	cli

	lgdt[gdtr]

	mov eax, cr0
	or eax, 0x00000001
	mov cr0, eax

	jmp $+2
	nop
	nop

	db 0x66
	db 0x67
	db 0xEA	
	dd PM_Start
	dw SysCodeSelector

;-------------------------------------------------------;
;**********여기부터 Protected Mode 입니다.**************;
;-------------------------------------------------------;
[bits 32]


PM_Start:
	
	mov bx, SysDataSelector
	mov ds, bx
	mov es, bx
	mov fs, bx
	mov gs, bx
	mov ss, bx

	xor eax, eax
	mov ax, VideoSelector
	mov es, ax
	mov edi, 80*2*10+2*10
	lea esi, [ds:msgPMode]
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
SysCodeSelector	equ 0x08
        dw 0xFFFF               ; limit:0xFFFF
	dw 0x0000		; base 0~15 bit
	db 0x01			; base 16~23 bit
	db 0x9A			; P:1, DPL:0, Code, non-conforming, readable
        db 0xCF                 ; G:1, D:1, limit 16~19 bit:0xF
	db 0x00			; base 24~32 bit

; 데이터 세그먼트 디스크립터
SysDataSelector	equ 0x10
        dw 0xFFFF               ; limit 0xFFFF
	dw 0x0000		; base 0~15 bit
	db 0x01			; base 16~23 bit
	db 0x92			; P:1, DPL:0, data, expand-up, writable
        db 0xCF                 ; G:1, D:1, limit 16~19 bit:0xF
	db 0x00			; base 24~32 bit

; 비디오 세그먼트 디스크립터
VideoSelector	equ 0x18
        dw 0xFFFF               ; limit 0xFFFF
	dw 0x8000		; base 0~15 bit
	db 0x0B			; base 16~23 bit
	db 0x92			; P:1, DPL:0, data, expand-up, writable
        db 0x40                 ; G:0, D:1, limit 16~19 bit:0
	db 0x00			; base 24~32 bit
gdt_end:
;------------------------------------------------------------------------
;------------------------------------------------------------------------

