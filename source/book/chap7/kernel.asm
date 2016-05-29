%include "init.inc"

[org 0x10000]
[bits 16]

start:
	cld			
	mov	ax,cs
	mov	ds,ax
	xor	ax,ax
	mov	ss,ax

	xor eax, eax
   	lea eax,[tss]                 ; EAX에 tss의 물리주소를 넣는다.
	add eax, 0x10000
    	mov [descriptor4+2],ax
    	shr eax,16
   	mov [descriptor4+4],al
    	mov [descriptor4+7],ah

	xor eax, eax
	lea eax, [printf]	      ; EAX에 printf 함수의 주소를 넣는다.
	add eax, 0x10000
	mov [descriptor7], ax
	shr eax, 16
	mov [descriptor7+6], al
	mov [descriptor7+7], ah	

	cli
        lgdt[gdtr]

        mov eax, cr0
        or eax, 0x00000001
        mov cr0, eax

        jmp $+2
 	nop
	nop

        jmp dword SysCodeSelector:PM_Start

[bits 32]

PM_Start:
	
	mov bx, SysDataSelector
	mov ds, bx
	mov es, bx
	mov fs, bx
	mov gs, bx
	mov ss, bx

	lea esp, [PM_Start]

	mov ax, TSSSelector
	ltr ax

	mov [tss_esp0],esp	   ; 특권레벨0 의 스택을 TSS에 지정해 둔다.
	lea eax, [PM_Start-256]
	mov [tss_esp],eax	   ; 특권레벨3 의 스택을 TSS에 지정해 둔다.

	mov ax, UserDataSelector   ; 데이터 세그먼트를 유저모드로 지정해 둔다.
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	lea esp, [PM_Start-256]	

	push dword UserDataSelector   ; SS
	push esp		      ; ESP
	push dword 0x200	      ; EFLAGS
	push dword UserCodeSelector   ; CS
	lea eax,[user_process]
	push eax		      ; EIP
	iretd			      ; 유저모드 태스크로 점프

;**************************************
;*********   Subrutines   *************
;**************************************
printf:
	mov ebp, esp
	push es
	push eax
	mov ax, VideoSelector
	mov es, ax
	mov esi, [ebp+8]	
	mov edi, [ebp+12]

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
	pop eax
	pop es
	ret	

user_process:
	mov edi, 80*2*7
	push edi                       ;인수를 유저모드 스택에 저장한다.
	lea eax, [msg_user_parameter1]
	push eax
	call 0x38:0                    ;콜게이트를 통하여 커널루틴을 호출.
	jmp $
		
msg_user_parameter1 db "This is User Parameter1", 0

;***************************************
;**********   Data Area   **************
;***************************************
gdtr:	dw	gdt_end-gdt-1
	dd	gdt
gdt:
	dd 0, 0
	dd 0x0000FFFF, 0x00CF9A00
	dd 0x0000FFFF, 0x00CF9200
	dd 0x8000FFFF, 0x0040920B

descriptor4:				;TSS 디스크립터
	dw 104
	dw 0
	db 0
	db 0x89
	db 0
	db 0

	dd	0x0000FFFF, 0x00FCFA00  ;유저 코드 세그먼트
	dd	0x0000FFFF, 0x00FCF200  ;유저 데이터 세그먼트

descriptor7:                            ;콜게이트 디스크립터
	dw 0
	dw SysCodeSelector
	db 0x02
	db 0xEC
	db 0 
	db 0 
gdt_end:

tss: 
    dw 0, 0                 ; 이전 태스크로의 back link
tss_esp0:
    dd 0                    ; ESP0
    dw SysDataSelector, 0   ; SS0, 사용안함
    dd 0                    ; ESP1
    dw 0, 0                 ; SS1, 사용안함
    dd 0                    ; ESP2
    dw 0, 0                 ; SS2, 사용안함
    dd 0
tss_eip:
    dd 0, 0                 ; EIP, EFLAGS
    dd 0, 0, 0, 0
tss_esp:
    dd 0, 0, 0, 0           ; ESP, EBP, ESI, EDI
    dw 0, 0                 ; ES, 사용안함
    dw 0, 0                 ; CS, 사용안함
    dw UserDataSelector, 0  ; SS, 사용안함
    dw 0, 0                 ; DS, 사용안함
    dw 0, 0                 ; FS, 사용안함
    dw 0, 0                 ; GS, 사용안함
    dw 0, 0                 ; LDT, 사용안함
    dw 0, 0                 ; 디버그용 T비트, IO 허가 비트맵

times 1024-($-$$) db 0

