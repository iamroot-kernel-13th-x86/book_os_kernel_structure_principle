[org 0]
[bits 16]
	jmp 0x07C0:start    	;far jmp 를 한다.

start:
	mov ax, cs	    	;cs 에는 0x07C0 이 들어 있다.
	mov ds, ax 	    	;ds 를 cs 와 같게 해준다.

 jmp $


times 510-($-$$) db 0		;여기서 부터, 509 번지까지 0 으로 채운다.
		 dw 0xAA55	;510 번지에 0xAA 를, 511 번지에 0x55 를 넣어 둔다.
