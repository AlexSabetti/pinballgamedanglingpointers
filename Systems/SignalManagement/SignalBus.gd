class_name SignalBus
extends Node

# For when the player's ball hits a bumper
signal bumper_hit(obj)

# signals left/right paddles to rotate if boolean is true. signals them to return back to idle state if false
signal left_paddle(pressed:bool)
signal right_paddle(pressed:bool)

# signals the current "pinball" that the move button is pressed if bool is true. 
signal move_ball_left(pressed:bool)
signal move_ball_right(pressed:bool)

# signals the game to pause or unpause
signal pause_game()
signal unpause_game()  
