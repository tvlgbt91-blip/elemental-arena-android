extends CharacterBody3D

var is_player := false
var display_name := "Fighter"
var element := "Anemo"
var power_name := "Elemental Burst"
var tint := Color.CYAN
var health := 100.0
var speed := 6.5
var attack_cooldown := 0.0
var skill_cooldown := 0.0
var dodge_cooldown := 0.0
var ai_timer := 0.0
var target: Node3D
var invulnerable := 0.0
var body_mesh: MeshInstance3D
var hp_bar: MeshInstance3D

func _ready():
    _build_body()
    var collision = CollisionShape3D.new()
    var capsule = CapsuleShape3D.new()
    capsule.radius = 0.48
    capsule.height = 1.9
    collision.shape = capsule
    collision.position.y = 0.95
    add_child(collision)
    if not is_player:
        target = get_parent().get_node_or_null("PlayerTarget")

func _build_body():
    body_mesh = MeshInstance3D.new()
    var capsule = CapsuleMesh.new()
    capsule.radius = 0.48
    capsule.height = 1.8
    body_mesh.mesh = capsule
    body_mesh.position.y = 0.95
    var material = StandardMaterial3D.new()
    material.albedo_color = tint
    material.metallic = 0.12
    material.roughness = 0.48
    material.emission_enabled = true
    material.emission = tint * 0.12
    body_mesh.material_override = material
    add_child(body_mesh)
    # A small bright elemental core on the chest.
    var core = MeshInstance3D.new()
    var sphere = SphereMesh.new()
    sphere.radius = 0.19
    sphere.height = 0.38
    core.mesh = sphere
    core.position = Vector3(0, 1.15, -0.43)
    var cm = StandardMaterial3D.new()
    cm.albedo_color = Color.WHITE
    cm.emission_enabled = true
    cm.emission = tint
    cm.emission_energy_multiplier = 2.0
    core.material_override = cm
    add_child(core)

func set_character(data: Dictionary):
    display_name = data.name
    element = data.element
    power_name = data.power
    tint = data.color
    var material = body_mesh.material_override as StandardMaterial3D
    material.albedo_color = tint
    material.emission = tint * 0.12
    for child in get_children():
        if child is MeshInstance3D and child != body_mesh:
            var cm = child.material_override as StandardMaterial3D
            if cm:
                cm.emission = tint
    health = 100.0

func _physics_process(delta):
    attack_cooldown = maxf(0.0, attack_cooldown - delta)
    skill_cooldown = maxf(0.0, skill_cooldown - delta)
    dodge_cooldown = maxf(0.0, dodge_cooldown - delta)
    invulnerable = maxf(0.0, invulnerable - delta)
    if is_player:
        _player_control(delta)
    else:
        _enemy_control(delta)
    if not is_on_floor():
        velocity.y -= 22.0 * delta
    move_and_slide()

func _player_control(_delta):
    var input_vec = Vector2.ZERO
    input_vec.y = float(Input.is_action_pressed("move_back")) - float(Input.is_action_pressed("move_forward"))
    input_vec.x = float(Input.is_action_pressed("move_right")) - float(Input.is_action_pressed("move_left"))
    if Input.is_key_pressed(KEY_W): input_vec.y -= 1
    if Input.is_key_pressed(KEY_S): input_vec.y += 1
    if Input.is_key_pressed(KEY_A): input_vec.x -= 1
    if Input.is_key_pressed(KEY_D): input_vec.x += 1
    input_vec = input_vec.normalized()
    var dir = Vector3(input_vec.x, 0, input_vec.y)
    velocity.x = dir.x * speed
    velocity.z = dir.z * speed
    if dir.length() > 0.1:
        look_at(global_position + dir, Vector3.UP)
    if Input.is_action_just_pressed("attack") or Input.is_key_pressed(KEY_J):
        _attack()
    if Input.is_action_just_pressed("skill") or Input.is_key_pressed(KEY_K):
        _skill()
    if Input.is_action_just_pressed("dodge") or Input.is_key_pressed(KEY_SPACE):
        _dodge()

func _enemy_control(delta):
    var p = get_parent().get_node_or_null("PlayerTarget")
    if p == null:
        # Arena assigns the player reference after creation.
        p = get_parent().get("player")
    if p == null or not is_instance_valid(p):
        return
    var diff = p.global_position - global_position
    diff.y = 0
    var distance = diff.length()
    if distance > 1.7:
        var dir = diff.normalized()
        velocity.x = dir.x * speed * 0.72
        velocity.z = dir.z * speed * 0.72
        look_at(global_position + dir, Vector3.UP)
    else:
        velocity.x = move_toward(velocity.x, 0, 20 * delta)
        velocity.z = move_toward(velocity.z, 0, 20 * delta)
        ai_timer -= delta
        if ai_timer <= 0:
            ai_timer = 1.15
            _attack()
    if distance < 4.5 and skill_cooldown <= 0:
        _skill()

func _attack():
    if attack_cooldown > 0:
        return
    attack_cooldown = 0.65
    var opponent = _opponent()
    if opponent and global_position.distance_to(opponent.global_position) < 2.8:
        opponent.take_hit(13.0, (opponent.global_position - global_position).normalized() * 5.0)

func _skill():
    if skill_cooldown > 0:
        return
    skill_cooldown = 4.0
    var opponent = _opponent()
    _burst_visual()
    if opponent and global_position.distance_to(opponent.global_position) < 6.0:
        var push = (opponent.global_position - global_position).normalized()
        opponent.take_hit(22.0, push * 12.0 + Vector3.UP * 2.0)

func _dodge():
    if dodge_cooldown > 0:
        return
    dodge_cooldown = 1.2
    invulnerable = 0.35
    var dir = -global_transform.basis.z
    velocity.x = dir.x * 13.0
    velocity.z = dir.z * 13.0

func _opponent():
    if is_player:
        return get_parent().get("enemy")
    return get_parent().get("player")

func take_hit(amount: float, impulse: Vector3):
    if invulnerable > 0:
        return
    health -= amount
    velocity += impulse
    if health <= 0:
        # Knockout also launches the fighter outward.
        var outward = Vector3(global_position.x, 0, global_position.z).normalized()
        velocity += outward * 16.0 + Vector3.UP * 4.0

func _burst_visual():
    var fx = MeshInstance3D.new()
    var sphere = SphereMesh.new()
    sphere.radius = 2.2
    sphere.height = 4.4
    fx.mesh = sphere
    fx.position.y = 1.0
    var m = StandardMaterial3D.new()
    m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    m.albedo_color = Color(tint.r, tint.g, tint.b, 0.28)
    m.emission_enabled = true
    m.emission = tint
    fx.material_override = m
    add_child(fx)
    var tween = create_tween()
    tween.tween_property(fx, "scale", Vector3(2.2,2.2,2.2), 0.32)
    tween.parallel().tween_property(m, "albedo_color:a", 0.0, 0.32)
    tween.tween_callback(fx.queue_free)
