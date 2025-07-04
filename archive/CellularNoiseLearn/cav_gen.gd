#https://www.youtube.com/watch?v=pCsnxWDx3rM
extends Node2D

# COnstants

const WIDTH = 100
const HEIGHT = 100
const CELL_SIZE = 10

# Create our grid
var grid = []

func _ready() -> void:

	
	# Create 2d array with random walls and floors
	initialize_grid()
	# Apply cellular automata rules to create cave like structures
	generate_cave()
	
	# Visualize the cave
	draw_cave()


"""
Creates our initial random world
nested loops to build 2d array

"""
func initialize_grid():
	# Create an array for each column
	for x in range(WIDTH):
		grid.append([])
		# Number of times defined in our height
		for y in range(HEIGHT):
			# percentage of cells being walls
			grid[x].append(randf()< 0.45)

func generate_cave():
	# Each iteration refines the cave layout
	# More iterations defined cave structures
	# Each iteration creates a new grid based on the current one applying 
	# Rules to each cell
	for i in range(4):
		var new_grid = grid.duplicate(true)
		for x in range(WIDTH):
			for y in range(HEIGHT):
				var wall_count = count_neighboring_walls(x,y)
				if grid[x][y]:
					new_grid[x][y] = wall_count > 3
				else:
					new_grid[x][y] = wall_count > 4
			grid = new_grid


func count_neighboring_walls(x,y):
	var count = 0
	# Count number of walls in the 8 cells surrounding a given cell
	# Uses nested loops to check all adjacent cells including diagonals
	# Run from -1 to 1
	for i in range(-1,2):
		for j in range(-1,2):
			if i == 0 and j == 0:
				continue
			var nx = x + i
			var ny = y + j
			if nx < 0 or nx >= WIDTH or ny < 0 or ny >= HEIGHT:
				count +=1
			elif grid[nx][ny]:
				count +=1
	return count

func draw_cave():
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var cell = ColorRect.new()
			cell.size = Vector2(CELL_SIZE, CELL_SIZE)
			cell.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
			cell.color = Color.DARK_SLATE_GRAY if grid[x][y] else Color.TAN
			add_child(cell)
