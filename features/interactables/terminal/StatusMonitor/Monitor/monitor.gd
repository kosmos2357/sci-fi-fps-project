extends StaticBody3D
@onready var status_label = $SubViewport/StatusUi/VBoxContainer/StatusLabel
# Targetname of entity
@export var entity_to_monitor: String = "button_light"

# A counter for the number of presses
var press_count: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect to the GameManager's global announcement signal
	if GAME:
		GAME.entity_activated.connect(_on_entity_messaged)

	# Set initial text
	status_label.text = "Presses: 0"


#This function will be called every time ANY message is sent in the game
func _on_entity_messaged(activator_entity: String, targetted_entities: String, message: String):
	print("Monitor received message. Target: '", activator_entity, "', Message: '", message, "'", " Entities Targetted:  ", targetted_entities)
	print("GAME HISTORY", GAME.get_history())
	# Now, let's see what we are specifically looking for
	print("Monitor is looking for target: '", entity_to_monitor, "'")
	# We only care about "use" messages sent to the specific entity we are monitoring
	if activator_entity == entity_to_monitor and message == "use":
		press_count += 1
		print("PRess_count ", press_count)
		status_label.text = "Presses: " + str(press_count)

func update_status(new_status: String):
	status_label.text = new_status
