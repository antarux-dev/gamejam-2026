class_name Globals

static var can_move: bool = false

static func GetMove() -> bool:
	return can_move
	
static func SetMove(NewVal: bool) -> void:
	can_move = NewVal;
