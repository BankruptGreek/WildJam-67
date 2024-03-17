extends Node2D
class_name AI
@onready var doctor:Doctor = $".."

@export var minRange:int=100
@export var my_target:Node2D=self
@onready var nav:NavigationAgent2D = $NavigationAgent2D

@onready var chase = $"../States/Chase"

var spread:int=30

var desiredDirection:Vector2

func updateAIpath():
	if(chase.d.isChasing):
		desiredDirection=Vector2.ZERO
		nav.target_position=my_target.global_position
		desiredDirection=(nav.get_next_path_position()-global_position).normalized()
	
	
func start(target:Node2D):
	nav.max_speed=doctor.maxSpeed
	nav.target_desired_distance=minRange
	my_target=target

func stop():
	my_target=self

