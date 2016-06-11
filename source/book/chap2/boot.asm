[org 0]     ; org는 ip값으로 세팅<-
				; https://en.wikibooks.org/wiki/X86_Assembly/Machine_Language_Conversion
            jmp 07C0h:start     ; 0x07c0:start -> 0x07c0:0x5 -> 0x07c05
				; cs = 0x07c0, ip 0x05
				; 00000000  EA0500C007        jmp 0x7c0:0x5
				; ea 05 00 00 00 c0 07    jmp    0x7c0:0x5
				; https://ko.wikipedia.org/wiki/JMP_(x86_%EB%AA%85%EB%A0%B9%EC%96%B4)


start:
            
            mov ax, cs
            mov ds, ax
            mov es, ax
  
            mov ax, 0xB800	    	; video mem area : 0xB8000
	    mov es, ax	    	
	    mov di, 0		; 받는 입장에서는 일반적으로..  destination -  offset으로  
	    mov ax, word [msgBack] 	 ; word 2byte 16bit
	    mov cx, 0x7FF   		    	; 7FF만큼 loop돌리기위함. (mbr영역)
paint:
	    mov word [es:di], ax; es:di = 0xB800:0x0 -> OxB8000 + 2byte, ax = msgBack
	    add di,2		 ; di 0 -> 2
	    dec cx		 ;  0x7FF - 1(bit)
	    jnz paint	   	 ; jump not zero -> paint ===> cx == 0 종료
                                 ; eflags reg => cx==0인경우 zero register의 값이1로 변함
			   

read:
            mov ax, 0x1000      ; ES:BX = 1000:0000 
            mov es, ax          ;
            mov bx, 0           ;

            mov ah, 2           ; 디스크에 있는 데이터를 es:bx 의 주소로  
				; 47page 참고, ah, al, ch, cl, dh  ah = bios call number <- 
            mov al, 1           ; 1 섹터를 읽을 것이다. sector start 1 = mbr( 512byte)
            mov ch, 0           ; 0번째 Cylinder ; bios에 고정된 cylinder, sector size가 다름.... -> 제조사 firmware값? bios표준??? 
            mov cl, 2           ; 2번째 섹터부터 읽기 시작한다.  c: counter
            mov dh, 0           ; Head=0 ; 0 앞 1 뒤 - 플래터마다 2개의 헤드가 존재
;            mov dl, 0x80           ; Drive=0  A:드라이브 d: data
            mov dl, 0x0           ; Drive=0  A:드라이브 d: data
            int 0x13            ; Read!
				; int 0x13이 발생되면 ah -> al -ch cl dh dl
				; hdd 구조  http://forensic-proof.com/archives/355

            jc read             ; 에러가 나면, 다시 함. jc -> jump carry
				; carry flag: ex) 1 + 1 -> carry 발생

 	    jmp 0x1000:0000     ; kernel.bin 이 위치한 곳으로 점프한다.
				; jmp를 통해 cs에 0x1000이 저장됨

	    msgBack db '1', 0x67 ; define byte :  '' 문자 하나, "" 문자열, 문자, 배경색, 전경

	    times 510-($-$$) db 0  ; 39page 참조, 참고이미지(https://raw.githubusercontent.com/iamroot-kernel-13th-x86/book_os_kernel_structure_principle/master/resource/image/mbr_mem.png)
            dw 0AA55h        ; define word -> 0??h hex 표현법 0 없어도 됨.

