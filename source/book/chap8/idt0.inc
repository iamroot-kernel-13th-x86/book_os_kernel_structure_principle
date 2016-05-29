	cld
	mov ax, SysDataSelector
	mov es, ax
	xor eax, eax
	xor ecx, ecx
	mov ax,256		       ; IDT 영역에 256개의 빈 디스크립터를 복사한다.
	mov edi, IDT_BASE
 loop_idt:
	lea esi, [idt_ignore]	
	mov cx,8		       ; 디스크립터 하나는 8바이트이다.
	rep movsb
	dec ax
	jnz loop_idt

	mov edi, IDT_BASE+8*0x20       ; 타이머 IDT 디스크립터를 복사한다.
	lea esi, [idt_timer]
	mov cx, 8
	rep movsb

	mov edi, IDT_BASE+8*0x21       ; 키보드 IDT 디스크립터를 복사한다.
	lea esi, [idt_keyboard]
	mov cx, 8
	rep movsb

	mov edi, IDT_BASE+8*0x80       ; 트랩 IDT 디스크립터를 복사한다.
	lea esi, [idt_soft_int]
	mov cx, 8
	rep movsb

	mov edi, IDT_BASE+8*0
	lea esi, [idt_exception00]
	mov cx, 8
	rep movsb

	mov edi, IDT_BASE+8*1
	lea esi, [idt_exception01]
	mov cx, 8
	rep movsb

	mov edi, IDT_BASE+8*2
	lea esi, [idt_exception02]
	mov cx, 8
	rep movsb

	mov edi, IDT_BASE+8*3
	lea esi, [idt_exception03]
	mov cx, 8
	rep movsb

	mov edi, IDT_BASE+8*4
	lea esi, [idt_exception04]
	mov cx, 8
	rep movsb

	mov edi, IDT_BASE+8*5
	lea esi, [idt_exception05]
	mov cx, 8
	rep movsb

	mov edi, IDT_BASE+8*6
	lea esi, [idt_exception06]
	mov cx, 8
	rep movsb

	mov edi, IDT_BASE+8*7
	lea esi, [idt_exception07]
	mov cx, 8
	rep movsb

	mov edi, IDT_BASE+8*8
	lea esi, [idt_exception08]
	mov cx, 8
	rep movsb

	mov edi, IDT_BASE+8*9
	lea esi, [idt_exception09]
	mov cx, 8
	rep movsb

	mov edi, IDT_BASE+8*10
	lea esi, [idt_exception10]
	mov cx, 8
	rep movsb

	mov edi, IDT_BASE+8*11
	lea esi, [idt_exception11]
	mov cx, 8
	rep movsb

	mov edi, IDT_BASE+8*12
	lea esi, [idt_exception12]
	mov cx, 8
	rep movsb

	mov edi, IDT_BASE+8*13
	lea esi, [idt_exception13]
	mov cx, 8
	rep movsb

	mov edi, IDT_BASE+8*14
	lea esi, [idt_exception14]
	mov cx, 8
	rep movsb

	mov edi, IDT_BASE+8*15
	lea esi, [idt_exception15]
	mov cx, 8
	rep movsb

	mov edi, IDT_BASE+8*17
	lea esi, [idt_exception17]
	mov cx, 8
	rep movsb

