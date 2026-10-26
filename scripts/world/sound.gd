extends Node
var music: AudioStreamPlayer
var muted: bool = false

func _ready() -> void:
	music = AudioStreamPlayer.new()
	music.volume_db = -18
	add_child(music)
	music.finished.connect(func() -> void: music.play())

func region(id: String) -> void:
	if DisplayServer.get_name() == "headless": return
	music.stream = load("res://assets/game/" + id + ".ogg")
	music.play()

func effect(id: String) -> void:
	if DisplayServer.get_name() == "headless": return
	var audio := AudioStreamPlayer.new()
	audio.stream = load("res://assets/custom/footstep.wav" if id == "footstep" else "res://assets/game/"+id+".wav")
	audio.volume_db = -24 if id in ["footstep","fireball"] else -16
	add_child(audio)
	audio.finished.connect(audio.queue_free)
	audio.play()

func toggle() -> void:
	muted = not muted
	AudioServer.set_bus_mute(0, muted)

func stop_all() -> void:
	for child: Node in get_children():
		if child is AudioStreamPlayer:
			child.stop()
			child.stream = null

func _exit_tree() -> void:
	stop_all()
