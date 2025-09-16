# JournalUI.gd
extends Window

@onready var log_list = $TabContainer/Logs/ItemList
@onready var log_content = $TabContainer/Logs/RichTextLabel

func _ready():

	# Connect the window's close button signal to our closing function
	self.close_requested.connect(_on_close_requested)

	# Connect the signal for when the player clicks a log entry
	log_list.item_selected.connect(_on_log_selected)


	# Populate the list with any entries that already exist
	_populate_log_list()

func _populate_log_list():
	print("Populating log list...")
	log_list.clear()

	var entries = Journal.get_entries()
	print("Received ", entries.size(), " entries from Journal.")

	for entry in entries:
		print("Adding item: ", entry["title"])
		log_list.add_item(entry["title"])


func _on_log_selected(index: int):
	var entry_data = Journal.get_entries()[index]
	log_content.text = entry_data["content"]

# This function is called when the "X" is clicked
func _on_close_requested():
	# Find the player in the scene tree and call its toggle function
	var player = get_tree().get_first_node_in_group("player")
	if is_instance_valid(player):
		player.toggle_journal()
