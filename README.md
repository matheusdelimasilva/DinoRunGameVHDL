# I. DinoRunGameVHDL
This is a game inspired by Chrome's dinosaur game built in an FPGA using VHDL. The game displayed on a monitor using the VGA protocol. The hardware complement consists of a VGA adapter connected to the FPGA and two buttons: reset and jump.

 
# How To Play:
To start controlling the dinosaur, press the red button. The dinosaur begins from the sky, and does a reaction jump after it has reached the ground. One must figure out when to drop the dinosaur from the moving plane so that it does not encounter any of the cacti on the ground. 
Control the dinosaur’s jumps using the red button to avoid more cacti. If you hold down the button, the dinosaur will jump continuously.
If the dinosaur touches a cactus, then the dinosaur stops moving and the game ends. Reset the game by pressing the blue button to play again.


# II. VHDL Methodology
Below are the components of the game. There is a description underneath each component, explaining its purpose and its implementations. 

A. Top Level
How the various components fit together:

High-level diagram of components:

![Diagram](Diagram.png)


Hardware Setup:

![Hardware](Hardware.png)


B. VGA Output

The VGA protocol is a computer chipset standard for displaying color graphics. In this project we are using a VGA adapter, that converts the output signals of the FPGA and converts it to the VGA standard that is read natively by the monitor, displaying a 640x480-pixel image. The VGA adapter has 8 input pins (RED1, RED0, GRN1, GRN0, BLU1, BLU0, HSYNC, VSYNC) and a GND.
 
The VGA protocol uses analog signals, however the FPGA can only produce digital signals. Therefore, each color channel uses two output pins (RED0 and RED1, for example) connected to resistors, essentially creating an analog voltage. Pixels are transmitted a row at a time, starting with the top-left corner (col = 0, row = 0) and scanning down to the bottom. This scan is controlled by the vga component. The functioning of this component has to fit the industry standard timing for the VGA protocol shown in figure 6:
Figure 6: VGA Signal (640 x 480 at 60 Hz) Industry standard timing from www.tinyvga.com 

The VGA component takes the 12MHz clock signal as an input and outputs valid, row, col, HSYNC, and VSYNC. For each clock cycle, the VGA component increments the column counter. It also increments rows when columns are greater or equal than the whole line (which is 800 pixels). At a 60Hz, columns counter reaches its max of 800 in 31.7us, which is faster than the human eye can see, giving the impression that the entire screen is being updated, not a pixel at a time. When the row counter reaches the value of the whole frame (which is 525px) its counter resets. The code for this part can be seen below:

Valid is responsible for knowing if the current pixel (determined by row and column) is in the visible area of 640x480 pixels. Therefore VALID is ‘1’ when the current pixel is in the visible area, and ‘0’ if not. HSYNC is ‘1’ when it is greater or equal than 656 (which includes the visible area of 640px plus the front porch, sync pulse, and back porch) and less than 752. Similarly, VSYNC is only ‘1’ when it is greater or equal than 490 and less than 492. 

HSYNC and VSYNC go directly to the VGA adapter, whereas the signals of “rows”,“columns”, and “valid” are outputted to pattern_gen. Those are used by the pattern_gen component to control the colors of the pixels, essentially creating the graphics of the game. RED, GRN, and BLU inputs control the color of each pixel displayed. This is better explained in the game graphics section.

C. Game Graphics

The game graphics are mainly controlled by the pattern_gen module, which relies on the column and row system described in section B. A pixel on the screen is determined by its column (going from 0 to 640) and row (going from 0 to 480) numbers. This works as a coordinate system. For each pixel, we can control its color using the 6-bit RGB signal, which follows the RGB (Red Green Blue) standard. The red color is represented as “110000”, green is “001100” and blue is “000011”.  
We can control where each object on the screen is by controlling the column and row which it will be.

If we take the player as an example, an std_logic signal called player1 is true if the current column and row (the current pixel) is in the playerX range. This is used to dictate the RGB value for the current pixel, in order to “draw” the player on the screen in its appropriate spot. 

D. Sprites

In order to display the dinosaur and cactus sprites on the monitor, a read-only-memory (ROM) component was created for the dinosaur and another one for a cactus. This ROM component stored a file that contains a 16 by 16 sequence of “0”s and “1”s to represent each of the appropriate sprite– where “1” indicates where the sprite needs to be colored in. Since this game was intended to maintain a similar feel to Google Chrome’s The Dinosaur Game, we decided to design these sprites as pixelated and make our monitor display 2 different colors only. Therefore, we used a binary memory file format for the ROM, with an address depth of 16 and data width of 16. 

For Dino in the Sky, 1 dinosaur sprite and 2 cactus sprites were instantiated. Intermediate signals for each of the sprites’ relative row and column placements were appropriately calculated, and then divided by 2 in order to make the sprite appear larger on the monitor screen. The relative row placement for the dinosaur sprite was calculated using a changing y-position variable because the dinosaur would only move along the y direction of the screen. Meanwhile the relative column placement for the two cactus sprites were calculated using a changing x-position variable because the cacti would only move along the x direction of the screen.

E. Frames and game logic

The movement of the objects on the screen are controlled by the position signals for each object. The position signals that determine the game logic are controlled by different processes. These processes can’t be updated at every rising edge of the clock, because the movements of the objects would be faster than the refresh rate of the screen. To solve that, the rising edge depends on a concept of “frame”, which is the time the FPGA takes to refresh all the pixels on the screen. Thus, all the processes involved with movements in the game run when there is a rising edge of the clock and when row and column are ‘1’, an arbitrary pixel that is outside of the center of the screen (where the objects are). We can see an example here: 

F. Movement

In order to create an illusion of the dinosaur moving through a path, the two cacti scroll to the right in the x direction, while the floor remains in one place and the dinosaur remains in the same x coordinate (only being able to change position in the y direction if the jump button is pressed). 

The shifting of the cacti along the x direction to simulate the dinosaur’s movement was done by adding a constant variable called “CACTUS_SPEED” while the game is still active and until it reaches the end of the screen on the left. When the cactus reached the end of the screen, then it would reappear on the right and repeat the cycle of shifting. In order to create a smooth transition of the cacti gradually appearing on the screen, black columns on either side of the screen were added. 

The two cacti sprites shifted with the same speed, and started at different x coordinate directions on the screen, a certain distance apart. 

G. Jumping

As part of the movement process of the game, the jumping dynamics of the dinosaur is divided with two signals that only affect the dinosaur y-coordinate position. These signals are jumping and falling, which are assigned as low and high values respectively when the game starts. Then the jumping animation starts when the button is pressed and jumping gets assigned a high value on its end, viceversily falling gets assigned a low value; this makes the first condition for the dinosaur to jump. The second condition that needs to be meet is that the position over the y-coordinate plus its diameter divided by 2 must be bigger than the jump height, which is a constant value, this is done in order to avoid any lag, for example that the dinosaur were still on the air when the the button is pressed again and therefore it avoids to jump again.
Once these conditions are met the playerY value, which is merely the y-coordinate of the dinosaur position, will be subtracted from the jump speed, which is the constant value of the speed that takes moving from playerY position to jump height position. In this way the dinosaur moves from the ground to the up to the jump constant height.
While on the other hand, the second signal which is falling, works practically in the same way jump does. When it gets a high value, which is everytime the button is not pressed, and the y-coordinate position is smaller than the constant assigned as default in the y coordinate, is when the dinosaur y coordinate will return to the default position. This is acquired with the addition of fall speed to the playerY value, which is a constant with the exactly same value as the jump speed, however, we decided to call it different to not confuse both processes. 

H. Collisions

The collision detection works with hit boxes, which are invisible squares (with 31x31 pixels) around the objects in the game. For each frame of the game, the code checks for collisions. They happen when we can see an overlap of those hit-boxes by using their coordinates. The example code can be seen below:

When the collision happens, a flag signal gameOver is set to true, which stops all the movements of the game, essentially stopping the game until you reset it. 

I. Button Controls

There were two buttons on the breadboard. The purpose of the blue button was to reset the game when the dino collided into a cactus - it is connected to GND and to the Reset pin of the FPGA. The purpose of the red button was to make the dino jump. The dino starts off in the top-left corner of the monitor and so when a player presses the red button, the dino would “fall” down and then jump, which is why the player has to time when they should press the button. The dino’s initial position was on the green line, however, the initial position eventually being in the top-left corner. The team tried to debug the issue, but the bug could not be found, which is why we made it a unique feature of the game. In terms of implementing this in VHDL, the input button is declared in the entity of button_press.vhd, patter_gen2.vhd, and top.vhd. The overall purposes are implemented throughout the code such that the hardware inputs work simultaneously with the VGA.  

In order to combat metastability, the jump button input was passed through 3 flip flops before being used.
