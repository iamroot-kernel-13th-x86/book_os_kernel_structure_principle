[bits 32]

segment .text
[global _prt]
[extern _print_it]
_prt:
	push ebp
	mov ebp, esp

	call _print_it

	mov esp, ebp
	pop ebp
	ret

