extends Node2D
class_name AI
@onready var doctor:Doctor = $".."

@export var minRange:int=100
@export var target:Node2D
@onready var timer = $Timer
@onready var nav:NavigationAgent2D = $NavigationAgent2D

@onready var straight:RayCast2D = $Straight
@onready var chase = $"../States/Chase"

var spread:int=30

var desiredDirection:Vector2

func updateAIpath():
	if(chase.running):
		desiredDirection=Vector2.ZERO
		nav.target_position=target.global_position
		desiredDirection=(nav.get_next_path_position()-global_position).normalized()
		timer.start()
	
	
func start(target:Node2D):
	nav.max_speed=doctor.maxSpeed
	nav.target_desired_distance=minRange
	self.target=target
	timer.start()
	pass
func stop():
	timer.stop()
	
	pass
