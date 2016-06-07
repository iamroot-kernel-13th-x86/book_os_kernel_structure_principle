%include "init.inc"

[org 0x10000]
[bits 32]

PM_Start:
	
	mov bx, SysDataSelector ; 초기화(16 -> 32bit)
	mov ds, bx
	mov es, bx
	mov fs, bx
	mov gs, bx
	mov ss, bx

	lea esp, [PM_Start] 	; PM_Start = 0x10000의 값 esp

	mov edi, 0		; 
	lea esi, [msgPMode]	; "We are in Protected Mode", 0
	call printf		;

	cld			; cld: clear the direction flag 
				; 주소를 복사할의 방향을 초기화
				; 방향?
	mov ax, SysDataSelector ;SysDataSelector =  0x8
	mov es, ax			
	xor eax, eax		; 0 초기화
	xor ecx, ecx		; 
	mov ax,256		; IDT 영역에 256개의 
	mov edi, 0              ; 디스크립터를 복사한다.

 loop_idt:			; 
	lea esi, [idt_ignore]	
	mov cx,8		; 디스크립터 하나는 8바이트이다.
	rep movsb		; rep - Repeat while ECX not zero 
				; movesb - Move byte string
				; ecx를 사용
				; movesb 사용시- edi esi 1 byte 증가 - cli와 관련
				; 111p 참조
	dec ax			; ax가 0이되면 loop end
	jnz loop_idt

	lidt [idtr]		; Load interrupt descriptor table (IDT) register
				; iterrupt descriptor table 등록 
	
	sti			; 인터럽트 차단 해제 
	int 0x77		; 77번 인터럽트 발생
        jmp $	

;**************************************
;*********   Subrutines   *************
;**************************************
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

;***************************************
;**********   Data Area   **************
;***************************************
msgPMode db "We are in Protected Mode", 0	
msg_isr_ignore db "This is an ignorable interrupt", 0
msg_isr_32_timer db ".This is the timer interrupt", 0


;****************************************
;****   Interrupt Service Rutines  ******
;****************************************
isr_ignore:		;interrup handler
			; 현재 상태 저장
	push gs
	push fs
	push es
	push ds
	pushad		;범용 레지스터 전부 스택에 넣는다
	pushfd		; eflags를 스택에 저장
			; https://en.wikipedia.org/wiki/FLAGS_register

	mov ax, VideoSelector
	mov es, ax
	mov edi, (80*7*2)
	lea esi, [msg_isr_ignore]
	call printf
			; 인터럽트 종료후 
			; 이전 상태 복원
	popfd		; cs eip esp ??
	popad		; 나머지 
	pop ds
	pop es
	pop fs
	pop gs
	
	iret		;iterrup return



;****************************************
;*************   IDT   ******************
;****************************************
idtr:	
	dw	256*8-1		; IDT 의 Limit 
	dd	0       	; IDT 의 Base Address

idt_ignore:	
	dw isr_ignore		;0 번지의 isr_ignore를 가리킴
	dw SysCodeSelector
	db 0
	db 0x8E
	dw 0x0001

times 512-($-$$) db 0

