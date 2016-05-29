%include "init.inc"

PAGE_DIR        equ 0x100000
PAGE_TAB_KERNEL equ 0x101000
PAGE_TAB_USER   equ 0x102000
PAGE_TAB_LOW    equ 0x103000

[org 0x90000]
[bits 16]
start:
	cld			
	mov	ax,cs
	mov	ds,ax
	xor	ax,ax
	mov	ss,ax

	xor eax, eax
   	lea eax,[tss]          ; EAX에 tss의 물리주소를 넣는다.
	add eax, 0x90000
    	mov [descriptor4+2],ax
    	shr eax,16
   	mov [descriptor4+4],al
    	mov [descriptor4+7],ah

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

        mov esi, 0x80000              ; 커널을 물리주소 0x200000 에 옮긴다.
        mov edi, 0x200000
        mov cx, 512*NumKernelSector
kernel_copy:
        mov al, byte [ds:esi]
        mov byte [es:edi], al
        inc esi
        inc edi
        dec cx
        jnz kernel_copy



	mov edi, PAGE_DIR
	mov eax, 0                 ; not present
	mov ecx, 1024              ; 페이지 갯수
	cld
	rep stosd

        mov edi, PAGE_DIR
        mov eax, 0x103000
        or  eax, 0x01
        mov [es:edi], eax        
	
	mov edi, PAGE_DIR+0x200*4  ; 0x80000000 의 상위 10비트*4
	mov eax, 0x102000
	or eax, 0x07               ; 유저 영역임을 표시
	mov [es:edi], eax

	mov edi, PAGE_DIR+0x300*4  ; 0xC0000000 의 상위 10비트*4
        mov eax, 0x101000
        or eax, 0x01               ; 커널 영역임을 표시
        mov [es:edi], eax

        mov edi, PAGE_TAB_KERNEL   ; 0x101000 ~ 0x101FFF 까지 not present 로 초기화 한다.
	mov eax, 0                 ; not present
	mov ecx, 1024              ; 페이지 갯수
	cld
	rep stosd	

        mov edi, PAGE_TAB_KERNEL+0x000*4
        mov eax, 0x200000          ; 커널은 2개의 페이지를 사용한다.
        or  eax, 1                 ; 0x200000 에서 4096*2 바이트의 영역이다.
        mov [es:edi], eax          ; 가상 메모리 0xC0000000 에서 4096*2 바이트의 영역

        mov edi, PAGE_TAB_KERNEL+0x001*4
        mov eax, 0x201000
        or  eax, 1
        mov [es:edi], eax

        mov edi, PAGE_TAB_KERNEL+0x002*4
        mov eax, 0x202000          ; IDT가 사용하는 페이지 
        or  eax, 1                 ; 유저모드에서는 접근하면 안됨.
        mov [es:edi], eax

        mov edi, PAGE_TAB_USER     ; 0x102000 ~ 0x102FFF 까지 not present 로 초기화 한다.
	mov eax, 0x00              ; not present
	mov ecx, 1024              ; 페이지 갯수
	cld
	rep stosd	

        mov edi, PAGE_TAB_USER+0x000*4
        mov eax, 0x300000          ; 유저 프로그램1의 영역
        or  eax, 0x07              ; 물리 메모리 0x300000 에서 4096 바이트 만큼의 영역
        mov [es:edi], eax          ; 가상 메모리 0x80000000 에서 4066 바이트 만큼의 영역

        mov edi, PAGE_TAB_USER+0x001*4
        mov eax, 0x301000          ; 유저 프로그램2의 영역
        or  eax, 0x07              
        mov [es:edi], eax

        mov edi, PAGE_TAB_USER+0x002*4
        mov eax, 0x302000          ; 유저 프로그램3의 영역
        or  eax, 0x07
        mov [es:edi], eax

        mov edi, PAGE_TAB_USER+0x003*4
        mov eax, 0x303000          ; 유저 프로그램4의 영역
        or  eax, 0x07
        mov [es:edi], eax

        mov edi, PAGE_TAB_USER+0x004*4
        mov eax, 0x304000          ; 유저 프로그램5의 영역
        or  eax, 0x07
        mov [es:edi], eax

        mov edi, PAGE_TAB_LOW      ; 1MB 이하의 영역을  
        mov eax, 0x00000           ; 256 개의 페이지로 매핑함.
        or  eax, 0x01              ; 256*4096 = 1048576 = 0x100000  
        mov cx, 256
page_low_loop:
        mov [es:edi], eax
        add eax, 0x1000
	add edi, 4
        dec cx
        jnz page_low_loop

	mov eax, PAGE_DIR          ; 페이지 디렉토리의 맨 앞 주소를
	mov cr3, eax               ; CR3 레지스터에 등록한다.

	mov eax, cr0               ; CR0 레지스터에 
	or eax, 0x80000000         ; 이제 부터 페이징 구조를 사용한다는
	mov cr0, eax               ; 표시를 한다.

        lea eax, [tss]             ; C언어로 이루어진 kernel.bin 에서 
        mov [TSS_WHERE], eax       ; TSS를 사용하므로, TSS의  
                                   ; 주소를 기록해 둔다.
	mov esp, 0xC0001FFF        ; 커널 모드의 스택주소를
                                   ; 커널이 위치한 페이지의 제일 마지막 부분을
                                   ; 가리키게 해둔다.

        jmp 0xC0000000             ; 커널로 점프한다.


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
gdt_end:




tss: 
   	 dw 0, 0                ; 이전 태스크로의 back link
tss_esp0:
    	dd 0xC0001FFF           ; ESP0
        dw SysDataSelector, 0   ; SS0, 사용안함
        dd 0                    ; ESP1
        dw 0, 0                 ; SS1, 사용안함
   	dd 0                    ; ESP2
    	dw 0, 0                 ; SS2, 사용안함
   	dd 0x100000
tss_eip:
        dd 0, 0                 ; EIP, EFLAGS
        dd 0, 0, 0, 0
tss_esp:
        dd 0, 0, 0, 0           ; ESP, EBP, ESI, EDI
        dw 0, 0                 ; ES, 사용안함
        dw 0, 0                 ; CS, 사용안함
        dw UserDataSelector, 0 	; SS, 사용안함
        dw 0, 0                 ; DS, 사용안함
        dw 0, 0                 ; FS, 사용안함
        dw 0, 0                 ; GS, 사용안함
        dw 0, 0                 ; LDT, 사용안함
        dw 0, 0                 ; 디버그용 T비트, IO 허가 비트맵


times 1024-($-$$) db 0

