[org 0]
[bits 16]
	jmp 0x07C0:start    	;far jmp 를 한다.

start:
	mov ax, cs	    	;cs 에는 0x07C0 이 들어 있다.
	mov ds, ax 	    	;ds 를 cs 와 같게 해준다.

        mov ax, 0xB800	    	;비디오 메모리의 세그먼트를
	mov es, ax	    	;es 레지스터에 넣는다.
	mov di, 0		;제일 윗 줄의 처음에 쓸 것이다.
	mov ax, word [msgBack] 	;써야 할 데이터의 주소값을 지정한다. 
	mov cx, 0x7FF       	;화면 전체에 쓰기 위해서는 
			    	;0x7FF(10진수 2047)개의 WORD 가 필요하다.
paint:
	mov word [es:di], ax	;비디오 메모리에 쓴다.
	add di,2		;한 WORD를 썼으므로, 2를 더한다.
	dec cx		    	;한 WORD를 썼으므로, CX 의 값을 하나 줄인다.
	jnz paint	   	;CX 가 0이 아니면, paint로 점프하여
			   	;나머지를 더 쓴다.


	mov edi, 0		;제일 윗 줄의 처음에 쓸 것이다.
	mov byte [es:edi], 'A'  ;비디오 메모리에 쓴다.
	inc edi			;한 개의 BYTE를 썼으므로 1을 더한다.
	mov byte [es:edi], 0x06 ;배경색을 쓴다.
	inc edi			;한 개의 BYTE를 썼으므로 1을 더한다.
	mov byte [es:edi], 'B'
	inc edi
	mov byte [es:edi], 0x06
	inc edi
	mov byte [es:edi], 'C'
	inc edi
	mov byte [es:edi], 0x06
	inc edi
	mov byte [es:edi], '1'
	inc edi
	mov byte [es:edi], 0x06
	inc edi
	mov byte [es:edi], '2'
	inc edi
	mov byte [es:edi], 0x06
	inc edi
	mov byte [es:edi], '3'
	inc edi
	mov byte [es:edi], 0x06

	jmp $			;이 번지에서 무한루프를 돈다.

msgBack db '.', 0xE7		;배경색으로 사용할 데이터

times 510-($-$$) db 0		;여기서 부터, 509 번지까지 0 으로 채운다.
		 dw 0xAA55	;510 번지에 0xAA 를, 511 번지에 0x55 를 넣어 둔다.

