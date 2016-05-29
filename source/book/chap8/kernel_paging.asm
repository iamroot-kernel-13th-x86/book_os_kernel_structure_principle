%include "init.inc"

[org 0xC0000000]
[bits 32]

	mov esp, 0xC0000FFF

%include "idt0.inc"

	lidt [idtr]		; IDT를 등록한다.

	mov al, 0xFC            ; 막아두었던 인터럽트 중, 
	out 0x21, al		; 타이머와 키보드만 다시 유효하게 한다.
	sti

	mov ax, TSSSelector
	ltr ax

	mov eax, [CurrentTask]  ; Task Struct의 리스트를 만든다.
	add eax, TaskList
	lea edx, [User1regs]
	mov [eax], edx  
	add eax, 4
	lea edx, [User2regs]
	mov [eax], edx	
	add eax, 4
	lea edx, [User3regs]
	mov [eax], edx	
	add eax, 4
	lea edx, [User4regs]
	mov [eax], edx	
	add eax, 4
	lea edx, [User5regs]
	mov [eax], edx	

	mov eax, [CurrentTask]  ; 첫 번째 Task를 선택한다. (CurrentTask = 0)
	add eax, TaskList
	mov ebx, [eax]
	jmp sched

scheduler:
	lea esi,[esp]           ; 커널 ESP에는 유저 레지스터들이 있다.

	xor eax, eax	
	mov eax, [CurrentTask]
	add eax, TaskList

	mov edi,[eax]           ; 현재 실행 중인 태스크의 저장영역을 선택한다.

	mov ecx,17              ; 17개의 DWORD(68 BYTE) 모든 레지스터의 바이트 합.
	rep movsd               ; 복사하고, 
	add esp,68              ; 17개의 DWORD 만큼 스택을 되돌려 놓는다.

	add dword [CurrentTask], 4	
	mov eax, [NumTask]
	mov ebx, [CurrentTask]
	cmp eax, ebx
	jne yet
	mov byte [CurrentTask], 0
yet:
	xor eax, eax
	mov eax, [CurrentTask]
	add eax, TaskList
	mov ebx, [eax]
sched:

        mov eax, [TSS_ESP0_WHERE]
        mov [eax], esp          ; 커널영역의 스택주소를 TSS에 기입해 둔다.
	                        

	lea esp,[ebx]           ; EBX에는 다음 태스크의 저장영역의 주소가 있다.

	popad                   ; EAX, EBX, ECX, EDX, EBP, ESI, EDI 를 복원한다.
	pop ds                  ; DS, ES, FS, GS 복원한다.
	pop es
	pop fs
	pop gs

	iretd                   ; 다음 유저 태스크로 스윗칭 된다.

CurrentTask dd 0                ; 현재 실행 중인 태스크 번호
NumTask dd 20                   ; 모든 태스크의 수
TaskList: times 5 dd 0          ; 각 태스크 저장영역의 포인터 배열


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


;**************************************
;*******   Task Structures   **********
;**************************************

%include "user_task_structure.inc"

;****************************************
;****   Interrupt Service Rutines  ******
;****************************************

%include "idt1.inc"

;****************************************
;*************   IDT   ******************
;****************************************

idtr:	dw	256*8-1		; IDT 의 Limit 
	dd	IDT_BASE        ; IDT 의 Base Address

%include "idt2.inc"

times 512*7-($-$$) db 0

