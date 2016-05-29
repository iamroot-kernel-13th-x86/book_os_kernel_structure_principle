[org 0x80000000]
[bits 32]
user_process1:
mov eax, 80*2*2+2*5
lea ebx, [msg_user_process1_1]
int 0x80
mov eax, 80*2*3+2*5
lea ebx, [msg_user_process1_2]
int 0x80
inc byte [msg_user_process1_2]
jmp user_process1
		
msg_user_process1_1 db "User Process1", 0
msg_user_process1_2 db ".I'm running now.", 0

times 512-($-$$) db 0
