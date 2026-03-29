extends Node

func is_valid(board: Array, pos: int, num: int) -> bool:
	var row: int = pos / 9
	var col: int = pos % 9

	for c in range(9):
		if board[row * 9 + c] == num:
			return false

	for r in range(9):
		if board[r * 9 + col] == num:
			return false

	var box_row: int = (row / 3) * 3
	var box_col: int = (col / 3) * 3
	for r in range(3):
		for c in range(3):
			if board[(box_row + r) * 9 + (box_col + c)] == num:
				return false

	return true

func _solve(board: Array) -> bool:
	for pos in range(81):
		if board[pos] == 0:
			var nums: Array = [1, 2, 3, 4, 5, 6, 7, 8, 9]
			nums.shuffle()
			for num in nums:
				if is_valid(board, pos, num):
					board[pos] = num
					if _solve(board):
						return true
					board[pos] = 0
			return false
	return true

func generate(difficulty: String) -> Dictionary:
	var board: Array = []
	board.resize(81)
	board.fill(0)
	_solve(board)

	var solution: Array = board.duplicate()
	var removals: Dictionary = {"easy": 36, "medium": 46, "hard": 54}
	_remove_cells(board, removals[difficulty])

	var clues: Array = []
	for i in range(81):
		clues.append(board[i] != 0)

	return {"board": board, "solution": solution, "clues": clues}

func _remove_cells(board: Array, count: int) -> void:
	var positions: Array = Array(range(81))  # range() returns Range in Godot 4 — must wrap in Array() before calling shuffle()
	positions.shuffle()
	var removed: int = 0
	for pos in positions:
		if removed >= count:
			break
		board[pos] = 0
		removed += 1

func is_complete(board: Array, solution: Array) -> bool:
	return board == solution
