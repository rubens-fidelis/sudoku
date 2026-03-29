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
		var backup: int = board[pos]
		board[pos] = 0
		if _has_unique_solution(board):
			removed += 1
		else:
			board[pos] = backup

func _has_unique_solution(board: Array) -> bool:
	var copy := board.duplicate()
	var count := [0]
	_count_solutions(copy, count)
	return count[0] == 1

func _count_solutions(board: Array, count: Array) -> void:
	if count[0] >= 2:
		return
	for pos in range(81):
		if board[pos] == 0:
			for num in range(1, 10):
				if is_valid(board, pos, num):
					board[pos] = num
					_count_solutions(board, count)
					board[pos] = 0
					if count[0] >= 2:
						return
			return
	count[0] += 1

func is_complete(board: Array, solution: Array) -> bool:
	return board == solution
