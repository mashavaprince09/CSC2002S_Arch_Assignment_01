.data
output_filename:        .asciiz "Enter output file name: "
sample_frequency:      .asciiz "Enter sample frequency: "
tone_frequency:     .asciiz "Enter length of tone (in seconds): "
error_message:    .asciiz "Something went wrong:\n"
user_inputFrequency:   .asciiz "Enter tone frequency: "
path:            .space 1000
header:          .space 44
.align 2
buffer:          .space 7000

.text
main:
  li $v0, 4
  la $a0, output_filename
  syscall

  li $v0, 8
  la $a0, path
  li $a1, 512
  syscall

  la $t0, path        
  li $t1, 0xA         

CheckNewline:
  lb $t2, 0($t0)
  beq $t2, $zero, frequency
  beq $t2, $t1, newLineRemoval
  addi $t0, $t0, 1    
  j CheckNewline

newLineRemoval:
  sb $zero, 0($t0)  

frequency:
  li $v0, 4
  la $a0, user_inputFrequency
  syscall
  li $v0, 5
  syscall
  move $s0, $v0       

  # Ask the user for the sample frequency
  li $v0, 4
  la $a0, sample_frequency
  syscall
  li $v0, 5
  syscall
  move $s1, $v0    

  li $v0, 4
  la $a0, tone_frequency
  syscall
  li $v0, 5
  syscall
  move $s2, $v0       

  mul $t3, $s1, $s2  

  div $t4, $s1, $s0   

  li $v0, 13
  la $a0, path
  li $a1, 577       
  li $a2, 511         
  syscall
  move $s3, $v0       

  li $v0, 15
  move $a0, $s3
  la $a1, header
  li $a2, 44
  syscall

  li $t5, 0           
  li $t6, 0           
  li $t7, 0x7fff      
  li $t8, 0x8000      
  la $s4, buffer      
  li $s5, 0  

GenerateWave:
  beq $t5, $t3, WriteToFile   
  srl $t9, $t4, 1    
  blt $t6, $t9, High

Low:
  sh $t8, 0($s4)    
  j NextSample

High:
  sh $t7, 0($s4)      

NextSample:
  addi $s4, $s4, 2
  addi $s5, $s5, 1
  addi $t5, $t5, 1
  addi $t6, $t6, 1

  beq $t6, $t4, Reset
  j Checkbuffer

Reset:
  li $t6, 0         

Checkbuffer:
  blt $s5, 4096, GenerateWave

  # Write buffer to file
  li $v0, 15
  move $a0, $s3
  la $a1, buffer
  li $a2, 8192       
  syscall

  la $s4, buffer
  li $s5, 0
  j GenerateWave

WriteToFile:
  beqz $s5, CloseFile
  li $v0, 15
  move $a0, $s3
  la $a1, buffer
  sll $a2, $s5, 1    
  syscall

CloseFile:
  li $v0, 16
  move $a0, $s3
  syscall

exit:
  li $v0, 10
  syscall

ErrorHandler:
  # Display error message and exit
  la $a0, error_message
  li $v0, 4
  syscall
  j exit
