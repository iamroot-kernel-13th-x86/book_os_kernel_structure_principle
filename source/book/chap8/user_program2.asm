[org 0x80001000]
[bits 32]
user_process2:
mov eax, 80*2*2+2*35
lea ebx, [msg_user_process2_1]
int 0x80
mov eax, 80*2*3+2*35
lea ebx, [msg_user_process2_2]
int 0x80
inc byte [msg_user_process2_2]
jmp user_process2
		
msg_user_process2_1 db "User Process2", 0
msg_user_process2_2 db ".I'm running now.", 0

times 512-($-$$) db 0
