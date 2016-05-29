%include "init.inc"

[org 0]
            jmp 07C0h:start     

start:
            
            mov ax, cs
            mov ds, ax
            mov es, ax
  
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

	    cli

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


gdtr:	
	dw gdt_end - gdt - 1	; GDT의 limit
	dd gdt+0x7C00           ; GDT의 베이스 어드레스
gdt:
	dd 0, 0
	dd 0x0000FFFF, 0x00CF9A00
	dd 0x0000FFFF, 0x00CF9200
	dd 0x8000FFFF, 0x0040920B
gdt_end:
	    times 510-($-$$) db 0
            dw 0AA55h

