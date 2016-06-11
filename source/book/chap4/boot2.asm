%include "init.inc"

[org 0]
            jmp 07C0h:start     

start:
            
            mov ax, cs
            mov ds, ax
            mov es, ax

reset:                          ; 플로피 디스크를 리셋한다.
            mov ax, 0           ;
            mov dl, 0           ; Drive=0 (A:)
            int 13h             ;
            jc reset            ; 에러가 나면 다시한다.

 
            mov ax, 0xB800	    	
	    mov es, ax	    	
	    mov di, 0		
	    mov ax, word [msgBack] 	
	    mov cx, 0x7FF 		    	
paint:
	    mov word [es:di], ax
	    add di,2		
	    dec cx		    
	    jnz paint	   	

read:
            mov ax, 0x1000      ; ES:BX = 1000:0000
            mov es, ax          ;
            mov bx, 0           ;

            mov ah, 2           ; 디스크에 있는 데이터를 es:bx 의 주소로  
            mov al, 1           ; 1 섹터를 읽을 것이다.
            mov ch, 0           ; 0번째 Cylinder
            mov cl, 2           ; 2번째 섹터부터 읽기 시작한다. 
            mov dh, 0           ; Head=0
            mov dl, 0           ; Drive=0  A:드라이브
            int 13h             ; Read!

            jc read             ; 에러가 나면, 다시 함. 

	    mov dx, 0x3F2	; 플로피 디스크 드라이브의
	    xor al, al          ; 모터를 끈다.
	    out dx, al

	    cli			; cpu단 인터럽트 
; 마스터 PIC       ; out IO 전용
					; IO port 20에 0x11 b00010001
					; LTIM (https://books.google.co.kr/books?id=INrGtjM9VI0C&pg=PA210&lpg=PA210&dq=ltim+interrupt&source=bl&ots=AP0kW1Xkd3&sig=FW2Ir1r9N6fh8I1mzuCrk6q98z4&hl=ko&sa=X&ved=0ahUKEwjww6ietZ_NAhUGo5QKHeB-CBcQ6AEIHDAA#v=onepage&q=ltim%20interrupt&f=false)
;IO 20 command port - 초기화 ICW1

            mov	al, 0x11		; PIC의 초기화 (PIC: 0x0020-0x0021)
					; PIC(http://wiki.osdev.org/PIC)
	    out	0x20, al
	    dw	0x00eb, 0x00eb		; jmp $+2, jmp $+2 
					; eb(http://x86.renejeschke.de/html/file_module_x86_id_147.html)
					; delay
	    out	0xA0, al		; 슬레이브 PIC(0x00A0-0x00A1	The second PIC)
	    dw	0x00eb, 0x00eb		; jmp $+2, jmp $+2 

; IO 21 data port -   ICW2~4
	    mov	al, 0x20		; 마스터 PIC 인터럽트 시작점
	    out	0x21, al		; ICW2

	    dw	0x00eb, 0x00eb


	    mov	al, 0x28		; 슬레이브 PIC 인터럽트 시작점
					; 0x28 b00101000	
   	    out	0xA1, al		; slave ICW2		
	    dw	0x00eb, 0x00eb

	    mov	al, 0x04		; 마스터 PIC의 IRQ2번에 
	    out	0x21, al		; 슬레이브 PIC이 연결되어 있다.
					; ICW3
	    dw	0x00eb, 0x00eb
	    mov	al, 0x02		; 슬레이브 PIC이 마스터 PIC의
	    out	0xA1, al		; IRQ2번에 연결되어 있다.
					; slave ICW3
	    dw	0x00eb, 0x00eb

	    mov	al, 0x01		; 8086 모드를 사용한다.
	    out	0x21, al		; ICW4
					; 0010 0001
					; AEOI 0 - 수동	
					; 수동으로 하는 이유는 다른 인터럽트로인해 꼬임 방지용
					; kernel2.asm out
					; 0x20 al(0x20) - 인터럽트 차단 해제 
					; AEOI - End of interrupt : 
	    dw	0x00eb, 0x00eb	
	    out	0xA1, al		; slave ICW4
	    dw	0x00eb, 0x00eb

	    mov	al, 0xFF		; 슬레이브 PIC의 모든 인터럽트를 
					; IMR에 oxff b11111111 8개 bit마다 매핑되어있는 각각의 인터럽트를 차단
					; PIC interrup registers: ISR, IRR, IMR
					; ox20, A0 (ICW1, OCW2,3이 공유)
					; ICW 0001xxxx
					; OCW2 0010xxxx
					; OCW3 0000xxxx
					; ICW1의 값을 정의하면 다음부터는 ICW2~4세팅으로 인식
					; ICW1이 안오면 OCW2,3이 온다고 기대함.
	    out	0xA1, al		; 막아 둔다.
  	    dw	0x00eb, 0x00eb
					; OCW값 세팅
	    mov	al, 0xFB		; 마스터 PIC의 IRQ2번을 제외한
	    out	0x21, al		; 모든 인터럽트를 막아 둔다.

	    lgdt[gdtr]

            mov eax, cr0
	    or eax, 0x00000001
	    mov cr0, eax

 	    jmp $+2
 	    nop
	    nop

	    mov bx, SysDataSelector
	    mov ds, bx
	    mov es, bx
	    mov fs, bx
	    mov gs, bx
	    mov ss, bx

            jmp dword SysCodeSelector:0x10000

	    msgBack db '.', 0x67


gdtr:	dw gdt_end - gdt - 1	; GDT의 limit
	dd gdt+0x7C00           ; GDT의 베이스 어드레스
gdt:
	dd 0, 0
	dd 0x0000FFFF, 0x00CF9A00
	dd 0x0000FFFF, 0x00CF9200
	dd 0x8000FFFF, 0x0040920B
gdt_end:
	    times 510-($-$$) db 0
            dw 0AA55h

