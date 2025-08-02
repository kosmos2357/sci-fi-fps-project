@tool
extends Area3D
"""
Pressure Plate
"""

"""
Entity properties for func_godot
"""
# Base Class Props
@export var target: String = ""
@export var targetname: String = ""
@export var room_id: String = ""
@export var is_enabled: bool

# -- Entity Specific
var bodies_on_plate = []

func _func_godot_apply_properties(props: Dictionary):
	# Base Class Props
	target = props.get("target", "")
	targetname  = props.get("targetname", "")
	room_id = props.get("room_id", "")
	is_enabled = props.get("is_enabled", false)

func _ready() -> void:
	if not Engine.is_editor_hint():
		# Check if the signal is NOT already connected before connecting it.
		if not body_entered.is_connected(_on_body_entered):
			body_entered.connect(_on_body_entered)

		if not body_exited.is_connected(_on_body_exited):
			body_exited.connect(_on_body_exited)

		if GAME:
			GAME.register_entity(self, self.targetname)

# -- Public API Methods

func enable():
	is_enabled = true

func disable():
	is_enabled = false

func use():
		print("Trigger activated! Telling GAME to activate target: '", target, "'")

		if is_enabled:
			if not target.is_empty():
				GAME.send_message(self.target, "use")

		else:
			print("NOT ENABLED")

# --- Helper Functions ---

# -- Node Methods ---
func _on_body_entered(body):
	if not body is PhysicsBody3D:
		return
	if not bodies_on_plate.has(body):
		bodies_on_plate.append(body)
	if bodies_on_plate.size() == 1:
		print("Pressure Plate Activated")
		use()

func _on_body_exited(body: Node3D) -> void:
	if not body is PhysicsBody3D:
		return
	if bodies_on_plate.has(body):
		bodies_on_plate.erase(body)
	if bodies_on_plate.is_empty():
		print("Pressure Plate Deactivated")
		use()
