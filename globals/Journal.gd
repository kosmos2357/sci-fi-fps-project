# Journal.gd
extends Node

var discovered_entries = [
	# Add some dummy data for testing
	{"title": "Welcome Log", "content": "This is the first test log entry."},
	{"title": "Security Memo", "content": "All personnel must update their credentials."}
]

func add_entry(entry_data: Dictionary):
	for entry in discovered_entries:
		if entry["title"] == entry_data["title"]:
			return
	discovered_entries.append(entry_data)

func get_entries() -> Array:
	return discovered_entries
