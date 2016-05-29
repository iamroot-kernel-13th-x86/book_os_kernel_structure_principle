[org 0x80004000]
[bits 32]
user_process5:
mov eax, 80*2*9+2*5
lea ebx, [msg_user_process5_1]
int 0x80
mov eax, 80*2*10+2*5
lea ebx, [msg_user_process5_2]
int 0x80
inc byte [msg_user_process5_2]
jmp user_process5
		
msg_user_process5_1 db "User Process5", 0
msg_user_process5_2 db ".I'm running now.", 0

times 512-($-$$) db 0
