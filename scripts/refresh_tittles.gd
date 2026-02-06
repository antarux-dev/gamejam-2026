@tool
extends TileMapLayer

@export var refresh := false : set = _do_refresh

func _do_refresh(value):
	if not value:
		return

	var used_cells := get_used_cells()

	var cells_data := []
	for cell in used_cells:
		cells_data.append({
			"pos": cell,
			"source_id": get_cell_source_id(cell),
			"atlas": get_cell_atlas_coords(cell),
			"alt": get_cell_alternative_tile(cell)
		})

	clear()

	for c in cells_data:
		set_cell(
			c.pos,
			c.source_id,
			c.atlas,
			c.alt
		)

	refresh = false
