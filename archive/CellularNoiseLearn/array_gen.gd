extends Node2D

const WIDTH = 10
const CELL_SIZE = 100
const HEIGHT = 1
var arr = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	init()
	generate()


func init():
	for i in range(WIDTH):
		arr.append(randf() < 0.45)
		if arr[i] == true:
			arr[i] = 1
		else:
			arr[i] = 0
	print(arr)

func generate():
	var next_arr = []
	next_arr.resize(WIDTH)

	for i in range(WIDTH):
		var current_cell_state = arr[i]
		var new_cell_state = current_cell_state

		# Check
		if i + 1 < arr.size():
			var right_neighbor_state = arr[i+1]

			if right_neighbor_state == 1:
				new_cell_state = 0
		next_arr[i] = new_cell_state

	arr = next_arr
# The _draw() function is a special Godot function that is called by the engine
# whenever the node needs to be drawn or when we call queue_redraw().
func _draw():
	# Loop through our final 'arr' data
	for i in range(WIDTH):
		# Determine the position and color for the cell
		var position = Vector2(i * CELL_SIZE, 0)
		var color = Color.DARK_SLATE_GRAY if arr[i] == 1 else Color.TAN

		# Draw a rectangle for the cell at the calculated position and color.
		# This is much faster than creating a ColorRect node.
		draw_rect(Rect2(position, Vector2(CELL_SIZE, CELL_SIZE)), color)

		# To create a border, we simply draw a second, smaller rectangle on top.
		# This is a simple but effective way to create a grid look.
		var border_size = 1
		var inner_rect_pos = position + Vector2(border_size, border_size)
		var inner_rect_size = Vector2(CELL_SIZE - border_size * 2, CELL_SIZE - border_size * 2)
		draw_rect(Rect2(inner_rect_pos, inner_rect_size), color)

		# Or, to draw just an outline:
		# draw_rect(Rect2(position, Vector2(CELL_SIZE, CELL_SIZE)), Color.BLACK, false, 1.0)
