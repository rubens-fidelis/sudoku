extends VBoxContainer

const LOCALES := ["en", "pt_BR", "es", "fr", "de"]
const LOCALE_NAMES := ["English", "Português", "Español", "Français", "Deutsch"]
const PADDING: float = 20.0

func _ready() -> void:
	alignment = BoxContainer.ALIGNMENT_BEGIN
	add_theme_constant_override("separation", 24)
	offset_left   =  PADDING
	offset_right  = -PADDING
	offset_top    =  PADDING
	offset_bottom = -PADDING

	_style_title()
	_style_buttons()
	_setup_locale_selector()

	# Two expanding spacers keep the title+buttons group vertically centered
	# while the locale selector sits at the bottom inside the padding.
	var top_spacer := Control.new()
	top_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(top_spacer)
	move_child(top_spacer, $Title.get_index())

	var bottom_spacer := Control.new()
	bottom_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(bottom_spacer)
	move_child(bottom_spacer, $LocaleSelector.get_index())

	$Buttons/EasyBtn.pressed.connect(_on_difficulty.bind("easy"))
	$Buttons/MediumBtn.pressed.connect(_on_difficulty.bind("medium"))
	$Buttons/HardBtn.pressed.connect(_on_difficulty.bind("hard"))

func _style_title() -> void:
	var bold_font := FontVariation.new()
	bold_font.base_font = load("res://assets/fonts/Outfit.ttf")
	bold_font.variation_opentype = {"wght": 900}
	bold_font.variation_embolden = 1.0
	$Title.add_theme_font_override("font", bold_font)
	$Title.add_theme_color_override("font_color", Color(0.08, 0.08, 0.15))
	$Subtitle.add_theme_color_override("font_color", Color(0.45, 0.45, 0.55))
	$Buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	$Buttons.add_theme_constant_override("separation", 16)

func _style_buttons() -> void:
	for btn_name in ["EasyBtn", "MediumBtn", "HardBtn"]:
		var btn: Button = $Buttons.get_node(btn_name)
		btn.custom_minimum_size = Vector2(200, 58)

		var normal := StyleBoxFlat.new()
		normal.bg_color = Color(0.18, 0.38, 0.82)
		normal.set_corner_radius_all(10)
		normal.content_margin_left = 32
		normal.content_margin_right = 32
		normal.content_margin_top = 14
		normal.content_margin_bottom = 14

		var hover := normal.duplicate() as StyleBoxFlat
		hover.bg_color = Color(0.25, 0.47, 0.92)

		var pressed_style := normal.duplicate() as StyleBoxFlat
		pressed_style.bg_color = Color(0.12, 0.28, 0.65)

		btn.add_theme_stylebox_override("normal", normal)
		btn.add_theme_stylebox_override("hover", hover)
		btn.add_theme_stylebox_override("pressed", pressed_style)
		btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		btn.add_theme_font_size_override("font_size", 22)
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_color_override("font_hover_color", Color.WHITE)
		btn.add_theme_color_override("font_pressed_color", Color.WHITE)

func _setup_locale_selector() -> void:
	var selector: OptionButton = $LocaleSelector
	selector.clear()
	for i in range(LOCALES.size()):
		selector.add_item(LOCALE_NAMES[i], i)
	selector.selected = max(LOCALES.find(GameState.locale), 0)
	selector.item_selected.connect(_on_locale_selected)

	selector.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	selector.custom_minimum_size = Vector2(200, 58)

	# All button states use the same soft style — no jarring hover/press changes
	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0.93, 0.93, 0.95)
	btn_style.set_corner_radius_all(6)
	btn_style.content_margin_left = 14
	btn_style.content_margin_right = 14
	btn_style.content_margin_top = 7
	btn_style.content_margin_bottom = 7

	for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		selector.add_theme_stylebox_override(state, btn_style.duplicate())
	selector.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	selector.add_theme_constant_override("arrow_margin", 14)
	selector.add_theme_color_override("font_color", Color(0.2, 0.2, 0.3))
	selector.add_theme_color_override("font_hover_color", Color(0.2, 0.2, 0.3))
	selector.add_theme_color_override("font_pressed_color", Color(0.2, 0.2, 0.3))
	selector.add_theme_color_override("font_hover_pressed_color", Color(0.2, 0.2, 0.3))
	selector.add_theme_font_size_override("font_size", 15)

	# Style the dropdown popup to match the game's light aesthetic
	var popup := selector.get_popup()

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.96, 0.96, 0.97)
	panel_style.set_corner_radius_all(8)
	panel_style.border_color = Color(0.82, 0.82, 0.87)
	panel_style.set_border_width_all(1)
	panel_style.content_margin_left = 4
	panel_style.content_margin_right = 4
	panel_style.content_margin_top = 4
	panel_style.content_margin_bottom = 4
	popup.add_theme_stylebox_override("panel", panel_style)

	var item_hover := StyleBoxFlat.new()
	item_hover.bg_color = Color(0.88, 0.92, 0.98)
	item_hover.set_corner_radius_all(4)
	item_hover.content_margin_left = 8
	item_hover.content_margin_right = 8
	item_hover.content_margin_top = 2
	item_hover.content_margin_bottom = 2
	popup.add_theme_stylebox_override("hover", item_hover)

	popup.add_theme_color_override("font_color", Color(0.2, 0.2, 0.3))
	popup.add_theme_color_override("font_hover_color", Color(0.2, 0.2, 0.3))
	popup.add_theme_font_size_override("font_size", 15)
	popup.add_theme_constant_override("v_separation", 12)

	# Blue dot for the selected item; same-size transparent for others (keeps text aligned)
	var dot_icon := ImageTexture.new()
	var dot_img := Image.create(14, 14, false, Image.FORMAT_RGBA8)
	dot_img.fill(Color(0, 0, 0, 0))
	var dot_center := Vector2(7, 7)
	for x in range(14):
		for y in range(14):
			if Vector2(x + 0.5, y + 0.5).distance_to(dot_center) <= 4.0:
				dot_img.set_pixel(x, y, Color(0.18, 0.38, 0.82))
	dot_icon.set_image(dot_img)

	var empty_icon := ImageTexture.new()
	var empty_img := Image.create(14, 14, false, Image.FORMAT_RGBA8)
	empty_img.fill(Color(0, 0, 0, 0))
	empty_icon.set_image(empty_img)

	popup.add_theme_icon_override("radio_checked", dot_icon)
	popup.add_theme_icon_override("checked", dot_icon)
	popup.add_theme_icon_override("radio_unchecked", empty_icon)
	popup.add_theme_icon_override("unchecked", empty_icon)

	# Reposition popup above the button (Godot places it below by default)
	popup.visibility_changed.connect(func():
		if not popup.visible:
			return
		var popup_size: Vector2i = popup.size
		var btn_rect := selector.get_global_rect()
		popup.position = Vector2i(
			int(btn_rect.position.x),
			int(btn_rect.position.y) - popup_size.y
		)
	)

func _on_locale_selected(idx: int) -> void:
	GameState.locale = LOCALES[idx]
	TranslationServer.set_locale(LOCALES[idx])
	GameState.save_settings()

func _on_difficulty(difficulty: String) -> void:
	GameState.difficulty = difficulty
	get_tree().change_scene_to_file("res://scenes/game.tscn")
