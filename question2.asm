.data
input_filename: .asciiz "Enter a wave file name:\n"
filesize: .asciiz "Enter the file size (in bytes):\n"
header: .asciiz "Information about the wave file:\n================================\n"
max_ampl: .asciiz "Maximum amplitude: "
min_ampl: .asciiz "Minimum amplitude: "
newline: .asciiz "\n"
buffer: .space 44  # buffer allocated for the WAVE file's metadata (44-byte header)
filename: .space 256 # buffer to hold the input file's name, accommodating up to 255 characters plus the string terminator

.text
.globl main

main:
    # ask the user to enter the file name and path
    li $v0, 4                  # load 4 to $v0 for the print to string service
    la $a0, input_filename    # load address of input_filename
    syscall
    # Read the filename that the user entered
    li $v0, 8                  # load 8 to $v0 for the read string service
    la $a0, filename           # load the address of filename buffer
    li $a1, 256                # max. characters to read
    syscall
    
    # Remove the newline character from the input filename
    jal remove_newline

    # Ask the user to enter the file size
    li $v0, 4  # load 4 to $v0 for the print to string service
    la $a0, filesize # Load the address of filesize
    syscall

     # Read the file size
    li $v0, 5
    syscall
    move $s0, $v0  # store the file size in $s0

    # Open the WAVE file
    li $v0, 13                 # load 13 to $v0 for the open file service 
    la $a0, filename           # load the address of the filename
    li $a1, 0  # flag for read-only
    li $a2, 0
    syscall
    move $s1, $v0  # $s1 = file descriptor

    # check for file open error
    bltz $s1, exit_program

    # read and remove the WAVE file's metadata (44-byte header)
    li $v0, 14
    move $a0, $s1
    la $a1, buffer
    li $a2, 44
    syscall

    # Initialize max and min amplitudes
    li $s2, -32768  # $s2 is the max ampl and it is assigned the smallest 16-bit value
    li $s3, 32767   # $s3 is the min ampl and it is assigned the largest 16-bit value

    # Calculate number of 16-bit samples
    sub $s0, $s0, 44  # subtract header size
    srl $s0, $s0, 1   # divide by 2 (16 bits = 2 bytes)

read_loop:
    beqz $s0, end_read  # if there are no more samples, end the loop

    # Read first byte
    li $v0, 14
    move $a0, $s1
    la $a1, buffer
    li $a2, 1
    syscall

    # Check if read was successful
    bne $v0, 1, end_read

    # Read second byte
    li $v0, 14 # load 14 to $v0 for the read from file service 
    move $a0, $s1
    la $a1, buffer+1
    li $a2, 1
    syscall

    # Check if read was successful
    bne $v0, 1, end_read

    # Combine bytes into a 16-bit signed integer
    lbu $t0, buffer    # Retrieve the initial byte 
    lbu $t1, buffer+1  # Retrieve the subsequent byte 
    sll $t1, $t1, 8    # Move the second byte to the upper 8 bits
    or $t2, $t0, $t1   # Merge the two bytes into a 16-bit value    


    # Sign-extend to 32 bits
    sll $t2, $t2, 16
    sra $t2, $t2, 16

# Compare current value with max
    blt $t2, $s2, check_min   # if current value < max, skip to check_min
    move $s2, $t2             # otherwise, update max with current value

check_min:
    # Update min if necessary
    bgt $t2, $s3, continue # Compare current element with current minimum
    move $s3, $t2 # If current element is smaller, update minimum

continue:
    addi $s0, $s0, -1 # Decrement the loop counter
    j read_loop  # Jump back to the beginning of the read loop

end_read:
    # Close file
    li $v0, 16
    move $a0, $s1
    syscall

    # Print results
    li $v0, 4 # load 4 to $v0 for the print to string service
    la $a0, header
    syscall

    li $v0, 4 # load 4 to $v0 for the print to string service
    la $a0, max_ampl
    syscall
    li $v0, 1
    move $a0, $s2
    syscall
    li $v0, 4 # load 4 to $v0 for the print to string service
    la $a0, newline
    syscall

    li $v0, 4 # load 4 to $v0 for the print to string service
    la $a0, min_ampl
    syscall
    li $v0, 1
    move $a0, $s3
    syscall
    li $v0, 4 # load 4 to $v0 for the print to string service
    la $a0, newline
    syscall

exit_program:
    # Exit program
    li $v0, 10
    syscall
# method to remove newline character from the input filename
remove_newline:
    la $t0, filename # load address of the filename
remove_loop:
    lb $t1, ($t0) # load byte from address in $t0
    beqz $t1, remove_done
    bne $t1, 10, remove_next
    sb $zero, ($t0)
    j remove_done
remove_next:
    addi $t0, $t0, 1
    j remove_loop
remove_done:
    jr $ra