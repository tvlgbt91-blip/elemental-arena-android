extends Node
func _ready():
    _bind("move_forward")
    _bind("move_back")
    _bind("move_left")
    _bind("move_right")
    _bind("attack")
    _bind("skill")
    _bind("dodge")
    _bind("swap")
func _bind(action):
    if not InputMap.has_action(action):
        InputMap.add_action(action)
