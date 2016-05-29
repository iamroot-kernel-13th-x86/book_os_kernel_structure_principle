%include "init.inc"

; 인터럽트 핸들러의 C언어로 된 루틴들
[extern _printk]
[extern _TimerHandler]
[extern _schedule]
[extern _KeyboardHandler]
[extern _FloppyHandler]
[extern _print_hex]
[extern _IgnorableInterrrupt]
[extern _SystemCallEntry]
[extern _H_isr_00]
[extern _H_isr_01]
[extern _H_isr_02]
[extern _H_isr_03]
[extern _H_isr_04]
[extern _H_isr_05]
[extern _H_isr_06]
[extern _H_isr_07]
[extern _H_isr_08]
[extern _H_isr_09]
[extern _H_isr_10]
[extern _H_isr_11]
[extern _H_isr_12]
[extern _H_isr_13]
[extern _H_isr_14]
[extern _H_isr_15]
[extern _H_isr_17]

segment .text

; 현재 이 파일에 정의된 루틴들


[global _LoadIDT]
[global _EnablePIC]
; 인터럽트 핸들러들
[global _isr_ignore]
[global _isr_32_timer]
[global _isr_33_keyboard]
[global _isr_38_floppy]
[global _isr_128_soft_int]
[global _isr_00]
[global _isr_01]
[global _isr_02]
[global _isr_03]
[global _isr_04]
[global _isr_05]
[global _isr_06]
[global _isr_07]
[global _isr_08]
[global _isr_09]
[global _isr_10]
[global _isr_11]
[global _isr_12]
[global _isr_13]
[global _isr_14]
[global _isr_15]
[global _isr_17]

_LoadIDT:
	push ebp
	mov ebp, esp

	lidt [idtr]

	pop ebp
	ret

_EnablePIC:
	mov al, 0xBC            ; 막아두었던 인터럽트 중, 
	out 0x21, al		; 타이머, 키보드, 플로피만
	sti                     ; 다시 유효하게 한다.		
	ret

_isr_ignore:
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

	call _IgnorableInterrrupt ; C언어 루틴을 불러들인다.
	
	popad
	pop ds
	pop es
	pop fs
	pop gs

	iret


_isr_32_timer:
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

	call _TimerHandler ; C언어 루틴을 불러들인다.
	
	call _schedule ; C언어 루틴을 불러들인다.

	popad
	pop ds
	pop es
	pop fs
	pop gs

	iret

_isr_33_keyboard:
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
	
	xor eax, eax
	in  al,0x60
	
	push eax
	call _KeyboardHandler 
	add esp, 4

	popad
	pop ds
	pop es
	pop fs
	pop gs

	iret

_isr_38_floppy:
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

	call _FloppyHandler 
	
	popad
	pop ds
	pop es
	pop fs
	pop gs

	iret

_isr_128_soft_int:
	push gs
	push fs
	push es
	push ds
	pushad

	push eax
	mov ax, SysDataSelector
	mov DS, ax
	mov ES, ax
	mov FS, ax
	mov GS, ax
	pop eax

	call _SystemCallEntry
	
	popad
	pop ds
	pop es
	pop fs
	pop gs

	iret

_isr_00:
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

	call _H_isr_00

	popad
	pop ds
	pop es
	pop fs
	pop gs

	iret

_isr_01:
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

	call _H_isr_01
	
	popad
	pop ds
	pop es
	pop fs
	pop gs

	iret

_isr_02:
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

	call _H_isr_02
	
	popad
	pop ds
	pop es
	pop fs
	pop gs

	iret

_isr_03:
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

	call _H_isr_03
	
	popad
	pop ds
	pop es
	pop fs
	pop gs

	iret

_isr_04:
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

	call _H_isr_04
	
	popad
	pop ds
	pop es
	pop fs
	pop gs

	iret

_isr_05:
	push gs
	push fs
	push es
	push ds
	pushad

	mov ax, SysDataSelector

	call _H_isr_05
	
	popad
	pop ds
	pop es
	pop fs
	pop gs

	iret

_isr_06:
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

	call _H_isr_06
	
	popad
	pop ds
	pop es
	pop fs
	pop gs

	iret

_isr_07:
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

	call _H_isr_07
	
	popad
	pop ds
	pop es
	pop fs
	pop gs

	iret

_isr_08:
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

	call _H_isr_08
	
	popad
	pop ds
	pop es
	pop fs
	pop gs

	iret

_isr_09:
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

	call _H_isr_09
	
	popad
	pop ds
	pop es
	pop fs
	pop gs

	iret

_isr_10:
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

	call _H_isr_10
	
	popad
	pop ds
	pop es
	pop fs
	pop gs

	iret

_isr_11:
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

	call _H_isr_11
	
	popad
	pop ds
	pop es
	pop fs
	pop gs

	iret

_isr_12:
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

	call _H_isr_12
	
	popad
	pop ds
	pop es
	pop fs
	pop gs

	iret

_isr_13:
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

	call _H_isr_13

	popad
	pop ds
	pop es
	pop fs
	pop gs

	iret

_isr_14:
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

	call _H_isr_14
	
	popad
	pop ds
	pop es
	pop fs
	pop gs

	iret

_isr_15:
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

	call _H_isr_15
	
	popad
	pop ds
	pop es
	pop fs
	pop gs

	iret

_isr_17:
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

	call _H_isr_17
	
	popad
	pop ds
	pop es
	pop fs
	pop gs

	iret


segment .data

idtr:	dw	256*8-1        	         ; IDT 의 Limit 
	dd	IDT_BASE                 ; IDT 의 Base Address
