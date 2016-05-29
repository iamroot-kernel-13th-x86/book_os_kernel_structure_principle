[bits 32]

segment .data

	lucky db "Lucky number is %d", 0

segment .text
[global _print_it]
[extern _printf]
_print_it:
	push ebp
	mov ebp, esp

	push dword 7
	push lucky
	call _printf

	mov esp, ebp
	pop ebp
	ret

