%include "init.inc"

[org 0x10000]
[bits 32]

PM_Start:
	
	mov bx, SysDataSelector
	mov ds, bx
	mov es, bx
	mov fs, bx
	mov gs, bx
	mov ss, bx
	lea esp, [PM_Start] ; esp stack point 초기화 10000

	mov edi, 0
	lea esi, [msgPMode]
	call printf

	cld			; up direction 
				; rep movesb 동작시 방향 지정
	mov ax, SysDataSelector
	mov es, ax
	xor eax, eax
	xor ecx, ecx
	mov ax,256		; IDT 영역에 256개의 빈 디스크립터를 복사한다.
	mov edi, 0

 loop_idt:
	lea esi, [idt_ignore]	
	mov cx,8		; 디스크립터 하나는 8바이트이다.
	rep movsb		; movesb : byte 만큼 복사, rep : cx 값만큼 반복 ->  1byte복사될때마다 cx - 1 => 8회 수행


				; cx레지스터 값만큼 byte이동
	dec ax
	jnz loop_idt

	mov edi, 8*0x20		; idt 8byte -  0x20 ; iterrupt number 32 = 0x20
	lea esi, [idt_timer]
	mov cx, 8
	rep movsb		; movesb : byte 만큼 복사, rep : cx 값만큼 반복 ->  1byte복사될때마다 cx - 1 => 8회 수행

	lidt [idtr]
	
	mov al, 0xFE            ; 막아두었던 인터럽트 중, 
				; 1111 1110 - p126 참조 (timer)
	out 0x21, al		; 타이머만 다시 유효하게 한다. - PIC 레벨
				; 타이머는 자동으로 인터럽트 계속 발생
	sti			; CPU 인터럽트 활성화

	jmp $


printf:
	push eax		
	push es
	mov ax, VideoSelector
	mov es, ax

printf_loop:
	mov al, byte [esi]	
	mov byte [es:edi], al	
	inc edi	
	mov byte [es:edi], 0x06 
	inc esi		
	inc edi	
	or al, al	
	jz printf_end
	jmp printf_loop
	
printf_end:
	pop es
	pop eax		
	ret	

msgPMode db "We are in Protected Mode", 0	
msg_isr_ignore db "This is an ignorable interrupt", 0
msg_isr_32_timer db ".This is the timer interrupt", 0


idtr:	dw	256*8-1		; IDT 의 Limit 
	dd	0       	; IDT 의 Base Address

;****************************************
;****   Interrupt Service Rutines  ******
;****************************************
isr_ignore:
	push gs
	push fs
	push es
	push ds
	pushad
	pushfd

	mov al,0x20
	out 0x20,al

	mov ax, VideoSelector
	mov es, ax
	mov edi, (80*7*2)
	lea esi, [msg_isr_ignore]
	call printf
	
	popfd
	popad
	pop ds
	pop es
	pop fs
	pop gs
	
	iret			; 인터럽트 발생전 시점으로 복원

isr_32_timer:
	push gs
	push fs
	push es
	push ds
	pushad
	pushfd

	mov	al,0x20 	; 0010 0000  -> IO 20번 port를 OCW2
				;    0 0 -> (3,4 bit OCW2)
				; 001   -> EOI( end of interrup )
	out	0x20,al		; 

	mov ax, VideoSelector	
	mov es, ax
	mov edi, (80*2*2)
	lea esi, [msg_isr_32_timer]
	call printf
	inc byte [msg_isr_32_timer]  ; inc => +1  
	
	popfd
	popad
	pop ds
	pop es
	pop fs
	pop gs
	
	iret



;****************************************
;*************   IDT   ******************
;****************************************
idt_ignore:	
	dw isr_ignore
	dw 0x08
	db 0
	db 0x8E
	dw 0x0001
idt_timer:			; 109p 그림 4-1 참조
	dw isr_32_timer		; 핸들러 하위 16bit 오프셋
	dw 0x08			; code selector
	db 0			; 
	db 0x8E			; 1000 1110 P: 1 DPL: 00 D: 1
	dw 0x0001		; 핸들러의 상위 16bit 오프셋

times 512-($-$$) db 0

