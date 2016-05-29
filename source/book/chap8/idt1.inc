isr_ignore:
	push gs
	push fs
	push es
	push ds
	pushad

	mov ax, SysDataSelector
	mov DS, ax
	mov ES, ax
	mov FS, ax
	mov GS, ax

	mov al,0x20
	out 0x20,al

	mov edi, (80*2*0)
	lea esi, [msg_isr_ignore]
	call printf
	inc byte [msg_isr_ignore]
	
	jmp ret_from_int

isr_32_timer:
	push gs
	push fs
	push es
	push ds
	pushad

	mov ax, SysDataSelector
	mov DS, ax
	mov ES, ax
	mov FS, ax
	mov GS, ax
	
	mov	al,0x20
	out	0x20,al

	mov edi, 80*2*0
	lea esi, [msg_isr_32_timer]
	call printf
	inc byte [msg_isr_32_timer]

	jmp ret_from_int

isr_33_keyboard:
	push gs
	push fs
	push es
	push ds
	pushad

	mov ax, SysDataSelector
	mov DS, ax
	mov ES, ax
	mov FS, ax
	mov GS, ax

	in	al,0x60

	mov	al,0x20
	out	0x20,al
	
	mov edi, (80*2*0)+(2*35)
	lea esi, [msg_isr_33_keyboard]
	call printf
	inc byte [msg_isr_33_keyboard]

	jmp ret_from_int
	
isr_128_soft_int:
	push gs
	push fs
	push es
	push ds
	pushad

	mov cx, SysDataSelector
	mov DS, cx
	mov ES, cx
	mov FS, cx
	mov GS, cx

	mov edi, eax
	lea esi, [ebx]
	
	call printf

	jmp ret_from_int

isr_00:
	
	mov edi,  (80*12*2)
	lea esi, [msg_isr_00_zero_devide]
	call printf
	jmp $

isr_01:
	
	mov edi,  (80*12*2)
	lea esi, [msg_isr_01_debug]
	call printf
	jmp $

isr_02:
	
	mov edi,  (80*12*2)
	lea esi, [msg_isr_02_nmi]
	call printf
	jmp $

isr_03:
	
	mov edi,  (80*12*2)
	lea esi, [msg_isr_03]
	call printf
	jmp $

isr_04:
	
	mov edi,  (80*12*2)
	lea esi, [msg_isr_04_into]
	call printf
	jmp $

isr_05:
	
	mov edi,  (80*12*2)
	lea esi, [msg_isr_05_bound]
	call printf
	jmp $

isr_06:
	
	mov edi,  (80*12*2)
	lea esi, [msg_isr_06_opcode]
	call printf
	jmp $

isr_07:
	
	mov edi,  (80*12*2)
	lea esi, [msg_isr_07_coprocess]
	call printf
	jmp $

isr_08:
	
	mov edi,  (80*12*2)
	lea esi, [msg_isr_08_double_fault]
	call printf
	jmp $

isr_09:
	
	mov edi,  (80*12*2)
	lea esi, [msg_isr_09_coprocess_segment]
	call printf
	jmp $

isr_10:
	
	mov edi,  (80*12*2)
	lea esi, [msg_isr_10_bad_tss]
	call printf
	jmp $

isr_11:
	
	mov edi,  (80*12*2)
	lea esi, [msg_isr_11_segment_not_present]
	call printf
	jmp $

isr_12:
	
	mov edi,  (80*12*2)
	lea esi, [msg_isr_12_stack_fault]
	call printf
	jmp $

isr_13:
	mov edi,  (80*12*2)
	lea esi, [msg_isr_13_gpf]
	call printf
	jmp $

isr_14:
	mov edi,  (80*12*2)
	lea esi, [msg_isr_14_page_fault]
	call printf
	jmp $

isr_15:
	
	mov edi,  (80*12*2)
	lea esi, [msg_isr_15_coprocessor_error]
	call printf
	jmp $

isr_17:
	
	mov edi,  (80*12*2)
	lea esi, [msg_isr_17_alignment_check]
	call printf
	jmp $

ret_from_int:
	xor eax, eax
	mov eax, [esp+52]
	and eax, 0x00000003
	xor ebx, ebx
	mov bx, cs
	and ebx, 0x00000003
	cmp eax, ebx
	ja scheduler

	popad
	pop ds
	pop es
	pop fs
	pop gs

	iret

msg_isr_00_zero_devide db "Zero Devide", 0
msg_isr_01_debug db "Debug", 0
msg_isr_02_nmi db "NMI", 0
msg_isr_03 db "int3", 0
msg_isr_04_into db "INTO", 0
msg_isr_05_bound db "Bound", 0
msg_isr_06_opcode db "Invalid Opcode", 0
msg_isr_07_coprocess db "Coprocess Not Available", 0
msg_isr_08_double_fault db "Double Fault", 0
msg_isr_09_coprocess_segment db "Coprocess Segment Overrun", 0
msg_isr_10_bad_tss db "Bad TSS", 0
msg_isr_11_segment_not_present db "Segment Not Present", 0
msg_isr_12_stack_fault db "Stack Fault", 0
msg_isr_13_gpf db "GPF", 0
msg_isr_14_page_fault db "Page Fault", 0
msg_isr_15_coprocessor_error db "Coprocess Error", 0
msg_isr_17_alignment_check db "Alignment Check", 0
msg_isr_ignore db "This is an ignorable interrupt", 0
msg_isr_32_timer db ".This is the timer interrupt", 0
msg_isr_33_keyboard db ".This is the keyboard interrupt", 0
msg_isr_128_soft_int db ".This is the soft_int interrupt", 0
