extends Sprite

func _ready():
	$AnimationPlayer.play("spawn")

func init(type, x, y)->void: #pseudo-constructor for easily initializing values
	frame = type
	position.x = x
	position.y = y

func increase_frame()->void:
	frame += 1

func queue_animation(x, y, kill)->void: # moves dice and unloads it if it's marked to "kill"
	$Tween.interpolate_property(self, "position", position,Vector2(x,y), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	if kill:
		$Tween.interpolate_callback(self, 0.2, "queue_free")
	$Tween.start()
