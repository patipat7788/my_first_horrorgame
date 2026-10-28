extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer_ลืมตา
@onready var openeyes: ColorRect = $openeyes

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play("wakeup")
	
	
