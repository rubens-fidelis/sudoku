extends Node

var board: Array = []
var solution: Array = []
var clues: Array = []
var pencil_marks: Array = []
var difficulty: String = "easy"
var error_count: int = 0
var locale: String = "en"
var is_continuing: bool = false
var _save_pending: bool = false

const SAVE_PATH := "user://save_game.cfg"

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.96, 0.96, 0.97))
	_load_settings()

func _process(_delta: float) -> void:
	if _save_pending:
		_save_pending = false
		_write_save()

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
	is_continuing = false
	for i in range(81):
		pencil_marks.append(0)
	_request_save()

func set_number(pos: int, num: int) -> void:
	if clues[pos]:
		return
	if num != 0 and num != solution[pos] and board[pos] != num:
		error_count += 1
		errors_changed.emit()
	board[pos] = num
	if num != 0:
		pencil_marks[pos] = 0
	board_changed.emit(pos)
	if is_complete():
		clear_saved_game()
		game_won.emit()
	else:
		_request_save()

func toggle_pencil(pos: int, num: int) -> void:
	if clues[pos] or board[pos] != 0:
		return
	pencil_marks[pos] ^= (1 << (num - 1))
	board_changed.emit(pos)
	_request_save()

func is_complete() -> bool:
	return board == solution

func save_game() -> void:
	_request_save()

func _request_save() -> void:
	_save_pending = true

func _write_save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("game", "board", board)
	cfg.set_value("game", "solution", solution)
	cfg.set_value("game", "clues", clues)
	cfg.set_value("game", "pencil_marks", pencil_marks)
	cfg.set_value("game", "difficulty", difficulty)
	cfg.set_value("game", "error_count", error_count)
	cfg.save(SAVE_PATH)

func has_saved_game() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func load_game() -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return false
	board = cfg.get_value("game", "board")
	solution = cfg.get_value("game", "solution")
	clues = cfg.get_value("game", "clues")
	pencil_marks = cfg.get_value("game", "pencil_marks")
	difficulty = cfg.get_value("game", "difficulty")
	error_count = cfg.get_value("game", "error_count")
	is_continuing = true
	return true

func clear_saved_game() -> void:
	_save_pending = false
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
