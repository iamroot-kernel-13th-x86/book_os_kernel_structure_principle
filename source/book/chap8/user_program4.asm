[org 0x80003000]
[bits 32]
user_process4:
mov eax, 80*2*5+2*35
lea ebx, [msg_user_process4_1]
int 0x80
mov eax, 80*2*6+2*35
lea ebx, [msg_user_process4_2]
int 0x80
inc byte [msg_user_process4_2]
jmp user_process4
		
msg_user_process4_1 db "User Process4", 0
msg_user_process4_2 db ".I'm running now.", 0

times 512-($-$$) db 0
