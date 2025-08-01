@tool
extends Area3D
"""
Trigger Area Entity
Repeat

Description: Trigger area3d that turns on when entered.
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


func _func_godot_apply_properties(props: Dictionary):
	# Base Class Props
	target = props.get("target", "")
	targetname  = props.get("targetname", "")
	room_id = props.get("room_id", "")
	is_enabled = props.get("is_enabled", false)

func _ready() -> void:
	# Connect to your own signals
	body_entered.connect(_on_body_entered)
	# Init Entity only in game
	if not Engine.is_editor_hint() and GAME:
		GAME.register_entity(self, self.targetname)

func _on_body_entered(body):
	if body.is_in_group("player"):
		use()

# -- Public API Methods

func enable():
	is_enabled = true

func disable():
	is_enabled = false
func use():
		print("Button pressed! Telling GAME to activate target: '", target, "'")

		if is_enabled:
			if not target.is_empty():
				GAME.send_message(self.target, "use")

		else:
			print("NOT ENABLED")

# --- Helper Functions ---
