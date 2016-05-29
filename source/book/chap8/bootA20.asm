[org 0]
            jmp 07C0h:start     

%include "a20.inc"

start:
            
            mov ax, cs
            mov ds, ax
            mov es, ax
	    mov ax, 0
            mov ss, ax
            mov esp, boot_stack

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

            call a20_try_loop
            
            push ds
            mov ax, 0
            mov ds, ax
            mov si, 1
            mov word [ds:si], 0

            mov ax, 0xFFFF
            mov ds, ax
            mov si, 0x11
            mov word [ds:si], 0x1234

            mov ax, 0
            mov ds, ax
            mov si, 1
            mov bx, word [ds:si]
            pop ds
            cmp bx, 0x1234
            je noA20
            
yesA20:
            mov ax, 0xB800
            mov es, ax
            mov di, 0
            lea si, [msgA20on]
yes_loop:            
            mov al, byte [si]
            cmp al, 0
            je stop
            mov byte [es:di], al
            inc si
            inc di
            mov byte [es:di], 0x06
            inc di
            jmp yes_loop

noA20:	   
            mov ax, 0xB800
            mov es, ax
            mov di, 0
            lea si, [msgA20off]
no_loop:            
            mov al, byte [si]
            cmp al, 0
            je stop
            mov byte [es:di], al
            inc si
            inc di
            mov byte [es:di], 0x06
            inc di
            jmp no_loop

stop:
            jmp $

msgBack db '.', 0x67
msgA20on db "A20 on ", 0
msgA20off db "A20 off", 0	    

	    times 64 db 0
boot_stack:	 
	    times 510-($-$$) db 0
            dw 0AA55h

