extends GutTest

var sudoku

func before_each():
	sudoku = load("res://scripts/sudoku.gd").new()
	add_child(sudoku)

func test_is_valid_rejects_row_duplicate():
	var board: Array = []
	board.resize(81)
	board.fill(0)
	board[0] = 5  # row 0, col 0
	assert_false(sudoku.is_valid(board, 1, 5))  # row 0, col 1 — same row

func test_is_valid_rejects_col_duplicate():
	var board: Array = []
	board.resize(81)
	board.fill(0)
	board[0] = 5  # row 0, col 0
	assert_false(sudoku.is_valid(board, 9, 5))  # row 1, col 0 — same col

func test_is_valid_rejects_box_duplicate():
	var board: Array = []
	board.resize(81)
	board.fill(0)
	board[0] = 5  # row 0, col 0
	assert_false(sudoku.is_valid(board, 10, 5))  # row 1, col 1 — same 3x3 box

func test_is_valid_accepts_valid_placement():
	var board: Array = []
	board.resize(81)
	board.fill(0)
	board[0] = 5  # row 0, col 0
	assert_true(sudoku.is_valid(board, 12, 5))  # row 1, col 3 — different row/col/box

func test_generate_returns_81_cells():
	var result = sudoku.generate("easy")
	assert_eq(result["board"].size(), 81)
	assert_eq(result["solution"].size(), 81)
	assert_eq(result["clues"].size(), 81)

func test_generate_easy_has_45_clues():
	var result = sudoku.generate("easy")
	var clue_count = result["clues"].filter(func(c): return c).size()
	assert_eq(clue_count, 45)  # 81 - 36 removed

func test_generate_medium_has_35_clues():
	var result = sudoku.generate("medium")
	var clue_count = result["clues"].filter(func(c): return c).size()
	assert_eq(clue_count, 35)  # 81 - 46 removed

func test_generate_hard_has_27_clues():
	var result = sudoku.generate("hard")
	var clue_count = result["clues"].filter(func(c): return c).size()
	assert_eq(clue_count, 27)  # 81 - 54 removed

func test_is_complete_true_when_board_equals_solution():
	var result = sudoku.generate("easy")
	assert_true(sudoku.is_complete(result["solution"], result["solution"]))

func test_is_complete_false_when_board_has_empty_cells():
	var result = sudoku.generate("easy")
	assert_false(sudoku.is_complete(result["board"], result["solution"]))

func test_solution_is_fully_filled():
	var result = sudoku.generate("easy")
	for val in result["solution"]:
		assert_ne(val, 0)

func test_clues_match_board():
	var result = sudoku.generate("easy")
	for i in range(81):
		if result["clues"][i]:
			assert_ne(result["board"][i], 0)
		else:
			assert_eq(result["board"][i], 0)

func test_generate_easy_has_unique_solution():
	var result = sudoku.generate("easy")
	var count := [0]
	sudoku._count_solutions(result["board"].duplicate(), count)
	assert_eq(count[0], 1)

func test_generate_medium_has_unique_solution():
	var result = sudoku.generate("medium")
	var count := [0]
	sudoku._count_solutions(result["board"].duplicate(), count)
	assert_eq(count[0], 1)

func test_generate_hard_has_unique_solution():
	var result = sudoku.generate("hard")
	var count := [0]
	sudoku._count_solutions(result["board"].duplicate(), count)
	assert_eq(count[0], 1)
