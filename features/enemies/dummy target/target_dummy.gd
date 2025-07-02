extends RigidBody3D
@export var health: int = 100


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("bullets"):
		print("Target damaged")
		take_damage(10)
		body.queue_free()

func take_damage(damage_amount: int):
	health -= damage_amount
	print("Target dummy took ", damage_amount, " damage. Health is now: ", health)
	if health <= 0:
		print("Target dummy destroyed")
		queue_free()
