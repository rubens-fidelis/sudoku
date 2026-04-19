extends HBoxContainer

signal number_pressed(num: int)
signal clear_pressed

var _normal_style: StyleBoxFlat
var _selected_style: StyleBoxFlat

func _ready() -> void:
	for i in range(1, 10):
		get_node("Num%d" % i).pressed.connect(_on_number_pressed.bind(i))
	$Clear.pressed.connect(_on_clear_pressed)
	_style_buttons()

func _style_buttons() -> void:
	_normal_style = StyleBoxFlat.new()
	_normal_style.bg_color = Color(1.0, 1.0, 1.0)
	_normal_style.border_color = Color(0.72, 0.72, 0.76)
	_normal_style.set_border_width_all(1)
	_normal_style.set_corner_radius_all(6)

	_selected_style = StyleBoxFlat.new()
	_selected_style.bg_color = Color(0.78, 0.86, 0.97)
	_selected_style.border_color = Color(0.25, 0.48, 0.9)
	_selected_style.set_border_width_all(2)
	_selected_style.set_corner_radius_all(6)

	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(0.82, 0.9, 1.0)
	hover.border_color = Color(0.25, 0.48, 0.9)
	hover.set_border_width_all(1)
	hover.set_corner_radius_all(6)

	var pressed_style := StyleBoxFlat.new()
	pressed_style.bg_color = Color(0.18, 0.38, 0.82)
	pressed_style.border_color = Color(0.18, 0.38, 0.82)
	pressed_style.set_border_width_all(1)
	pressed_style.set_corner_radius_all(6)

	for child in get_children():
		if child is Button:
			child.add_theme_stylebox_override("normal", _normal_style.duplicate())
			child.add_theme_stylebox_override("hover", hover.duplicate())
			child.add_theme_stylebox_override("pressed", pressed_style.duplicate())
			child.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
			child.add_theme_font_size_override("font_size", 20)
			child.add_theme_color_override("font_color", Color(0.1, 0.1, 0.2))
			child.add_theme_color_override("font_hover_color", Color(0.1, 0.1, 0.2))
			child.add_theme_color_override("font_pressed_color", Color.WHITE)

func refresh(sel_num: int, counts: Array) -> void:
	for i in range(1, 10):
		var btn: Button = get_node("Num%d" % i)
		btn.add_theme_stylebox_override("normal",
				_selected_style if i == sel_num else _normal_style)
		if counts[i] > 9:
			btn.add_theme_color_override("font_color", Color(0.82, 0.15, 0.15))
			btn.add_theme_color_override("font_hover_color", Color(0.82, 0.15, 0.15))
		elif counts[i] == 9:
			btn.add_theme_color_override("font_color", Color(0.65, 0.68, 0.75))
			btn.add_theme_color_override("font_hover_color", Color(0.65, 0.68, 0.75))
		else:
			btn.add_theme_color_override("font_color", Color(0.1, 0.1, 0.2))
			btn.add_theme_color_override("font_hover_color", Color(0.1, 0.1, 0.2))

func _on_number_pressed(num: int) -> void:
	number_pressed.emit(num)

func _on_clear_pressed() -> void:
	clear_pressed.emit()
