extends Node

var board: Array = []
var solution: Array = []
var clues: Array = []
var pencil_marks: Array = []
var difficulty: String = "easy"
var error_count: int = 0
var locale: String = "en"

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.96, 0.96, 0.97))
	_load_settings()

const VALID_LOCALES := ["en", "pt_BR", "es", "fr", "de"]

func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") == OK:
		var saved := cfg.get_value("settings", "locale", "en") as String
		locale = saved if saved in VALID_LOCALES else "en"
	TranslationServer.set_locale(locale)

func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("settings", "locale", locale)
	cfg.save("user://settings.cfg")

signal board_changed(pos: int)
signal game_won
signal errors_changed

func setup(puzzle: Dictionary) -> void:
	board = puzzle["board"].duplicate()
	solution = puzzle["solution"].duplicate()
	clues = puzzle["clues"].duplicate()
	pencil_marks = []
	error_count = 0
	for i in range(81):
		pencil_marks.append([])

func set_number(pos: int, num: int) -> void:
	if clues[pos]:
		return
	if num != 0 and num != solution[pos] and board[pos] != num:
		error_count += 1
		errors_changed.emit()
	board[pos] = num
	if num != 0:
		pencil_marks[pos].clear()
	board_changed.emit(pos)
	if is_complete():
		game_won.emit()

func toggle_pencil(pos: int, num: int) -> void:
	if clues[pos] or board[pos] != 0:
		return
	if num in pencil_marks[pos]:
		pencil_marks[pos].erase(num)
	else:
		pencil_marks[pos].append(num)
	board_changed.emit(pos)

func is_complete() -> bool:
	return board == solution
