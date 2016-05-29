[org 0x80002000]
[bits 32]
user_process3:
mov eax, 80*2*5+2*5
lea ebx, [msg_user_process3_1]
int 0x80
mov eax, 80*2*6+2*5
lea ebx, [msg_user_process3_2]
int 0x80
inc byte [msg_user_process3_2]
jmp user_process3
		
msg_user_process3_1 db "User Process3", 0
msg_user_process3_2 db ".I'm running now.", 0

times 512-($-$$) db 0
