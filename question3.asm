.data
fileNameIn:         .space 256   #store the input file name
fileNameOut:        .space 256   #store the output file name
header:             .space 44    #space for the header
newLine:            .asciiz "\n"

.text
.globl main

main:

    #get input file name from the user
    li $v0, 8     #syscall to read a string
    la $a0, fileNameIn
    li $a1, 256   #max string length
    syscall

    #remove the newline character
    la $t0, fileNameIn  #address of fileNameIn
    jal remove_newline

    #get output file name from user
    li $v0, 8
    la $a0, fileNameOut
    li $a1, 256
    syscall

    #remove the newline character
    la $t0, fileNameOut #address of fileNameOut
    jal remove_newline

    # Get the file size
    li $v0, 5 #syscall to read integer
    syscall
    move $s0, $v0 #store the file size in $s0

    #open the input file to read
    li $v0, 13         #syscall to open file
    la $a0, fileNameIn #input file name
    li $a1, 0          #open for reading (mode 0)
    li $a2, 0          #no special permissions
    syscall
    move $s1, $v0    #store input file descriptor in $s1
    #bltz $s1, exit   #exit if file couldn't be opened

    #read the header
    li $v0, 14      #syscall to read file
    move $a0, $s1   #input file descriptor
    la $a1, header  #address to store header
    li $a2, 44      #read 44 bytes (header)
    syscall

    #allocate space for the audio data in memory
    sub $t0, $s0, 44  #subtract header size from total size
    li $v0, 9      #syscall to allocate memory
    move $a0, $t0  #size of audio data (file size - 44) -Edit (Actually size of file)
    syscall
    move $s2, $v0   #store audio data memory address in $s2

    #read the audio data into memory
    li $v0, 14     #syscall to read file
    move $a0, $s1  #input file descriptor
    move $a1, $s2  #memory location for audio data
    move $a2, $t0  #number of bytes to read (audio data size)
    syscall

    #close the input file
    #li $v0, 16     #syscall to close file
    #move $a0, $s1  #input file descriptor
    #syscall

    #open the output file for writing
    li $v0, 13          #syscall to open file
    la $a0, fileNameOut #output file name
    li $a1, 577           #open for writing (mode 1)
    li $a2, 438         #permission 644 (rw-r--r--)
    syscall
    move $s1, $v0   #store output file descriptor in $s1
    #bltz $s1, exit  #exit if file couldn't be opened

    #write the 44-byte header to the output file
    li $v0, 15     #syscall to write to file
    move $a0, $s1  #output file descriptor
    la $a1, header #address of header
    li $a2, 44     #write 44 bytes (header)
    syscall

    #reverse and write the audio data
    #la $t4, fileNameIn
    #addi $t4, $s2, 44
    add $t1, $s2, $t0  #end of audio data (s2 + audio size)
    subu $t1, $t1, 2    #start at last 2 bytes (since bit depth is 16)
reverse_audio:
    blt $t1, $s2, done_reversing #if we've reached the beginning, stop
    
    #lh $t3, 0($t1)
    #addi $t1, $t1, 2

    #write 2 bytes from the end to the output file
    li $v0, 15    #syscall to write to file
    move $a0, $s1 #output file descriptor
    la $a1, 0($t1)#address of the current sample
    li $a2, 2     #write 2 bytes (one sample)
    syscall

    #move backwards to the next 2-byte sample
    sub $t1, $t1, 2
    j reverse_audio

done_reversing:
    #close the output file
    li $v0, 16     #syscall to close file
    move $a0, $s1  #output file descriptor
    syscall

exit:
    #exit the program
    li $v0, 10 #syscall to exit
    syscall

#subroutine to remove newline character from the files names'
remove_newline:
    lb $t1, 0($t0)       #load byte from address in $t0
    beq $t1, 10, newline_found #if newline (ASCII 10), replace it
    beq $t1, 0, return_from_sub #if null terminator, end
    addi $t0, $t0, 1     #move to the next byte
    j remove_newline     #repeat

newline_found:
    sb $zero, 0($t0)     #replace newline with null terminator
    j return_from_sub

return_from_sub:
    jr $ra               #return from subroutine
