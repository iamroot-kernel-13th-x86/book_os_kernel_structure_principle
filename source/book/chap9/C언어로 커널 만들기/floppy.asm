segment .text

[global _FloppyMotorOn]
[global _FloppyMotorOff]
[global _initializeDMA]
[global _FloppyCode]
[global _ResultFhase]
[global _inb]
[global _outb]

_FloppyMotorOn:
	push edx
	push eax

	mov al, 0x1c
	mov dx, 0x3f2
	out dx, al

	pop eax
	pop edx
ret




_FloppyMotorOff:
	push edx
	push eax

        mov dx, 0x3F2	; 플로피 디스크 드라이브의
        xor al, al      ; 모터를 끈다.
        out dx, al	
	
	pop eax
	pop edx
ret




_initializeDMA:
	push ebp
	mov ebp, esp

	push eax	

	mov al, 0x14
	out 0x08, al       ; DMA를 deactive 한다.

	mov al, 1
	out 0x0c, al       ; flip-flop 을 리셋한다.

	mov al, 0x56
	out 0x0b, al       ; mode register

	mov al, 1          ; flip-flop 을 리셋한다.
	out 0x0c, al       

	mov eax, dword [ebp+0x0C] 
	out 0x04, al       ; 오프셋의 Low byte
	mov al, ah
	out 0x04, al       ; 오프셋의 High byte 

	mov eax, dword [ebp+0x08]
	out 0x81, al       ; Page 

	mov al, 1
	out 0x0c, al       ; flip-flop 을 리셋한다.

	mov al, 0xff
	out 0x05, al       ; count 의 Low byte

	mov al, 1
        out 0x05, al       ; count 의 High byte

	mov al, 0x02
	out 0x0a, al       ; channel 2의 mask 해제

	mov al, 0x10
	out 0x08, al       ; DMA active 상태로 한다.

	pop eax

	mov esp, ebp
	pop ebp
ret

; I/O 포트를 읽어 들인다.
_inb:   
	push ebp
	mov ebp, esp

	push edx
	
	xor eax, eax
	mov edx, dword [ebp+0x08]
	in al, dx

	pop edx

	mov esp, ebp
	pop ebp
ret

; I/O 포트에 출력한다.
_outb:
	push ebp
	mov ebp, esp

	push eax
	push edx
	
	xor eax, eax
	mov eax, dword [ebp+0x0C]
	mov edx, dword [ebp+0x08]
	out dx, al

	pop edx
	pop eax

	mov esp, ebp
	pop ebp
ret

; FDC에서 결과 값을 가져온다.
_ResultFhase:
	push edx

	mov dx, 0x3F5
	in al, dx

	pop edx
ret	







