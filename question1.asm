.data
    input_filename: .asciiz "Enter a wave file name:\n"
    filesize: .asciiz "Enter the file size (in bytes):\n"
    header: .asciiz "Information about the wave file:\n================================\n"
    num_channels: .asciiz "Number of channels: "
    sample_rate: .asciiz "Sample rate: "
    byte_rate: .asciiz "Byte rate: "
    bits_sample: .asciiz "Bits per sample: "
    newline:         .asciiz "\n"

    # buffer to hold the input file's name, accommodating up to 255 characters plus the string terminator
    filename: .space 256
    
    # buffer allocated for the WAVE file's metadata (44-byte header)
    # adjusted to match word size limits to avoid improper memory access
    .align 2
    header_buffer:   .space 44

.text
.globl main

main:
    # Ask the user to enter the file name and path
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
    li $v0, 5                  # load 8 to $v0 for the read int service 
    syscall

    # Open the WAVE file
    li $v0, 13                 # load 13 to $v0 for the open file service 
    la $a0, filename           # load the address of the filename
    li $a1, 0                  # flag for read-only
    li $a2, 0                 
    syscall

    move $s0, $v0              # store the file descriptor in $s0

    # Read the WAVE file's metadata (44-byte header)
    li $v0, 14                 # load 14 to $v0 for the read from file service 
    move $a0, $s0              # file descriptor
    la $a1, header_buffer      # buffer to store the header
    li $a2, 44                 # number of bytes to read
    syscall

    # Close the WAVE file
    li $v0, 16                 # load 16 to $v0 for the close file service  
    move $a0, $s0              # file descriptor
    syscall

    # Print the information header
    li $v0, 4 # load 4 to $v0 for the print to string service
    la $a0, header
    syscall

    # Extract and print number of channels
    li $v0, 4 # load 4 to $v0 for the print to string service
    la $a0, num_channels # load the address of the number of channels
    syscall

    la $t0, header_buffer      # Load base address of header_buffer
    lhu $a0, 22($t0)           # load half-word with an offset of 22
    li $v0, 1                  # load 1 to $v0 for the print int string service 
    syscall

    li $v0, 4 # load 4 to $v0 for the print to string service
    la $a0, newline
    syscall

    # extract and print sample rate
    li $v0, 4 # load 4 to $v0 for the print to string service
    la $a0, sample_rate
    syscall

    la $t0, header_buffer
    lw $a0, 24($t0)            # load word with an offset of 24
    li $v0, 1
    syscall

    li $v0, 4 # load 4 to $v0 for the print to string service
    la $a0, newline
    syscall

    # extract and print byte rate
    li $v0, 4 # load 4 to $v0 for the print to string service
    la $a0, byte_rate
    syscall

    la $t0, header_buffer
    lw $a0, 28($t0)  # load word with an offset of 28
    li $v0, 1
    syscall

    li $v0, 4 # load 4 to $v0 for the print to string service
    la $a0, newline
    syscall

    # extract and print bits per sample
    li $v0, 4 # load 4 to $v0 for the print to string service
    la $a0, bits_sample
    syscall

    la $t0, header_buffer
    lhu $a0, 34($t0)           # load half word with an offset of 34
    li $v0, 1
    syscall

    li $v0, 4 # load 4 to $v0 for the print to string service
    la $a0, newline
    syscall

    # close program
    li $v0, 10  # load 10 to $v0 for the close program service
    syscall

# method to remove newline character from the input filename
remove_newline:
    la $t0, filename           # load address of the filename
remove_newline_loop:
    lb $t1, ($t0)              # load byte from address in $t0
    beqz $t1, remove_newline_done  # if the byte is null terminator, we're done
    bne $t1, 10, remove_newline_next  # if the byte is not newline, check next byte
    sb $zero, ($t0)            # replace newline with null terminator
    j remove_newline_done
remove_newline_next:
    addi $t0, $t0, 1           # move to next byte
    j remove_newline_loop
remove_newline_done:
    jr $ra                     # return to caller (line 38)