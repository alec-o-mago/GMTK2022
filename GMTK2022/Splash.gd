extends Node2D

#The Splash Screen was cut for lack of time

onready var timer = $Timer

func _ready():
	timer.connect("timeout", self, "_on_timer_timeout")

func _on_timer_timeout():
   get_tree().change_scene("res://MainMenu.tscn")
