# In NavLinkLogic.gd
@tool
extends NavigationLink3D

# This will hold the entity's unique name from TrenchBroom.
var targetname: String = ""
var target: String = ""
# This function receives the properties from the importer.
func _func_godot_apply_properties(props: Dictionary):
	targetname = props.get("targetname", "")
	target = props.get("target", "")

# This function runs when the game starts.
func _ready():
	if Engine.is_editor_hint(): return

	# Register with the GameManager so other entities can find and activate us.
	if not targetname.is_empty() and GAME:
		GAME.set_targetname(self, targetname)
	if not target.is_empty() and GAME:
		GAME.set_targets(target, self)

# This is the function that our door will call.
# It simply flips the 'enabled' state of the NavigationLink3D.
func use(activator):
	set_enabled(not is_enabled())
	if is_enabled():
		print("NavLink '", targetname, "' was ENABLED.")
	else:
		print("NavLink '", targetname, "' was DISABLED.")
