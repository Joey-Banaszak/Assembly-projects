#==============================================================================
# maze.s
#
# by Patrick Kelley
#
# This program produces a maze in an 80 X 24 grid by recursively pathing 
# through the grid space.  It is an implementation of the following C++ code
# and is an example of equivalent coding.  As such, the complete code is given
# below and then repeated as comments in the assembly code.
#
# This code is intended to be built in the QTSPIM environment and run at a
# console command prompt with no parameters.  Each run should produce a unique
# maze.
#
# Last modified: 3/29/2014 by Patrick Kelley
#==============================================================================

# BEGIN C++ CODE
# //===========================================================================
# // maze.cpp
# //
# // C++ implementation of a recursive maze-generating program.
# //
# // History:
# // 2006.03.30 / Abe Pralle - Created
# // 2010.04.02 / Abe Pralle - Converted to C++
# //===========================================================================
# #include <iostream>
# using namespace std;
# 
# //----CONSTANTS-------------------------------------------------------
# #define GRID_WIDTH 79
# #define GRID_HEIGHT 23
# #define NORTH 0
# #define EAST 1
# #define SOUTH 2
# #define WEST 3
# 
# //----GLOBAL VARIABLES------------------------------------------------
# char grid[GRID_WIDTH*GRID_HEIGHT];
# 
# //----FUNCTION PROTOTYPES---------------------------------------------
# void ResetGrid();
# int XYToIndex( int x, int y );
# int IsInBounds( int x, int y );
# void Visit( int x, int y );
# void PrintGrid();
# 
# //----FUNCTIONS-------------------------------------------------------
# int main()
# {
#   // Starting point and top-level control.
#   srand( time(0) ); // seed random number generator.
#   ResetGrid();
#   Visit(1,1);
#   PrintGrid();
#   return 0;
# }
# 
# void ResetGrid()
# {
#   // Fills the grid with walls ('#' characters).
#   for (int i=0; i<GRID_WIDTH*GRID_HEIGHT; ++i)
#   {
#     grid[i] = '#';
#   }
# }
# 
# int XYToIndex( int x, int y )
# {
#   // Converts the two-dimensional index pair (x,y) into a
#   // single-dimensional index. The result is y * ROW_WIDTH + x.
#   return y * GRID_WIDTH + x;
# }
# 
# int IsInBounds( int x, int y )
# {
#   // Returns "true" if x and y are both in-bounds.
#   if (x < 0 || x >= GRID_WIDTH) return false;
#   if (y < 0 || y >= GRID_HEIGHT) return false;
#   return true;
# }
# 
# void Visit( int x, int y )
# {
#   // Starting at the given index, recursively visits every direction in a
#   // randomized order.
#   // Set my current location to be an empty passage.
#   grid[ XYToIndex(x,y) ] = ' ';
#   
#   // Create an local array containing the 4 directions and shuffle their
#   // order.
#   int dirs[4];
#   dirs[0] = NORTH;
#   dirs[1] = EAST;
#   dirs[2] = SOUTH;
#   dirs[3] = WEST;
#   
#   for (int i=0; i<4; ++i)
#   {
#     int r = rand() & 3;
#     int temp = dirs[r];
#     dirs[r] = dirs[i];
#     dirs[i] = temp;
#   }
#   
#   // Loop through every direction and attempt to Visit that direction.
#   for (int i=0; i<4; ++i)
#   {
#     // dx,dy are offsets from current location. Set them based
#     // on the next direction I wish to try.
#     int dx=0, dy=0;
#     switch (dirs[i])
#     {
#       case NORTH: dy = -1; break;
#       case SOUTH: dy = 1; break;
#       case EAST: dx = 1; break;
#       case WEST: dx = -1; break;
#     }
#     
#     // Find the (x,y) coordinates of the grid cell 2 spots
#     // away in the given direction.
#     int x2 = x + (dx<<1);
#     int y2 = y + (dy<<1);
#     
#     if (IsInBounds(x2,y2))
#     {
#       if (grid[ XYToIndex(x2,y2) ] == '#')
#       {
#         // (x2,y2) has not been visited yet... knock down the
#         // wall between my current position and that position
#         grid[ XYToIndex(x2-dx,y2-dy) ] = ' ';
#         
#         // Recursively Visit (x2,y2)
#         Visit(x2,y2);
#       }
#     }
#   }
# }
# 
# void PrintGrid()
# {
#   // Displays the finished maze to the screen.
#   for (int y=0; y<GRID_HEIGHT; ++y)
#   {
#     for (int x=0; x<GRID_WIDTH; ++x)
#     {
#       cout << grid[XYToIndex(x,y)];
#     }
#     cout << endl;
#   }
# }
# END C++ CODE

#==============================================================================
# BEGIN IMPLEMENTATION
#==============================================================================

#==============================================================================
# SETUP:
#
# #include <iostream>
# using namespace std;
#==============================================================================
	# nothing to do here; standard for MIPS

#==============================================================================
# CONSTANTS:
#
# #define GRID_WIDTH 79			
# #define GRID_HEIGHT 23
# #define NORTH 0
# #define EAST 1
# #define SOUTH 2
# #define WEST 3
#==============================================================================
	.data
GRID_WIDTH:	.word	80		# need to add 1 to print as string
GRID_HEIGHT:	.word	23
GRID_SIZE:	.word	1840		# because I can't precalculate it in
					# MIPS like I could in MASM
NORTH:		.word	0
EAST:		.word   1
SOUTH:		.word	2
WEST:		.word	3
RGEN:		.word	1140671485	# a sufficiently large prime for rand
POUND:		.byte	35		# the '#' character
SPACE:		.byte	32		# the ' ' character
NEWLINE:	.byte	10		# the newline character

#==============================================================================
# STRING VARIABLES
#
# Think of them as string constants for prompts and such
#==============================================================================

rsdPrompt:	.asciiz "Enter a seed number (1073741824 - 2147483646): "
smErr1:		.asciiz "That number is too small, try again: "
bgErr:		.asciiz "That number is too large, try again: "
newLine:	.asciiz "\n"

#==============================================================================
# GLOBAL VARIABLES
#
# char grid[GRID_WIDTH*GRID_HEIGHT];
#==============================================================================

grid:	.space	1841		# ((79 + 1) * 23) + 1 bytes reserved for grid
rSeed:	.word	0		# a seed for generating a random number

#==============================================================================
# FUNCTION PROTOTYPES:
#==============================================================================
# Only listed here because it is not necessary to forward-declare in assembly
# void ResetGrid();
# int XYToIndex( int x, int y );
# int IsInBounds( int x, int y );
# void Visit( int x, int y );
# void PrintGrid();
# int srand();                  # adding function to get random seed from user
# int rand(int min, int max);	# adding function to get a random from a range

#==============================================================================
# FUNCTIONS:
#==============================================================================
	.text
	.globl main
#==============================================================================
# int main()
# {
#   // Starting point and top-level control.
#   srand( time(0) ); // seed random number generator.
#   ResetGrid();
#   Visit(1,1);
#   PrintGrid();
#   return 0;
# }
#==============================================================================
main:
	sw	$ra, 0($sp)	# save the return address
	jal	srand		# get a random seed
	jal	ResetGrid	# reset the grid to '#'s
	# TODO: Uncomment these lines when ready to test Visit.
	li	$t0, 1		# set up for start of generation at (1,1)
	sw	$t0, -4($sp)	# push first param
	sw	$t0, -8($sp) 	# push second param
	jal	Visit		# start the recursive generation
	jal	PrintGrid	# display the grid
	lw	$ra, 0($sp)	# restor the return address
	jr	$ra		# exit the program

#==============================================================================
# void ResetGrid()
# {
#   // Fills the grid with walls ('#' characters).
#   for (int i=0; i<GRID_WIDTH*GRID_HEIGHT; ++i)
#   {
#     grid[i] = '#';
#   }
# }
#==============================================================================
ResetGrid:
	# It's a waste do do a stack frame when there are no parameters or
	# return values, so I'll optimize and simply push any register I use
	# onto the stack.  I need 7, a loop counter, a place to store the
	# loop bound for comparison, the base address of the grid, a register
	# to store the character value I will write, a register to store the
	# width of the grid, a register to store the newline character, and
	# finally, a register to hold calculation results.
	
	# save the registers
	sw	$s0, -4($sp)	# $s0 will be the loop counter
	sw	$s1, -8($sp)	# $s1 will hold the array bound
	sw	$s2, -12($sp)	# $s2 will be the grid base address
	sw	$s3, -16($sp)	# $s3 will hold the character
	sw	$s4, -20($sp)	# $s4 will hold the grid width
	sw      $s5, -24($sp)   # $s5 will hold the newline character
	sw	$s6, -28($sp)	# $s6 used for calculations
	
	# load the working values
	li	$s0, 1		# initialize the counter
	lw	$s1, GRID_SIZE	# initialize the array bound
	la	$s2, grid	# get the base address
	lb	$s3, POUND	# store the '#' ASCII code
	lw	$s4, GRID_WIDTH # store the grid width
	lb	$s5, NEWLINE	# store the newline ASCII code
  
ResetLoop:
	sb	$s3, 0($s2)	# put a '#' in the grid
	addi	$s0, $s0, 1	# increment the loop counter
	addi	$s2, $s2, 1	# point at next char position
	div	$s0, $s4	# divide the counter by grid width
	mfhi	$s6		# get remainder in calculation register
	bnez	$s6, NoNewLine	# keep going
	
	sb	$s5, 0($s2)     # put a newline in the grid
	addi	$s0, $s0, 1	# increment the loop counter
	addi	$s2, $s2, 1	# point at next char position
	
NoNewLine:
	blt	$s0, $s1, ResetLoop	# if less than end, loop again
	
	# when we fall out of the loop, restore the registers and return
	lw	$s0, -4($sp)	
	lw	$s1, -8($sp)	
	lw	$s2, -12($sp)	
	lw	$s3, -16($sp)	
	lw	$s4, -20($sp)	
	lw      $s5, -24($sp)   
	lw	$s6, -28($sp)	
	jr	$ra		# return
	
#==============================================================================
# srand()
# 
# Unlike the C++ equivalent, this routine has to ask the user for a seed,
# because we don't have access to a time string. So I borrowed code from a
# linear congruence project to prompt for a large integer and save it as a
# seed for another function that does linear congruence.
#==============================================================================
srand:
	# For this function, we only need to preserve 3 registers.  We use
	# $a0 and $v0 for I/0, and we use $s0 as a scratch register.

	# save the registers
	sw	$v0, -4($sp)	# $v0 will be the service code
	sw	$a0, -8($sp)	# $a0 will point to the grid string
	sw	$s0, -12($sp)	# $s0 will hold the input for testing
	
	# prompt for a random seed and get the value
	la	$a0, rsdPrompt
	li	$v0, 4		# print_string
	syscall

input10:
	li	$v0, 5		# read_int
	syscall
	li	$s0, 1073741823		# put 2147483646 in t0 for comparison
	bgtu	$v0, $s0, input11	# input bigger than 1073741823?
	la	$a0, smErr1	# no, point to error and
	li	$v0, 4		# print_string
	syscall
	j	input10		# try again

input11:
	li	$s0, 2147483646	# upper bound in register t0 for comparison
	bleu	$v0, $s0, input12	# less than or equal 2147483646?
	la	$a0, bgErr	# no, point to error and
	li	$v0, 4		# print_string
	syscall
	j	input10		# try again

input12:	
	# number is good, save and move on
	sw	$v0, rSeed
	
	# restore the registers
	lw	$v0, -4($sp)	
	lw	$a0, -8($sp)	
	lw	$s0, -12($sp)

	jr	$ra		# return
	
#==============================================================================
# rand(int min, int max)
# 
# This code is stolen from the linear congruence project (relax, I wrote it).
# It uses the rSeed and RGNE values to create a new psuedo-random and a new 
# seed for the next time this routine is called.  It range-fits the psuedo-
# random to the range min-max and returns it.  It does not need to formalize a
# stack frame since it doesn't call any other routines, so we simply set the
# two params and the return into the stack before calling and it begins pushing
# registers onto the stack above -12($sp).  Min is expected to be at -8($sp)
# and max is expected at -12($sp) while the return is at -4($sp).
#==============================================================================
rand:
	# For this function, we only need to preserve 3 registers.  We use
	# $s0 - $s2 as scratch registers.

	# save the registers
	sw	$s0, -16($sp)	# $s0 random
	sw	$s1, -20($sp)	# $s1 will hold generator and min
	sw	$s2, -24($sp)	# $s2 will hold new seed and max
	
	# linear congruence
	lw	$s1, RGEN	# load the generator
	lw	$s2, rSeed	# last seed
	multu	$s1, $s2	# result goes in hi/lo registers
	mfhi	$s0		# lo result is new seed
	mflo	$s2		# hi result is new random
	sw	$s2, rSeed

	# fit the random into the range
	lw	$s2, -12($sp)	# get the max
	lw	$s1, -8($sp)    # get the min
	sub	$s2, $s2, $s1	# s2 is now range (max - min)
	addiu	$s2, $s2, 1	# increment the range
	divu	$s0, $s2	# remainder is in hi register
	mfhi	$s0		# get it back
	addu	$s0, $s0, $s1	# add the minimum to put it in range
	sw	$s0, -4($sp)	# store the random in the return

	# restore the registers
	lw	$s0, -16($sp)	
	lw	$s1, -20($sp)	
	lw	$s2, -24($sp)

	jr	$ra		# return
	
#==============================================================================
# int XYToIndex( int x, int y )
# {
#   // Converts the two-dimensional index pair (x,y) into a
#   // single-dimensional index. The result is y * ROW_WIDTH + x.
#   return y * GRID_WIDTH + x;
# }
#
# Like rand, this uses the stack only for getting and returning values.  
# -4($sp) is the return, -8($sp) is x, and -12($sp) is y.
#==============================================================================
XYToIndex:
	# For this function, we only need to preserve 3 registers.  We use
	# $s0 - $s2 as scratch registers.
	
	# save the registers
	sw	$s0, -16($sp)	# $s0 will hold grid width
	sw	$s1, -20($sp)	# $s1 will hold x
	sw	$s2, -24($sp)	# $s2 will hold y
  
  	# get the values for our calculation
  	lw	$s0, GRID_WIDTH	# load the grid width
  	lw	$s1, -8($sp)	# load x
  	lw	$s2, -12($sp)	# load y
  	
  	# calculate and store in return
  	multu	$s0, $s2	# result goes in hi/lo registers
  	mflo	$s0		# hopefully only need LO
  	addu	$s0, $s0, $s1	# add x
  	sw	$s0, -4($sp)	# store result in return

  	# restore the registers
	lw	$s0, -16($sp)	
	lw	$s1, -20($sp)	
	lw	$s2, -24($sp)

	jr	$ra		# return


#================================================================================
# int IsInBounds( int x, int y )
# {
#   // Returns "true" if x and y are both in-bounds.
#   if (x < 0 || x >= GRID_WIDTH) return false;
#   if (y < 0 || y >= GRID_HEIGHT) return false;
#   return true;
# }
#
# Like rand, this uses the stack only for getting and returning values.  -4($sp)
# is the return, -8($sp) is x, and -12($sp) is y.  Note that because we use a
# width that has an extra character, our first test is actually:
# 	if (x < 0 || x > GRID_WIDTH) return false;
#================================================================================
IsInBounds:
	# For this function, we only need to preserve 3 registers.  We use
	# $s0 - $s2 as scratch registers.
	
	# save the registers
	sw	$s0, -16($sp)	# $s0 will hold bounds for testing and return
	sw	$s1, -20($sp)	# $s1 will hold x
	sw	$s2, -24($sp)	# $s2 will hold y
  
  	# get the values for our calculation
  	lw	$s1, -8($sp)	# load x
  	lw	$s2, -12($sp)	# load y
  	
  	# test width
  	lw	$s0, GRID_WIDTH		# load the grid width
  	bgtu	$s1, $s0, OutOfBounds	# catches both >= grid width and < 0
  	
  	# test height
  	lw	$s0, GRID_HEIGHT	# load the grid height
  	bgeu	$s2, $s0, OutOfBounds	# catches both >= grid height and < 0
  	
  	li	$s0, 1		# neither failed, so set true (1)
  	sw	$s0, -4($sp)
  	j	EndBounds
  	
OutOfBounds:
	li	$s0, 0		# something failed, so set false (0)
	sw	$s0, -4($sp)

EndBounds:
  	# restore the registers
	lw	$s0, -16($sp)	
	lw	$s1, -20($sp)	
	lw	$s2, -24($sp)

	jr	$ra		# return

#==============================================================================
# void Visit( int x, int y )
# {
#   // Starting at the given index, recursively visits every direction in a
#   // randomized order.
#   // Set my current location to be an empty passage.
#   grid[ XYToIndex(x,y) ] = ' ';
#   
#   // Create an local array containing the 4 directions and shuffle their
#   // order.
#   int dirs[4];
#   dirs[0] = NORTH;
#   dirs[1] = EAST;
#   dirs[2] = SOUTH;
#   dirs[3] = WEST;
#   
#   for (int i=0; i<4; ++i)
#   {
#     int r = rand() & 3;
#     int temp = dirs[r];
#     dirs[r] = dirs[i];
#     dirs[i] = temp;
#   }
#   
#   // Loop through every direction and attempt to Visit that direction.
#   for (int i=0; i<4; ++i)
#   {
#     // dx,dy are offsets from current location. Set them based
#     // on the next direction I wish to try.
#     int dx=0, dy=0;
#     switch (dirs[i])
#     {
#       case NORTH: dy = -1; break;
#       case SOUTH: dy = 1; break;
#       case EAST: dx = 1; break;
#       case WEST: dx = -1; break;
#     }
#     
#     // Find the (x,y) coordinates of the grid cell 2 spots
#     // away in the given direction.
#     int x2 = x + (dx<<1);
#     int y2 = y + (dy<<1);
# 
#     if (IsInBounds(x2,y2))
#     {
#       if (grid[ XYToIndex(x2,y2) ] == '#')
#       {
#         // (x2,y2) has not been visited yet... knock down the
#         // wall between my current position and that position
#         grid[ XYToIndex(x2-dx,y2-dy) ] = ' ';
#         
#         // Recursively Visit (x2,y2)
#         Visit(x2,y2);
#       }
#     }
#   }
# }
#
# Visit is the tough one.  Because it is recursive, you have to use a stack-
# frame to properly handle all the levels of recursion.  There is no return
# but x is at -4($sp) and y is at -8($sp).
#==============================================================================
Visit:
	# first, save the old frame pointer and return address on the stack
	# and point the frame pointer to the bottom of the frame. At this
	# point, offsets are relative to the stack pointer, not the frame
	# pointer.
	# TODO: Fill in the code to match the comments.
				# save the old frame pointer
				# save the return address
				# copy the stack pointer to the frame pointer
	sw $fp, -12($sp)
	sw $ra, -16($sp)
	move $fp, $sp
	
	sw $s0, -20($sp)
	sw $s1, -24($sp)
	sw $s2, -28($sp)
	sw $s3, -32($sp)
	sw $s4, -36($sp)
	sw $s5, -40($sp)
	sw $s6, -44($sp)
	sw $s7, -48($sp)
	sw $t0, -52($sp)
	sw $t1, -56($sp)
	sw $t2, -60($sp)
	sw $t3, -64($sp)
	
	
	# now we can save any registers we need. The offsets are the same for
	# both the stack and frame pointers (use the $FP column in the stack
	# frame chart in the project document).
	# TODO: store the registers noted in the stack frame chart
	#	to the appropriate locations.
				# $s0 will hold current x or scratch
				# $s1 will hold current y or scratch
				# $s2 will hold returns from functions
				# $s3 will hold pointer register
				# $s4 will hold character ASCII code
				# $s5 will be a scratch register
				# $s6 will be a loop counter
				# $s7 will be another scratch register
				# $t0 will be used to hold x2
				# $t1 will be used to hold y2
				# $t2 will be used to hold dx
				# $t3 will be used to hold dy
	
  	# ok, before things get too complicated, let's set the current grid
  	# location to ' '.  These registers have just been saved to the 
  	# stack frame so I can overwrite them.  Note that I could use
  	# either $sp or $fp as they are currently pointing to the same
  	# place.
  	lw	$s0, -4($sp)	# load x into $s0
  	lw	$s1, -8($sp)	# load y into $s1
  	lb	$s4, SPACE	# preload a blank character

	# Create an local array containing the 4 directions by loading the
	# direction into $s5 and then storing it into the appropiate location
	# in the stack frome.  Still using either $sp or $fp with the same
	# offsets.
	# TODO: Store $s5 to the appropriate location for each direction
	
	lw $s5, NORTH
	sw $s5, -68($sp)
	lw $s5, EAST
	sw $s5, -72($sp)
	lw $s5, SOUTH
	sw $s5, -76($sp)
	lw $s5, WEST
	sw $s5, -80($sp)
	
	lw	$s5, NORTH
		 		# North goes into the local array index 0
	lw	$s5, EAST
				# East goes into the local array index 1
	lw	$s5, SOUTH
				# South goes into the local array index 2
	lw	$s5, WEST
				# West goes into the local array index 3
				
	# TODO: Finally, set the stack pointer to the top of the stack frame.
	#	After this, items in the stack frame can be accessed by the
	#	stack pointer with positive offsets or the frame pointer
	#	with negative offsets.
				# point to the top of the stack frame

	addiu $sp, $sp, -84


	# Set my current location to be an empty passage.
  	#   grid[ XYToIndex(x,y) ] = ' ';
	sw	$s0, -8($sp)	# push x above current registers on stack
	sw	$s1, -12($sp)   # push y
	jal	XYToIndex
	lw	$s2, -4($sp)	# put return in $s2
	la	$s3, grid	# put base address in $s3
	addu	$s3, $s3, $s2	# add offset into grid
	sb	$s4, 0($s3)	# put a blank at the location

	# Shuffle the local array
	li	$s6, 0		# initialize the loop
	li	$s7, 4		# set loop bound
	
ShuffleLoop:
	bgeu	$s6, $s7, VisitLoopEntry	#when done shuffling, go visit

	# pick a random direction
	li	$s5, 3		# set up to do a random 0 to 3
	sw	$0, -8($sp)	# min param set
	sw	$s5, -12($sp)	# max param set
	jal	rand		# get the random
	lw	$s2, -4($sp)	# and put it in $s2
	
	# set up to swap directions
	la	$s3, 4($sp)	# base address of array in $s3
	la	$s1, 4($sp)     # and in #s1
	li	$s5, 4		# multiply by 4 for offset
	mult	$s2, $s5
	mflo	$s2		# get the result back in $s2
	addu	$s3, $s3, $s2	# add offset to base
	mult	$s6, $s5
	mflo	$s5		# get loopcount offest back in $s5
	addu	$s1, $s1, $s5	# add offset to base
	
	# now $s3 and $s7 point into the array and we swap values
	lw	$s5, 0($s1)
	lw	$s2, 0($s3)
	sw	$s5, 0($s3)
	sw	$s2, 0($s1)
	
	# next loop iteration
	addi	$s6, $s6, 1
  	j	ShuffleLoop

VisitLoopEntry:
	# now we visit; reset the loop counter
	li	$s6, 0

VisitLoop:
	li	$s2, 4	# loop bound
	bgeu	$s6, $s2, VisitReturn	# when done, clean up and return

	#----------------------------------
	# switch statement to set dx and dy
	#----------------------------------
	# get the direction
	li	$s5, 4		# offset by 4s to get direction
	mult	$s6, $s5
	mflo	$s5
	move	$s3, $sp	# base address of array in $s3
	addiu	$s3, $s3, 4	#  "     "      "   "    "  "
	addu	$s3, $s3, $s5
	lw	$s7, 0($s3)	# dir[i] now in $s7

	# $s2 and $s5 will be dx and dy respectively
	li	$s2, 0		#initialize to 0
	
	# use $s5 to hold the directions and test
	lw	$s5, NORTH
	beq	$s7, $s5, SetNorth
	lw	$s5, EAST
	beq	$s7, $s5, SetEast
	lw	$s5, SOUTH
	beq	$s7, $s5, SetSouth

	# not the other three directions, so set West
	li	$s2, -1
	li	$s5, 0
	j	EndDirCase

SetNorth:
	li	$s5, -1
	j	EndDirCase

SetEast:
	li	$s2, 1
	li	$s5, 0
	j	EndDirCase

SetSouth:
	li	$s5, 1

	#---------------------------------
	#  modify dx and dy into x2 and y2
	#---------------------------------
EndDirCase:
	# reload $s1 and $s0 in case we used them for something else
  	lw	$s0, -4($fp)	# load x into $s0
  	lw	$s1, -8($fp)	# load y into $s1

	move	$t2, $s2	# save dx and dy
	move	$t3, $s5
	
	sll	$s2, $s2, 1	# double it;
	addu	$t0, $s2, $s0	# add x, store x2 in $t0
	sll	$s5, $s5, 1	# double it
	addu	$t1, $s5, $s1	# add y, store y2 in $t1
	
	#---------------------------------------------------------
	# nested if statements to see if we recursively call Visit
	#---------------------------------------------------------
	# Is it in bounds ?
	sw	$t0, -8($sp)	# x param = x2
	sw	$t1, -12($sp)	# y param = y2
	jal	IsInBounds	# get the result
	lw	$s2, -4($sp)	# and put it in $s2
	beqz	$s2, NextVisitLoop	# not in bounds so go to next

	# Is it visited already?
	sw	$t0, -8($sp)	# x param = x2
	sw	$t1, -12($sp)	# y param = y2
	jal	XYToIndex	# get the result
	lw	$s2, -4($sp)	# and put it in $s2
	la	$s3, grid	# get the base address of the grid
	addu	$s3, $s3, $s2	# add the offset
	lb	$s5, 0($s3)	# get the byte there
	lb	$s2, POUND	# get a byte to compare
	bne	$s2, $s5, NextVisitLoop	# visited so go to next

	# Not visited, so knock down the wall
	sub	$s5, $t1, $t3	# subtract dy from y2
	sub	$s2, $t0, $t2	# subtract dx from x2
	
	sw	$s2, -8($sp)	# push x2-dx
	sw	$s5, -12($sp)	# push y2-dy
	jal	XYToIndex	# get the offset
	lw	$s7, -4($sp)	# and put it in $s7
	la	$s3, grid	# get base address
	addu	$s3, $s3, $s7	# add them together
	sb	$s4, 0($s3)	# store a blank there
	
	# Call Visit recursively
	# TODO: Uncomment these only AFTER you are sure the rest of Visit works.
	sw	$t0, -4($sp)	# push x2
	sw	$t1, -8($sp)	# push y2
	jal	Visit

NextVisitLoop:
	addiu	$s6, $s6, 1	# increment loop counter
	j	VisitLoop
    
VisitReturn:
	# TODO: Set the stack pointer back to where the frame pointer is.
				# point to the beginning of the stack frame
	move $sp, $fp
	# TODO: restore the registers; don't worry about the local array
	lw	$s0, -20($sp)	# this is an example; you do the rest	
	lw	$s1, -24($sp)
	lw	$s2, -28($sp)
	lw	$s3, -32($sp)
	lw	$s4, -36($sp)
	lw	$s5, -40($sp)
	lw	$s6, -44($sp)
	lw	$s7, -48($sp)
	lw	$t0, -52($sp)
	lw 	$t1, -56($sp)
	lw	$t2, -60($sp)
	lw 	$t3, -64($sp)
	lw 	$ra, -16($sp)
	lw 	$fp, -12($sp)

	# TODO: including the old frame pointer and the return address
	
	# and now we can return
	jr	$ra
	
#==============================================================================
# void PrintGrid()
# {
#   // Displays the finished maze to the screen.
#   for (int y=0; y<GRID_HEIGHT; ++y)
#   {
#     for (int x=0; x<GRID_WIDTH; ++x)
#     {
#       cout << grid[XYToIndex(x,y)];
#     }
#     cout << endl;
#   }
# }
#==============================================================================
PrintGrid:

	# This is even easier than the C++ code because I've set the grid up as 
	# one long string so I can simply use a system service to print it to 
	# the console. Doing character by character printing in MASM was more 
	# complicated. We need to preserve 2 registers, $v0 and $a0 used for
	# this system service.

	# save the registers
	sw	$v0, -4($sp)	# $v0 will be the service code
	sw	$a0, -8($sp)	# $a0 will point to the grid string
	
	# load the values and print
	li	$v0, 4		# print service
	la	$a0, grid	# string to print
	syscall

	# restore the registers
	lw	$v0, -4($sp)	
	lw	$a0, -8($sp)	

	li	$v0, 10		# return
	syscall