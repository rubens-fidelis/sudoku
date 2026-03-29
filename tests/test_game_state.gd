extends GutTest

var sudoku
var state

func before_each():
	sudoku = load("res://scripts/sudoku.gd").new()
	add_child(sudoku)
	state = load("res://scripts/game_state.gd").new()
	add_child(state)
	var puzzle = sudoku.generate("easy")
	state.setup(puzzle)

# --- setup() ---

func test_setup_resets_error_count():
	state.error_count = 5
	state.setup(sudoku.generate("easy"))
	assert_eq(state.error_count, 0)

func test_setup_resets_pencil_marks():
	state.setup(sudoku.generate("easy"))
	assert_eq(state.pencil_marks.size(), 81)
	for marks in state.pencil_marks:
		assert_eq(marks.size(), 0)

func test_setup_board_matches_clues():
	for i in range(81):
		if state.clues[i]:
			assert_ne(state.board[i], 0)
		else:
			assert_eq(state.board[i], 0)

# --- set_number() ---

func test_set_number_on_clue_does_nothing():
	var clue_pos := -1
	for i in range(81):
		if state.clues[i]:
			clue_pos = i
			break
	var original := state.board[clue_pos]
	state.set_number(clue_pos, 9 if original != 9 else 1)
	assert_eq(state.board[clue_pos], original)

func test_set_number_wrong_increments_error_count():
	var empty_pos := -1
	for i in range(81):
		if not state.clues[i]:
			empty_pos = i
			break
	var wrong_num := 1 if state.solution[empty_pos] != 1 else 2
	state.set_number(empty_pos, wrong_num)
	assert_eq(state.error_count, 1)

func test_set_number_correct_does_not_increment_error_count():
	var empty_pos := -1
	for i in range(81):
		if not state.clues[i]:
			empty_pos = i
			break
	state.set_number(empty_pos, state.solution[empty_pos])
	assert_eq(state.error_count, 0)

func test_set_number_emits_errors_changed_on_wrong():
	var empty_pos := -1
	for i in range(81):
		if not state.clues[i]:
			empty_pos = i
			break
	var wrong_num := 1 if state.solution[empty_pos] != 1 else 2
	watch_signals(state)
	state.set_number(empty_pos, wrong_num)
	assert_signal_emitted(state, "errors_changed")

func test_set_number_emits_board_changed():
	var empty_pos := -1
	for i in range(81):
		if not state.clues[i]:
			empty_pos = i
			break
	watch_signals(state)
	state.set_number(empty_pos, state.solution[empty_pos])
	assert_signal_emitted(state, "board_changed")

func test_set_number_clears_pencil_marks():
	var empty_pos := -1
	for i in range(81):
		if not state.clues[i]:
			empty_pos = i
			break
	state.pencil_marks[empty_pos] = [1, 2, 3]
	state.set_number(empty_pos, state.solution[empty_pos])
	assert_eq(state.pencil_marks[empty_pos].size(), 0)

func test_set_number_zero_does_not_increment_errors():
	var empty_pos := -1
	for i in range(81):
		if not state.clues[i]:
			empty_pos = i
			break
	state.set_number(empty_pos, state.solution[empty_pos])
	var errors_before := state.error_count
	state.set_number(empty_pos, 0)
	assert_eq(state.error_count, errors_before)

# --- toggle_pencil() ---

func test_toggle_pencil_adds_mark():
	var empty_pos := -1
	for i in range(81):
		if not state.clues[i]:
			empty_pos = i
			break
	state.toggle_pencil(empty_pos, 5)
	assert_true(5 in state.pencil_marks[empty_pos])

func test_toggle_pencil_removes_existing_mark():
	var empty_pos := -1
	for i in range(81):
		if not state.clues[i]:
			empty_pos = i
			break
	state.toggle_pencil(empty_pos, 5)
	state.toggle_pencil(empty_pos, 5)
	assert_false(5 in state.pencil_marks[empty_pos])

func test_toggle_pencil_on_clue_does_nothing():
	var clue_pos := -1
	for i in range(81):
		if state.clues[i]:
			clue_pos = i
			break
	state.toggle_pencil(clue_pos, 3)
	assert_eq(state.pencil_marks[clue_pos].size(), 0)

func test_toggle_pencil_on_filled_cell_does_nothing():
	var empty_pos := -1
	for i in range(81):
		if not state.clues[i]:
			empty_pos = i
			break
	state.set_number(empty_pos, state.solution[empty_pos])
	state.toggle_pencil(empty_pos, 3)
	assert_eq(state.pencil_marks[empty_pos].size(), 0)

# --- is_complete() / game_won signal ---

func test_is_complete_false_on_partial_board():
	assert_false(state.is_complete())

func test_is_complete_true_when_board_equals_solution():
	state.board = state.solution.duplicate()
	assert_true(state.is_complete())

func test_game_won_emitted_when_last_correct_number_placed():
	# Fill all non-clue cells with the correct answer directly except one
	for i in range(81):
		if not state.clues[i]:
			state.board[i] = state.solution[i]
	# Find the last empty-ish cell we can use set_number on
	var last_pos := -1
	for i in range(81):
		if not state.clues[i]:
			state.board[i] = 0
			last_pos = i
			break
	watch_signals(state)
	state.set_number(last_pos, state.solution[last_pos])
	assert_signal_emitted(state, "game_won")
