class_name BaseState
extends Node

"""
Base State Class for player character
"""

# Reference to my character node
var player: CharacterBody3D

func enter():
	pass #Override this in State file

func exit():
	pass #Override this in State file

func process_physics(delta):
	pass #Override this in State file
