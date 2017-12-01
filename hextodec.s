# A MIPS Program that prints the corresponding decimal number 
# of an hexadecimal number specified by user input
.data
str: .space 9
error: .asciiz "Invalid hexadecimal number."
buffer: .space 11	# buffer string to store decimal string

.text
main:
addi $s0, $zero, 0    	# Initialize $s0

li $v0, 8 							# Read in hexadecimal number
la $a0, str
li $a1, 9							# of size 9 
syscall

la $s1, str

add $a0, $s1, $zero					# Add address of string to argument
jal hex_string
lw $s0, 0($sp)						# Copy return value from stack to $s0
addi $sp, $sp, 4					# Increment stack pointer by 4

#li $v0, 1								# Print integer value
#add $a0, $s0, $zero			# in $s0
#syscall

la $s3, buffer
addi $t7, $zero, 0
sb $t7, 8($s3)					# Null terminate the buffer string

addi $s3, $s3, 8				# Start from the end of the buffer string

stringloop: addi $t6, $zero, 1
sub $s3, $s3, $t6				# Subtract 1 from s3
addi $t6, $zero, 10
divu $s0, $t6					# Divide the decimal in $s0 by 10
mfhi $t7							# Put the remainder in $t7
mflo $s0							# Put the quotient in $s0
addi $t7, $t7, 48 		# Convert decimal in $t7 to ascii
sb $t7, 0($s3)   			# store remainder in $s3

bne $s0, $zero, stringloop		# Continue looping until quotient is 0

finalexit: 

li $v0, 4  						# Print string
la $a0, 0($s3)
syscall

li $v0, 10 							# Exit Program
syscall

########################################hex_string
# Function returns decimal value of an hexadecimal string
#
# Arg registers used: $a0
# Tmp registers used: $t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t9
#
# Pre: none
# Post: 0($sp) contains the return value
# Returns: the value of the hex, -1 if not valid
#
# Called by: main
# Calls: hex_funct
hex_string:
add $t9, $a0, $zero			# Load address of string from argument
lbu $t2, 0($t9)					# Load character at $t9
addi $t1, $zero, 0			# initialize counter $t1 to zero
add $t5, $ra, $zero 		# Store the value in $ra into $t5

sp: addi $t7, $zero, 32			# Store 32 - ascii space in $t7			
bne $t2, $t7, loop					# If not space branch to loop
addi $t9, $t9, 1				
lbu $t2, 0($t9)				# Load the next charcter
j sp						# Repeat until character is not space

loop: 
add $a0, $zero,  $t2		# Initialize values for function: hex_funct
jal hex_funct
addi $t7, $zero, 1			# Set temporary variable to 1
sub $t3, $zero, $t7			# Set temporary variable to -1
bne $v0, $t3, valid			# Check whether $v0 is not equal to -1

li $v0, 4					# Print error string, the input character is not a hex value
la $a0, error
syscall
li $v0, 10 					# Exit Program
syscall

valid: add $t0, $v0, $zero
bne $t1, $zero, else		# If it's the first number, don't shift the register
j both
else: sll $t6, $t6, 4   	# Shift register that stores the decimal number by 4
both: add $t6, $t6, $t0		# Add the new decimal returned by hex_funct to the number

addi $t1, $t1, 1			# Update the counter

addi $t9, $t9, 1
lbu $t2, 0($t9)				# Load the next  character
beq $t2, $zero, finish 		# Exit loop when next character in string is null
addi $t8, $zero, 10
beq $t2, $t8, finish		# Exit loop when next character in string is enter
j loop

finish:
addi $sp, $sp, -4			# Decrement stack pointer by 4
sw $t6, 0($sp)				# Copy $t6 to stack

add $ra, $t5, $zero		# Reload $ra from t5
jr $ra


########################################hex_funct
# Function returns decimal value of a single hexadecimal value using ascii ranges
#
# Arg registers used: $a0
# Tmp registers used: $t0, $t2, $t3, $t4, $t7
#
# Pre: none
# Post: $v0 contains the return value
# Returns: the value of the hex, -1 if not valid
#
# Called by: hex_string
# Calls: none
hex_funct:	
addi $t7, $zero, 1								
sub $v0, $zero, $t7			# Initialize $v0 to -1

li $t0, 48							# Initialize lower bound for the ascii range 0 - 9
li $t2, 58							# Initialize upper bound the ascii range 0 - 9
add $t3, $t0, $zero			# t3 is the value to be subtracted from the ascii value to get its value in hex

l1: bne $a0, $t0, ne1 	# a0 is the ascii value, t0 is the lower bound of the ascii range to be checked
sub $v0, $t0, $t3				# t3 is the value to be subtracted from the ascii value to get its value in hex
jr $ra
ne1: addi $t0, $t0, 1
bne $t0, $t2, nne1			# t2 is the upper bound of the ascii range plus 1
j label1								# Hex value not in range, try next range
nne1: j l1

label1: li $t0, 65			# Initialize lower bound for the ascii range A - F
li $t2, 71							# Initialize upper bound for the ascii range A - F
addi $t4, $zero, 10			# Set temporary variable to 10
sub $t3, $t0, $t4				# t3 is the value to be subtracted from the ascii value to get its value in hex

l2: bne $a0, $t0, ne2 	# a0 is the ascii value, t0 is the lower bound of the ascii range to be checked
sub $v0, $t0, $t3				# t3 is the value to be subtracted from the ascii value to get its value in hex
jr $ra
ne2: addi $t0, $t0, 1
bne $t0, $t2, nne2			# t2 is the upper bound of the ascii range plus 1
j label2								# Hex value not in range, try next range
nne2: j l2

label2: li $t0, 97			# Initialize lower bound for the for the ascii range a - f
li $t2, 103							# Initialize upper bound for the ascii range a - f
addi $t4, $zero, 10			# Set temporary variable to 10
sub $t3, $t0, $t4				# t3 is the value to be subtracted from the ascii value to get its value in hex

l3: bne $a0, $t0, ne3 	# a0 is the ascii value, t0 is the lower bound of the ascii range to be checked
sub $v0, $t0, $t3				# t3 is the value to be subtracted from the ascii value to get its value in hex
jr $ra									# Return the decimal value
ne3: addi $t0, $t0, 1
bne $t0, $t2, nne3			# t2 is the upper bound of the ascii range plus 1
jr $ra									# Invalid hex value, return
nne3: j l3