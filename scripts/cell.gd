extends Panel

signal cell_selected(pos: int)

var pos: int = 0
var is_clue: bool = false

var _style_normal: StyleBoxFlat
var _style_highlighted: StyleBoxFlat
var _style_num_highlighted: StyleBoxFlat
var _style_selected: StyleBoxFlat

@onready var big_number: Label = $BigNumber
@onready var pencil_grid: GridContainer = $PencilGrid

const THIN: int = 1
const THICK: int = 3

func _ready() -> void:
	big_number.visible = false
	pencil_grid.visible = false

func _make_style(bg: Color, border_col: Color, row: int, col: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.anti_aliasing = false
	s.bg_color = bg
	s.border_color = border_col
	s.border_width_left  = THICK if col % 3 == 0 else THIN
	s.border_width_top   = THICK if row % 3 == 0 else THIN
	s.border_width_right  = THICK if col == 8 else 0
	s.border_width_bottom = THICK if row == 8 else 0
	return s

func set_box_color(color: Color, cell_pos: int) -> void:
	var row: int = cell_pos / 9
	var col: int = cell_pos % 9
	var gray := Color(0.58, 0.58, 0.65)
	var blue := Color(0.30, 0.52, 0.88)

	_style_normal        = _make_style(color,                    gray, row, col)
	_style_highlighted   = _make_style(Color(0.88, 0.92, 0.98),  gray, row, col)
	_style_num_highlighted = _make_style(Color(0.78, 0.86, 0.97), gray, row, col)
	_style_selected      = _make_style(Color(0.80, 0.90, 1.00),  blue, row, col)

	add_theme_stylebox_override("panel", _style_normal)

func setup(cell_pos: int, clue: bool) -> void:
	pos = cell_pos
	is_clue = clue

func refresh(number: int, marks: Array, selected: bool, highlighted: bool, num_highlighted: bool, wrong: bool, completed: bool) -> void:
	_update_background(selected, highlighted, num_highlighted)
	if number != 0:
		_show_number(number, wrong, completed)
	else:
		_show_pencil_marks(marks)

func _show_number(number: int, wrong: bool, completed: bool) -> void:
	big_number.text = str(number)
	big_number.visible = true
	pencil_grid.visible = false
	if wrong:
		big_number.add_theme_color_override("font_color", Color(0.82, 0.15, 0.15))
	elif is_clue:
		var color = Color(0.48, 0.48, 0.58) if completed else Color(0.08, 0.08, 0.15)
		big_number.add_theme_color_override("font_color", color)
	else:
		var color = Color(0.62, 0.72, 0.88) if completed else Color(0.18, 0.38, 0.82)
		big_number.add_theme_color_override("font_color", color)

func _show_pencil_marks(marks: Array) -> void:
	big_number.visible = false
	pencil_grid.visible = marks.size() > 0
	for i in range(9):
		var label: Label = pencil_grid.get_child(i)
		label.text = str(i + 1) if (i + 1) in marks else ""
		label.add_theme_color_override("font_color", Color(0.35, 0.35, 0.45))

func _update_background(selected: bool, highlighted: bool, num_highlighted: bool) -> void:
	if _style_normal == null:
		return
	if selected:
		add_theme_stylebox_override("panel", _style_selected)
	elif num_highlighted:
		add_theme_stylebox_override("panel", _style_num_highlighted)
	elif highlighted:
		add_theme_stylebox_override("panel", _style_highlighted)
	else:
		add_theme_stylebox_override("panel", _style_normal)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		cell_selected.emit(pos)
		accept_event()
