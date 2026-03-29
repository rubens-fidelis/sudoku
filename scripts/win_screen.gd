extends VBoxContainer

const PADDING: float = 20.0

func _ready() -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 20)
	offset_left   =  PADDING
	offset_right  = -PADDING
	offset_top    =  PADDING
	offset_bottom = -PADDING

	var bold_font := FontVariation.new()
	bold_font.base_font = load("res://assets/fonts/Outfit.ttf")
	bold_font.variation_opentype = {"wght": 900}
	bold_font.variation_embolden = 1.0
	$Title.add_theme_font_override("font", bold_font)
	$Title.add_theme_color_override("font_color", Color(0.08, 0.08, 0.15))
	$Subtitle.add_theme_color_override("font_color", Color(0.45, 0.45, 0.55))

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.18, 0.38, 0.82)
	normal.set_corner_radius_all(10)
	normal.content_margin_left = 40
	normal.content_margin_right = 40
	normal.content_margin_top = 16
	normal.content_margin_bottom = 16

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.25, 0.47, 0.92)

	var pressed_style := normal.duplicate() as StyleBoxFlat
	pressed_style.bg_color = Color(0.12, 0.28, 0.65)

	$PlayAgainBtn.add_theme_stylebox_override("normal", normal)
	$PlayAgainBtn.add_theme_stylebox_override("hover", hover)
	$PlayAgainBtn.add_theme_stylebox_override("pressed", pressed_style)
	$PlayAgainBtn.add_theme_stylebox_override("hover_pressed", pressed_style.duplicate())
	$PlayAgainBtn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	$PlayAgainBtn.add_theme_font_size_override("font_size", 22)
	$PlayAgainBtn.add_theme_color_override("font_color", Color.WHITE)
	$PlayAgainBtn.add_theme_color_override("font_hover_color", Color.WHITE)
	$PlayAgainBtn.add_theme_color_override("font_pressed_color", Color.WHITE)
	$PlayAgainBtn.add_theme_color_override("font_hover_pressed_color", Color.WHITE)
	$PlayAgainBtn.custom_minimum_size = Vector2(200, 58)

	$PlayAgainBtn.pressed.connect(_on_play_again)

func _on_play_again() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
