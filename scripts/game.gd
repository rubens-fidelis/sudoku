extends VBoxContainer

var cells: Array = []
var selected_pos: int = -1
var selected_num: int = 0
var pencil_mode: bool = false
var error_label: Label

@onready var board: GridContainer = $Board
@onready var pencil_toggle: Button = $Toolbar/PencilToggle
@onready var difficulty_label: Label = $Toolbar/DifficultyLabel
@onready var number_picker = $NumberPicker

const CellScene = preload("res://scenes/ui/cell.tscn")
const PADDING: float = 20.0

# Alternating 3x3 box colors for visual separation
const BOX_COLOR_A := Color(1.0, 1.0, 1.0)
const BOX_COLOR_B := Color(1.0, 1.0, 1.0)

func _ready() -> void:
	# Container padding — keeps content away from screen edges
	offset_left   =  PADDING
	offset_right  = -PADDING
	offset_top    =  PADDING
	offset_bottom = -PADDING

	# Spacing between toolbar, board, separator, and picker
	add_theme_constant_override("separation", 16)

	# Board fills container width but does not grow taller than its cells
	board.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

	_style_toolbar()
	_add_error_label()
	_add_separator()
	_build_board()
	_generate_puzzle()
	_connect_signals()

func _style_toolbar() -> void:
	# Spread items: MenuBtn — [spacer] — DifficultyLabel — [spacer] — PencilToggle
	var left_spacer := Control.new()
	left_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	$Toolbar.add_child(left_spacer)
	$Toolbar.move_child(left_spacer, $Toolbar/MenuBtn.get_index() + 1)

	var right_spacer := Control.new()
	right_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	$Toolbar.add_child(right_spacer)
	$Toolbar.move_child(right_spacer, $Toolbar/DifficultyLabel.get_index() + 1)

	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0.93, 0.93, 0.95)
	btn_style.set_corner_radius_all(6)
	btn_style.content_margin_left = 14
	btn_style.content_margin_right = 14
	btn_style.content_margin_top = 7
	btn_style.content_margin_bottom = 7

	for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		$Toolbar/MenuBtn.add_theme_stylebox_override(state, btn_style.duplicate())
	$Toolbar/MenuBtn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	$Toolbar/MenuBtn.add_theme_color_override("font_color", Color(0.2, 0.2, 0.3))
	$Toolbar/MenuBtn.add_theme_color_override("font_hover_color", Color(0.2, 0.2, 0.3))
	$Toolbar/MenuBtn.add_theme_color_override("font_pressed_color", Color(0.2, 0.2, 0.3))
	$Toolbar/MenuBtn.add_theme_font_size_override("font_size", 15)

	difficulty_label.add_theme_color_override("font_color", Color(0.15, 0.15, 0.25))
	difficulty_label.add_theme_font_size_override("font_size", 18)

	var pencil_off := btn_style.duplicate() as StyleBoxFlat
	pencil_off.border_color = Color(0.65, 0.65, 0.72)
	pencil_off.set_border_width_all(1)

	var pencil_on := StyleBoxFlat.new()
	pencil_on.bg_color = Color(0.18, 0.38, 0.82)
	pencil_on.set_corner_radius_all(6)
	pencil_on.content_margin_left = 14
	pencil_on.content_margin_right = 14
	pencil_on.content_margin_top = 7
	pencil_on.content_margin_bottom = 7

	pencil_toggle.add_theme_stylebox_override("normal", pencil_off)
	pencil_toggle.add_theme_stylebox_override("hover", pencil_off.duplicate())
	pencil_toggle.add_theme_stylebox_override("pressed", pencil_on)
	pencil_toggle.add_theme_stylebox_override("hover_pressed", pencil_on.duplicate())
	pencil_toggle.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	pencil_toggle.add_theme_color_override("font_color", Color(0.2, 0.2, 0.3))
	pencil_toggle.add_theme_color_override("font_hover_color", Color(0.2, 0.2, 0.3))
	pencil_toggle.add_theme_color_override("font_pressed_color", Color.WHITE)
	pencil_toggle.add_theme_color_override("font_hover_pressed_color", Color.WHITE)
	pencil_toggle.add_theme_font_size_override("font_size", 15)

func _add_error_label() -> void:
	error_label = Label.new()
	error_label.text = tr_n("MISTAKES_COUNT", "MISTAKES_COUNT", 0) % 0
	error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	error_label.add_theme_color_override("font_color", Color(0.55, 0.55, 0.65))
	error_label.add_theme_font_size_override("font_size", 14)
	add_child(error_label)
	move_child(error_label, board.get_index())

func _add_separator() -> void:
	# Thin line between board and number picker
	var sep := ColorRect.new()
	sep.color = Color(0.78, 0.78, 0.83)
	sep.custom_minimum_size = Vector2(0, 1)
	sep.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(sep)
	move_child(sep, number_picker.get_index())

func _build_board() -> void:
	board.add_theme_constant_override("h_separation", 0)
	board.add_theme_constant_override("v_separation", 0)
	cells.clear()
	for i in range(81):
		var cell = CellScene.instantiate()
		board.add_child(cell)
		cells.append(cell)
		cell.set_box_color(_box_color(i), i)
		cell.cell_selected.connect(_on_cell_selected)
	call_deferred("_resize_cells")

func _box_color(pos: int) -> Color:
	var box_row: int = (pos / 9) / 3
	var box_col: int = (pos % 9) / 3
	return BOX_COLOR_A if (box_row + box_col) % 2 == 0 else BOX_COLOR_B

func _resize_cells() -> void:
	var side: float = floor(size.x / 9.0)
	for cell in cells:
		cell.custom_minimum_size = Vector2(side, side)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_SIZE_CHANGED and cells.size() > 0:
		_resize_cells()

func _generate_puzzle() -> void:
	var sudoku = load("res://scripts/sudoku.gd").new()
	var puzzle = sudoku.generate(GameState.difficulty)
	GameState.setup(puzzle)
	difficulty_label.text = tr("DIFFICULTY_" + GameState.difficulty.to_upper())
	if error_label:
		error_label.text = tr_n("MISTAKES_COUNT", "MISTAKES_COUNT", 0) % 0
	_refresh_all_cells()

func _connect_signals() -> void:
	GameState.board_changed.connect(_on_board_changed)
	GameState.game_won.connect(_on_game_won)
	GameState.errors_changed.connect(_on_errors_changed)
	number_picker.number_pressed.connect(_on_number_pressed)
	number_picker.clear_pressed.connect(_on_clear_pressed)
	pencil_toggle.toggled.connect(_on_pencil_toggled)
	$Toolbar/MenuBtn.pressed.connect(_on_menu_pressed)

func _exit_tree() -> void:
	GameState.board_changed.disconnect(_on_board_changed)
	GameState.game_won.disconnect(_on_game_won)
	GameState.errors_changed.disconnect(_on_errors_changed)

func _refresh_picker() -> void:
	var counts: Array = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	for pos in range(81):
		var num: int = GameState.board[pos]
		if num > 0 and GameState.board[pos] == GameState.solution[pos]:
			counts[num] += 1
	number_picker.refresh(selected_num, counts)

func _refresh_all_cells() -> void:
	for i in range(81):
		cells[i].setup(i, GameState.clues[i])
		_refresh_cell(i)
	_refresh_picker()

func _is_in_context(pos: int) -> bool:
	if selected_pos < 0:
		return false
	var row: int = pos / 9
	var col: int = pos % 9
	var sel_row: int = selected_pos / 9
	var sel_col: int = selected_pos % 9
	if row == sel_row or col == sel_col:
		return true
	return (row / 3 == sel_row / 3) and (col / 3 == sel_col / 3)

func _is_row_complete(row: int) -> bool:
	for col in range(9):
		var p: int = row * 9 + col
		if GameState.board[p] == 0 or GameState.board[p] != GameState.solution[p]:
			return false
	return true

func _is_col_complete(col: int) -> bool:
	for row in range(9):
		var p: int = row * 9 + col
		if GameState.board[p] == 0 or GameState.board[p] != GameState.solution[p]:
			return false
	return true

func _is_box_complete(box_row: int, box_col: int) -> bool:
	for r in range(3):
		for c in range(3):
			var p: int = (box_row * 3 + r) * 9 + (box_col * 3 + c)
			if GameState.board[p] == 0 or GameState.board[p] != GameState.solution[p]:
				return false
	return true

func _refresh_cell(pos: int) -> void:
	var number = GameState.board[pos]
	var marks = GameState.pencil_marks[pos]
	var selected = pos == selected_pos
	var highlighted = not selected and _is_in_context(pos)
	var num_highlighted = not selected and selected_num > 0 and number == selected_num and number != 0
	var wrong = number != 0 and not GameState.clues[pos] \
			and number != GameState.solution[pos]
	var row: int = pos / 9
	var col: int = pos % 9
	var completed = not wrong and (_is_row_complete(row) or _is_col_complete(col) \
			or _is_box_complete(row / 3, col / 3))
	cells[pos].refresh(number, marks, selected, highlighted, num_highlighted, wrong, completed)

func _apply_number(num: int) -> void:
	if selected_pos < 0 or GameState.clues[selected_pos]:
		return
	if pencil_mode:
		GameState.toggle_pencil(selected_pos, num)
		return
	if GameState.board[selected_pos] == GameState.solution[selected_pos]:
		selected_num = num
		return
	GameState.set_number(selected_pos, num)

func _on_cell_selected(pos: int) -> void:
	if pos == selected_pos:
		selected_pos = -1
	else:
		selected_pos = pos
		if selected_num > 0:
			_apply_number(selected_num)
	for i in range(81):
		_refresh_cell(i)

func _on_number_pressed(num: int) -> void:
	if selected_num == num:
		selected_num = 0
	else:
		selected_num = num
		if selected_pos >= 0:
			_apply_number(num)
	for i in range(81):
		_refresh_cell(i)
	_refresh_picker()

func _on_clear_pressed() -> void:
	if selected_pos >= 0:
		GameState.set_number(selected_pos, 0)
	selected_num = 0
	for i in range(81):
		_refresh_cell(i)
	_refresh_picker()

func _on_board_changed(pos: int) -> void:
	_refresh_cell(pos)
	_refresh_picker()

func _on_errors_changed() -> void:
	error_label.text = tr_n("MISTAKES_COUNT", "MISTAKES_COUNT", GameState.error_count) % GameState.error_count

func _on_pencil_toggled(pressed: bool) -> void:
	pencil_mode = pressed
	pencil_toggle.text = tr("PENCIL_ON") if pressed else tr("PENCIL_OFF")

func _on_game_won() -> void:
	get_tree().change_scene_to_file("res://scenes/win_screen.tscn")

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		selected_pos = -1
		selected_num = 0
		for i in range(81):
			_refresh_cell(i)
		_refresh_picker()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and selected_pos >= 0:
		var key = event.keycode
		if key >= KEY_1 and key <= KEY_9:
			var num = key - KEY_0
			selected_num = num
			_apply_number(num)
			for i in range(81):
				_refresh_cell(i)
			_refresh_picker()
		elif key == KEY_0 or key == KEY_BACKSPACE or key == KEY_DELETE:
			GameState.set_number(selected_pos, 0)
			selected_num = 0
			for i in range(81):
				_refresh_cell(i)
			_refresh_picker()
