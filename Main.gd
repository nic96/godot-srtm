extends Spatial


const ROT_SPEED = 0.15
var rot_x = 0
var rot_y = 0
var rot_z = 0


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	var speed = 2000
	var direction = Vector3()
	if Input.is_action_pressed("key_forward"):
		direction -= $KinematicBody/Camera.get_transform().basis.z
	if Input.is_action_pressed("key_backward"):
		direction += $KinematicBody/Camera.get_transform().basis.z

	if Input.is_action_pressed("key_left"):
		direction -= $KinematicBody/Camera.get_transform().basis.x
	if Input.is_action_pressed("key_right"):
		direction += $KinematicBody/Camera.get_transform().basis.x

	$KinematicBody.move_and_slide(direction * speed * delta)


func _unhandled_input(ev):
	if (ev is InputEventMouseButton and ev.button_mask == BUTTON_MASK_LEFT):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if (ev is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
		rot_y += ev.relative.x * ROT_SPEED
		rot_z += ev.relative.y * ROT_SPEED

		var t = Transform()
		t = t.rotated(Vector3(1,0,0),-rot_z * PI / 180.0)
		t = t.rotated(Vector3(0,1,0),-rot_y * PI / 180.0)

		$KinematicBody/Camera.transform.basis = t.basis

	if (ev.is_action_pressed("ui_cancel")):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
