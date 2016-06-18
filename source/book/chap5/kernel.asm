%include "init.inc"

[org 0x10000]
[bits 16]

start:


	cld			; Advance = inc -> direction inc
	mov	ax,cs
	mov	ds,ax
	xor	ax,ax
	mov	ss,ax


	xor ebx, ebx
   	lea eax,[tss1]    ; EAX에 tss1의 물리주소를 넣는다.
	add eax, 0x10000	; tss1 + 0x10000
    	mov [descriptor4+2],ax  ; limit 2byte를 건너뛰기 위함.
				; 상위 16를 접근할 수 없으니까 하위 16를 넣고 (ax만 접근 eax 풀로 사용 불가)
    	shr eax,16		; base Address  
				; eax right shift -> 상위 16비트의 값을 가져오기 위해 shr
   	mov [descriptor4+4],al	; 1byte
				; base address 16~ 23 값 
    	mov [descriptor4+7],ah	; 1byte base address의 24~31
				; base address를 가져옴.

    	lea eax,[tss2]    ; EAX에 tss2의 물리주소를 넣는다. 
	add eax, 0x10000
    	mov [descriptor5+2],ax
    	shr eax,16
    	mov [descriptor5+4],al
    	mov [descriptor5+7],ah

    	;mov [descriptor5+2],ax
    	;mov [descriptor5+4],al
    	;mov [descriptor5+7],ah
		

; tss 초기화 종료

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

	mov ax, TSS1Selector	; gdt index 4
				; 현재 진행중인 task를  tss1이 가지고 있기위한 행위
	ltr ax			; cpu tr register에 tss디스크립터 셀렉터 값을 넣는다.
				; task switch를 할때 일부 값들은  cpu가 자동으로 저장  
	lea eax, [process2]	; 그림5-6 TSS중 값

	mov [tss2_eip], eax	; 실행될 task의 주소
				; process2의 주소를  tss2_eip에 저장
	mov [tss2_esp], esp 	; 현재 스택  포인터를 tss2_esp에 저장	
				; 호출할 주소의 값을 초기화

	jmp TSS2Selector:0	; p179 태스크 스위칭 흐름도 참조
				; 32bit GDT를 이용하여 jmp
				; 다시 태스크 스윗칭이 되면 이곳으로 돌아온다.

	mov edi, 80*2*9
	lea esi, [msg_process1]
	call printf
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

process2:
	mov edi, 80*2*7
	lea esi, [msg_process2]
	call printf
	jmp TSS1Selector:0		; selector가 tss이기 때문에 
					; s비트가 system bit이때문에 cpu가 알아서
					; 44bit - 70p에 s비트 설명이 나옴
					; system bit는 0
					; code/data  세그먼트 1 
					; p197 5-9의 과정이 이루어짐 
		
;***************************************
;**********   Data Area   **************
;***************************************

msg_process1 db "This is System Process 1", 0
msg_process2 db "This is System Process 2", 0



gdtr:	dw	gdt_end-gdt-1
	dd	gdt
gdt:
	dd 0, 0
	dd 0x0000FFFF, 0x00CF9A00
	dd 0x0000FFFF, 0x00CF9200
	dd 0x8000FFFF, 0x0040920B

descriptor4:
	dw 104
	dw 0			; tss 0
	db 0			; 1
	db 0x89	
	db 0			; 
	db 0			; 0

descriptor5:
	dw 104
	dw 0
	db 0
	db 0x89
	db 0
	db 0

gdt_end:

tss1:   
    dw 0, 0         ; 이전 태스크로의 back link
    dd 0            ; ESP0
    dw 0, 0         ; SS0, 사용안함
    dd 0            ; ESP1
    dw 0, 0         ; SS1, 사용안함
    dd 0            ; ESP2
    dw 0, 0         ; SS2, 사용안함
    dd 0, 0, 0      ; CR3, EIP, EFLAGS
    dd 0, 0, 0, 0       ; EAX, ECX, EDX, EBX
    dd 0, 0, 0, 0       ; ESP, EBP, ESI, EDI
    dw 0, 0         ; ES, 사용안함
    dw 0, 0         ; CS, 사용안함
    dw 0, 0         ; SS, 사용안함
    dw 0, 0         ; DS, 사용안함
    dw 0, 0         ; FS, 사용안함
    dw 0, 0         ; GS, 사용안함
    dw 0, 0         ; LDT, 사용안함
    dw 0, 0         ; 디버그용 T비트, IO 허가 비트맵

tss2: 
    dw 0, 0         ; 이전 태스크로의 back link
    dd 0            ; ESP0
    dw 0, 0         ; SS0, 사용안함
    dd 0            ; ESP1
    dw 0, 0         ; SS1, 사용안함
    dd 0            ; ESP2
    dw 0, 0         ; SS2, 사용안함
    dd 0
tss2_eip:
    dd 0, 0         ; EIP, EFLAGS (EFLAGS=0x200 for ints)
    dd 0, 0, 0, 0
tss2_esp:
    dd 0, 0, 0, 0       ; ESP, EBP, ESI, EDI
    dw SysDataSelector, 0  ; ES, 사용안함
    dw SysCodeSelector, 0  ; CS, 사용안함
    dw SysDataSelector, 0  ; SS, 사용안함
    dw SysDataSelector, 0  ; DS, 사용안함
    dw SysDataSelector, 0  ; FS, 사용안함
    dw SysDataSelector, 0  ; GS, 사용안함
    dw 0, 0         ; LDT, 사용안함
    dw 0, 0         ; 디버그용 T비트, IO 허가 비트맵

times 1024-($-$$) db 0		; sector 사이즈를 맞추기 위함.

