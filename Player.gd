extends CharacterBody2D


var SPEED = 200
const JUMP_VELOCITY = -250
var stamina = 100

var jumpAmount = 0

var doubleJump = true
@export var holdingYeti = false
var isSprinting = false

var warningText : Label
var warningTimer : Timer


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var camera
var playerPos = get_position()
var player

func _ready():
	# Reference the Label and Timer nodes.
	#warningText = get_node("playerCam.warningText")
	warningText = $playerCam/warningText
	warningTimer = get_node("warningTimer")
	player = get_node("Player")
	camera = get_node("playerCam")


	# Connect the Timer's "timeout" signal (integer constant 14) to hide the warning.
	warningTimer.timeout.connect(_hide_warning)





func _physics_process(delta):
	# Calculate the player facing direction.
	var camPos = camera.get_position()
	
	var playerFacingDirection = camPos - playerPos
	playerFacingDirection.normalize()

	# Calculate the camera velocity.
	var cameraVelocity = playerFacingDirection * player.velocity.x * delta

	# Move the camera.
	camera.global_position += cameraVelocity

	# Check if the player is moving forward or backwards.
	if playerFacingDirection.x > 0.0:
		# Player is moving forward.
		camera.global_position.y += 100.0 * delta
	elif playerFacingDirection.x < 0.0:
		# Player is moving backwards.
		camera.global_position.y -= 100.0 * delta
	
	movement()
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	print(velocity)
	#print("Stamina: ", stamina," ", "Speed: ", SPEED)
	#print(doubleJump)
	
func movement():
	
	
	#Jumping
	if is_on_floor():
		#resets double jumps
		doubleJump = true
		jumpAmount = 0
	
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept"):
		jumpAmount += 1
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			
		
		#Handle double jumping
		if !is_on_floor() and doubleJump == true and !holdingYeti:
			doubleJump = false
			velocity.y = JUMP_VELOCITY
		elif jumpAmount == 2 and holdingYeti:
			_show_warning("You can't do that while holding the Yeti!")
	
	#Walking
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if Input.is_action_pressed("sprint") and stamina > 0:
		isSprinting = true
		velocity.x = direction * (SPEED + 200)
		stamina = stamina - 1
	else: if stamina < 100:
		SPEED = 200
		stamina += 0.5
	move_and_slide()

func _show_warning(message: String):
	warningText.text = message
	warningText.visible = true
	warningTimer.start(2)  # Display the warning for 5 seconds.

func _hide_warning():
	warningText.visible = false
	warningTimer.stop()
	
