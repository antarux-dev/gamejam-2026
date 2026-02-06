class_name Globals

static var can_move: bool = false

static var LocalPlayer = null

static var FUCKING_ROOM_LOOP = false;

static func GetMove() -> bool:
	return can_move
	
static func SetMove(NewVal: bool) -> void:
	can_move = NewVal;

static func GetPlayer():
	return LocalPlayer

static func SetLocalPlayer(NewPLayer):
	LocalPlayer = NewPLayer
