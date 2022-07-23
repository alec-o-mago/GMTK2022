extends Node2D


const DISTANCE = 64

onready var grid = [[0,0,0],[0,0,0],[0,0,0]]
onready var grid_sprites = [[null,null,null],[null,null,null],[null,null,null]] #storing the position of the sprites for animations
onready var operations = []
onready var dice_scene = load("res://Levels/2048/Dice.tscn")
onready var score = 0
onready var valid_move_up = true #valid move verification was not implemented
onready var valid_move_down = true
onready var valid_move_left = true
onready var valid_move_right = true

func _ready()->void: #this function is called once after initialization
	randomize()  #generates new seed for random functions
	$ResultPanel/TryAgainButton.connect("button_down",self,"_try_again")
	spawn_dice() #initialize grid with 2 dices
	spawn_dice()

func _input(event)->void: #this function is called at every user input
	if valid_move_up and event.is_action_pressed("ui_up"):
		move_up() #handling all types of movement in different functions results in repeated code, but also makes it easier to understand and maintain.
	elif valid_move_down and event.is_action_pressed("ui_down"):
		move_down()
	elif valid_move_left and event.is_action_pressed("ui_left"):
		move_left()
	elif valid_move_right and event.is_action_pressed("ui_right"):
		move_right()

func _process(delta): #this function is called at every frame
	$ScoreLabel.text = "Score: "+str(score)

func _try_again():
	get_tree().reload_current_scene()


func print_grid()->void: #debugging
	for row in grid:
		print(row)

func spawn_dice()->void:
	var spots = find_empty_spots()
	var spots_size = spots.size()
	if spots_size == 0:
		#print("Game Over :(") #debugging
		game_over(false)
	else:
		var pos = spots[randi() % spots_size]
		var value = 1 if ((randi() % 10) != 0) else 2 #inline-style if. 90% chance of '1'. 10% chance of '2'.
		create_dice(value, pos.x, pos.y)

func create_dice(value, row, col)->void:
	grid[row][col] = value
	var dice = dice_scene.instance()
	dice.init(value-1, col*DISTANCE, row*DISTANCE)
	grid_sprites[row][col] = dice
	$Dices.add_child(dice)
	#print_grid() #debugging

func find_empty_spots()->Array:
	var spots = []
	for row in range(3):
		for col in range(3):
			if grid[row][col] == 0:
				spots.append(Vector2(row,col))
	return spots

func move_up()->void:
	#print('move_up()') #debugging
	var just_merged:bool = false #should not merge consecutively
	for col in range(3):
		for row in [1,2,1,2]:
			if grid[row][col] != 0:
				if grid[row-1][col] == 0:
					just_merged = false
					grid[row-1][col] = grid[row][col]
					grid[row][col] = 0
					#animate movement
					grid_sprites[row][col].queue_animation(col*DISTANCE, (row-1)*DISTANCE, false)
					grid_sprites[row-1][col] = grid_sprites[row][col]
					grid_sprites[row][col] = null
				elif !just_merged and grid[row][col] == grid[row-1][col]:
					just_merged = true
					grid[row-1][col] += 1
					grid[row][col] = 0
					#score
					score += grid[row-1][col]*10
					#animate movement
					grid_sprites[row][col].queue_animation(col*DISTANCE, (row-1)*DISTANCE, false)
					grid_sprites[row-1][col].queue_animation(col*DISTANCE, (row-1)*DISTANCE, true)
					grid_sprites[row-1][col] = grid_sprites[row][col]
					grid_sprites[row][col] = null
					grid_sprites[row-1][col].frame += 1 # increases dice number
					if (grid_sprites[row-1][col].frame == 6):
						game_over(true)
			else:
				just_merged = false
		just_merged = false
	spawn_dice()

func move_down()->void:
	#print('move_down()') #debugging
	var just_merged:bool = false #should not merge consecutively
	for col in range(3):
		for row in [1,0,1,0]:
			if grid[row][col] != 0:
				if grid[row+1][col] == 0:
					just_merged = false
					grid[row+1][col] = grid[row][col]
					grid[row][col] = 0
					#score
					score += grid[row+1][col]*10
					#animate movement
					grid_sprites[row][col].queue_animation(col*DISTANCE, (row+1)*DISTANCE, false)
					grid_sprites[row+1][col] = grid_sprites[row][col]
					grid_sprites[row][col] = null
				elif !just_merged and grid[row][col] == grid[row+1][col]:
					just_merged = true
					grid[row+1][col] += 1
					grid[row][col] = 0
					#animate movement
					grid_sprites[row][col].queue_animation(col*DISTANCE, (row+1)*DISTANCE, false)
					grid_sprites[row+1][col].queue_animation(col*DISTANCE, (row+1)*DISTANCE, true)
					grid_sprites[row+1][col] = grid_sprites[row][col]
					grid_sprites[row][col] = null
					grid_sprites[row+1][col].frame += 1 # increases dice number
					if (grid_sprites[row+1][col].frame == 6):
						game_over(true)
			else:
				just_merged = false
		just_merged = false
	spawn_dice()

func move_left()->void:
	#print('move_left()') #debugging
	var just_merged:bool = false #should not merge consecutively
	for row in range(3):
		for col in [1,2,1,2]:
			if grid[row][col] != 0:
				if grid[row][col-1] == 0:
					just_merged = false
					grid[row][col-1] = grid[row][col]
					grid[row][col] = 0
					#animate movement
					grid_sprites[row][col].queue_animation((col-1)*DISTANCE, row*DISTANCE, false)
					grid_sprites[row][col-1] = grid_sprites[row][col]
					grid_sprites[row][col] = null
				elif !just_merged and grid[row][col] == grid[row][col-1]:
					just_merged = true
					grid[row][col-1] += 1
					grid[row][col] = 0
					#score
					score += grid[row][col-1]*10
					#animate movement
					grid_sprites[row][col].queue_animation((col-1)*DISTANCE, row*DISTANCE, false)
					grid_sprites[row][col-1].queue_animation((col-1)*DISTANCE, row*DISTANCE, true)
					grid_sprites[row][col-1] = grid_sprites[row][col]
					grid_sprites[row][col] = null
					grid_sprites[row][col-1].frame += 1 # increases dice number
					if (grid_sprites[row][col-1].frame == 6):
						game_over(true)
			else:
				just_merged = false
		just_merged = false
	spawn_dice()

func move_right()->void:
	#print('move_right()') #debugging
	var just_merged:bool = false #should not merge consecutively
	for row in range(3):
		for col in [1,0,1,0]:
			if grid[row][col] != 0:
				if grid[row][col+1] == 0:
					just_merged = false
					grid[row][col+1] = grid[row][col]
					grid[row][col] = 0
					#animate movement
					grid_sprites[row][col].queue_animation((col+1)*DISTANCE, row*DISTANCE, false)
					grid_sprites[row][col+1] = grid_sprites[row][col]
					grid_sprites[row][col] = null
				elif !just_merged and grid[row][col] == grid[row][col+1]:
					just_merged = true
					grid[row][col+1] += 1
					grid[row][col] = 0
					#score
					score += grid[row][col+1]*10
					#animate movement
					grid_sprites[row][col].queue_animation((col+1)*DISTANCE, row*DISTANCE, false)
					grid_sprites[row][col+1].queue_animation((col+1)*DISTANCE, row*DISTANCE, true)
					grid_sprites[row][col+1] = grid_sprites[row][col]
					grid_sprites[row][col] = null
					grid_sprites[row][col+1].frame += 1 # increases dice number
					if (grid_sprites[row][col+1].frame == 6):
						game_over(true)
			else:
				just_merged = false
		just_merged = false
	spawn_dice()

func game_over(win):
	if win:
		$ResultPanel/ResultLabel.text = "You Won! :)"
	else:
		$ResultPanel/ResultLabel.text = "You Lost! :("
	$ResultPanel.visible = true
