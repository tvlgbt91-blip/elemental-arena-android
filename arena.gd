extends Node3D

const FIGHTER_SCRIPT = preload("res://fighter.gd")
const ROSTER = [
    {"name":"Lumine","element":"Anemo","color":Color(0.55,0.86,0.72),"power":"Gale Burst"},
    {"name":"Amber","element":"Pyro","color":Color(1.0,0.34,0.16),"power":"Fiery Rain"},
    {"name":"Lisa","element":"Electro","color":Color(0.68,0.36,0.95),"power":"Violet Arc"},
    {"name":"Barbara","element":"Hydro","color":Color(0.28,0.72,1.0),"power":"Melody Splash"},
    {"name":"Noelle","element":"Geo","color":Color(0.92,0.72,0.48),"power":"Sweeping Time"},
    {"name":"Keqing","element":"Electro","color":Color(0.65,0.35,0.95),"power":"Starward Sword"},
    {"name":"Ganyu","element":"Cryo","color":Color(0.55,0.86,1.0),"power":"Celestial Shower"},
    {"name":"Xiao","element":"Anemo","color":Color(0.25,0.78,0.62),"power":"Bane of All Evil"},
    {"name":"Diluc","element":"Pyro","color":Color(0.82,0.18,0.12),"power":"Dawn"}
]

var player
var enemy
var camera_pivot
var camera
var hud
var status_label
var selected_index := 0
var game_over := false
var arena_radius := 12.0
var mobile_buttons := []

func _ready():
    _make_world()
    _make_arena()
    player = _make_fighter(true, ROSTER[selected_index], Vector3(-3, 0.2, 0))
    player.name = "PlayerTarget"
    enemy = _make_fighter(false, ROSTER[1], Vector3(3, 0.2, 0))
    enemy.name = "EnemyTarget"
    _make_camera()
    _make_hud()
    _make_mobile_controls()
    _update_hud()

func _make_world():
    var world_env = WorldEnvironment.new()
    var env = Environment.new()
    env.background_mode = Environment.BG_SKY
    env.sky = Sky.new()
    env.sky.sky_material = ProceduralSkyMaterial.new()
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.72, 0.82, 1.0)
    env.ambient_light_energy = 0.7
    world_env.environment = env
    add_child(world_env)
    var sun = DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -30, 0)
    sun.light_energy = 1.4
    add_child(sun)

func _make_arena():
    var floor = MeshInstance3D.new()
    var mesh = CylinderMesh.new()
    mesh.top_radius = arena_radius
    mesh.bottom_radius = arena_radius
    mesh.height = 0.7
    floor.mesh = mesh
    floor.position.y = -0.35
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0.20, 0.28, 0.39)
    mat.roughness = 0.82
    floor.material_override = mat
    add_child(floor)
    var body = StaticBody3D.new()
    var shape = CollisionShape3D.new()
    var cylinder = CylinderShape3D.new()
    cylinder.radius = arena_radius
    cylinder.height = 0.7
    shape.shape = cylinder
    shape.position.y = -0.35
    body.add_child(shape)
    add_child(body)
    # Glowing perimeter ring
    var ring = MeshInstance3D.new()
    var torus = TorusMesh.new()
    torus.inner_radius = arena_radius - 0.18
    torus.outer_radius = arena_radius
    ring.mesh = torus
    ring.position.y = 0.04
    var glow = StandardMaterial3D.new()
    glow.albedo_color = Color(0.2, 0.75, 1.0)
    glow.emission_enabled = true
    glow.emission = Color(0.1, 0.55, 1.0)
    glow.emission_energy_multiplier = 1.5
    ring.material_override = glow
    add_child(ring)
    # Decorative pillars
    for i in range(8):
        var a = TAU * float(i) / 8.0
        var pillar = MeshInstance3D.new()
        var pm = CylinderMesh.new()
        pm.top_radius = 0.35
        pm.bottom_radius = 0.55
        pm.height = 2.2
        pillar.mesh = pm
        pillar.position = Vector3(cos(a) * 10.6, 1.1, sin(a) * 10.6)
        var pmat = StandardMaterial3D.new()
        pmat.albedo_color = Color(0.42, 0.55, 0.72)
        pillar.material_override = pmat
        add_child(pillar)

func _make_fighter(is_player: bool, data: Dictionary, at: Vector3):
    var f = CharacterBody3D.new()
    f.set_script(FIGHTER_SCRIPT)
    f.is_player = is_player
    f.display_name = data.name
    f.element = data.element
    f.power_name = data.power
    f.tint = data.color
    f.position = at
    add_child(f)
    return f

func _make_camera():
    camera_pivot = Node3D.new()
    camera_pivot.position = Vector3(0, 2.2, 0)
    player.add_child(camera_pivot)
    camera = Camera3D.new()
    camera.position = Vector3(0, 4.2, 8.5)
    camera.rotation_degrees = Vector3(-18, 0, 0)
    camera.current = true
    camera_pivot.add_child(camera)

func _make_hud():
    hud = CanvasLayer.new()
    add_child(hud)
    var title = Label.new()
    title.text = "ELEMENTAL ARENA"
    title.position = Vector2(24, 16)
    title.add_theme_font_size_override("font_size", 28)
    title.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))
    hud.add_child(title)
    status_label = Label.new()
    status_label.position = Vector2(24, 58)
    status_label.add_theme_font_size_override("font_size", 19)
    hud.add_child(status_label)
    var hint = Label.new()
    hint.text = "PC: WASD mover | J ataque | K poder | Espaço esquiva | Q trocar"
    hint.position = Vector2(24, 92)
    hint.add_theme_font_size_override("font_size", 14)
    hint.add_theme_color_override("font_color", Color(0.82,0.87,0.95))
    hud.add_child(hint)
    var enemy_label = Label.new()
    enemy_label.name = "EnemyInfo"
    enemy_label.position = Vector2(900, 24)
    enemy_label.add_theme_font_size_override("font_size", 20)
    enemy_label.text = "DESAFIANTE: Amber"
    hud.add_child(enemy_label)
    var help = Label.new()
    help.text = "Derrube o adversário para fora da arena!"
    help.position = Vector2(450, 18)
    help.add_theme_font_size_override("font_size", 18)
    help.add_theme_color_override("font_color", Color(1.0,0.85,0.55))
    hud.add_child(help)

func _make_mobile_controls():
    # Simple touch buttons: directional pad + combat actions.
    _add_touch_button("▲", Vector2(104, 470), "move_forward")
    _add_touch_button("▼", Vector2(104, 590), "move_back")
    _add_touch_button("◀", Vector2(44, 530), "move_left")
    _add_touch_button("▶", Vector2(164, 530), "move_right")
    _add_touch_button("ATAQUE", Vector2(1040, 570), "attack", Vector2(150, 64))
    _add_touch_button("PODER", Vector2(1040, 490), "skill", Vector2(150, 64))
    _add_touch_button("ESQUIVA", Vector2(870, 570), "dodge", Vector2(145, 64))
    _add_touch_button("TROCAR", Vector2(870, 490), "swap", Vector2(145, 64))

func _add_touch_button(caption: String, pos: Vector2, action: String, size := Vector2(54,54)):
    var b = Button.new()
    b.text = caption
    b.position = pos
    b.size = size
    b.modulate = Color(0.82, 0.91, 1.0, 0.82)
    b.add_theme_font_size_override("font_size", 16 if size.x > 80 else 22)
    hud.add_child(b)
    b.button_down.connect(func(): _press_action(action, true))
    b.button_up.connect(func(): _press_action(action, false))
    if action == "swap":
        b.button_down.connect(_swap_character)
    mobile_buttons.append(b)

func _press_action(action: String, down: bool):
    if down: Input.action_press(action)
    else: Input.action_release(action)

func _process(_delta):
    if game_over:
        return
    if Input.is_action_just_pressed("swap"):
        _swap_character()
    if player.position.y < -2.0 or Vector2(player.position.x, player.position.z).length() > arena_radius + 1.0:
        _finish(false)
    if enemy.position.y < -2.0 or Vector2(enemy.position.x, enemy.position.z).length() > arena_radius + 1.0:
        _finish(true)
    _update_hud()

func _swap_character():
    if game_over:
        return
    selected_index = (selected_index + 1) % ROSTER.size()
    var data = ROSTER[selected_index]
    player.set_character(data)
    _update_hud()

func _update_hud():
    if is_instance_valid(status_label):
        status_label.text = "%s  |  %s  |  Especial: %s" % [player.display_name, player.element, player.power_name]

func _finish(won: bool):
    game_over = true
    var overlay = ColorRect.new()
    overlay.color = Color(0.02,0.04,0.08,0.82)
    overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    hud.add_child(overlay)
    var result = Label.new()
    result.text = "VITÓRIA!" if won else "VOCÊ SAIU DA ARENA!\nDERROTA"
    result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    result.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    result.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    result.add_theme_font_size_override("font_size", 48)
    result.add_theme_color_override("font_color", Color(0.75,0.92,1.0))
    overlay.add_child(result)
    var restart = Button.new()
    restart.text = "JOGAR NOVAMENTE"
    restart.size = Vector2(240,64)
    restart.position = Vector2(520, 440)
    overlay.add_child(restart)
    restart.pressed.connect(func(): get_tree().reload_current_scene())
