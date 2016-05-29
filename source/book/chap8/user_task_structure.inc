;****************************************
;******   User1 Task_Structure   ********
;****************************************
times 63 dd 0                   ; 유저 스택영역
User1Stack:
User1regs:	
dd 0, 0, 0, 0, 0, 0, 0, 0	; EDI, ESI, EBP, EBX, EDX, ECX, EBX, EAX
                                ; POPA 명령으로 모두 POP된다.
dw UserDataSelector, 0		; DS
dw UserDataSelector, 0		; ES
dw UserDataSelector, 0		; FS
dw UserDataSelector, 0		; GS
                                                
dd 0x80000000                     ; EIP
dw UserCodeSelector, 0		; CS
dd 0x200			; EFLAGS (0x200 enables ints)
dd 0x80000FFF			; ESP
dw UserDataSelector, 0		; SS
                                ; IRET 명령으로 모두 POP 된다.
;****************************************
;******   User2 Task_Structure   ********
;****************************************
times 63 dd 0                   ; 유저 스택영역
User2Stack:
User2regs:	
dd 0, 0, 0, 0, 0, 0, 0, 0	; EDI, ESI, EBP, EBX, EDX, ECX, EBX, EAX
                                ; POPA 명령으로 모두 POP된다.
dw UserDataSelector, 0		; DS
dw UserDataSelector, 0		; ES
dw UserDataSelector, 0		; FS
dw UserDataSelector, 0		; GS
                                                
dd 0x80001000                   ; EIP
dw UserCodeSelector, 0		; CS
dd 0x200			; EFLAGS (0x200 enables ints)
dd 0x80001FFF			; ESP
dw UserDataSelector, 0		; SS
                                ; IRET 명령으로 모두 POP 된다.
;****************************************
;******   User3 Task_Structure   ********
;****************************************
times 63 dd 0                   ; 유저 스택영역
User3Stack:
User3regs:	
dd 0, 0, 0, 0, 0, 0, 0, 0	; EDI, ESI, EBP, EBX, EDX, ECX, EBX, EAX
                                ; POPA 명령으로 모두 POP된다.
dw UserDataSelector, 0		; DS
dw UserDataSelector, 0		; ES
dw UserDataSelector, 0		; FS
dw UserDataSelector, 0		; GS
                                                
dd 0x80002000                   ; EIP
dw UserCodeSelector, 0		; CS
dd 0x200			; EFLAGS (0x200 enables ints)
dd 0x80002FFF			; ESP
dw UserDataSelector, 0		; SS
                                ; IRET 명령으로 모두 POP 된다.
;****************************************
;******   User4 Task_Structure   ********
;****************************************
times 63 dd 0                   ; 유저 스택영역
User4Stack:
User4regs:	
dd 0, 0, 0, 0, 0, 0, 0, 0	; EDI, ESI, EBP, EBX, EDX, ECX, EBX, EAX
                                ; POPA 명령으로 모두 POP된다.
dw UserDataSelector, 0		; DS
dw UserDataSelector, 0		; ES
dw UserDataSelector, 0		; FS
dw UserDataSelector, 0		; GS
                                                
dd 0x80003000                   ; EIP
dw UserCodeSelector, 0		; CS
dd 0x200			; EFLAGS (0x200 enables ints)
dd 0x80003FFF			; ESP
dw UserDataSelector, 0		; SS
                                ; IRET 명령으로 모두 POP 된다.
;****************************************
;******   User5 Task_Structure   ********
;****************************************
times 63 dd 0                   ; 유저 스택영역
User5Stack:
User5regs:	
dd 0, 0, 0, 0, 0, 0, 0, 0	; EDI, ESI, EBP, EBX, EDX, ECX, EBX, EAX
                                ; POPA 명령으로 모두 POP된다.
dw UserDataSelector, 0		; DS
dw UserDataSelector, 0		; ES
dw UserDataSelector, 0		; FS
dw UserDataSelector, 0		; GS
                                                
dd 0x80004000                   ; EIP
dw UserCodeSelector, 0		; CS
dd 0x200			; EFLAGS (0x200 enables ints)
dd 0x80004FFF			; ESP
dw UserDataSelector, 0		; SS
                                ; IRET 명령으로 모두 POP 된다.
