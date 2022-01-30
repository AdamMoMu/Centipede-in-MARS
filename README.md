# CSC258_Centipede
A version of the Centipede game coded in MIPS Assembly using MARS.

In order to run it MARS (MIPS Assembler and Runtime Simulator) will be needed.
Download at: http://courses.missouristate.edu/kenvollmar/mars/

# Steps to run game,
  1.Open the file centipede.s in MARS
  2.Go to Tools -> Bitmap Display
  3.Keep Bitmap Display in View and set Unit Width and Height to 8, Display Width and Height to 512, and Base Address to 0x10008000 ($gp)
  4.Click Connect to MIPS and expand Bitmap Display window until black display is fully visible
  5.Next go to Tools -> Keyboard and Display MMIO Simulator
  6.Click Connect to MIPS. To play the game you will have to type in the textbox in this window
  7.Go to Run -> Assemble
  8.Finally, you can Run -> Go or click the play button to start
The Game will be displayed on the Bitmap Display and in order for inputs to work they have to be entered in the textbox in the Keyboard and Display MMIO Simulator.

# Controls:
  +	j - move left
  +	k - move right
  +	x - shoot
  +	r - restart
  +	c - exit
  
Point of the game is to score as many points as possible, while not allowing centipede to strike you. Shooting the centipede breaks it apart and spawns a mushroom. Collisions with mushrooms make the centipede descend faster. You have 5 lives.

More information is present in the top of the centipede.s document
