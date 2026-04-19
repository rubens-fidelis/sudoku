extends Node

static var _peers: Array = _build_peers()

static func _build_peers() -> Array:
	var result: Array = []
	result.resize(81)
	for pos in range(81):
		var row := pos / 9
		var col := pos % 9
		var box_row := (row / 3) * 3
		var box_col := (col / 3) * 3
		var peers := PackedInt32Array()
		for c in range(9):
			if c != col:
				peers.append(row * 9 + c)
		for r in range(9):
			if r != row:
				peers.append(r * 9 + col)
		for r in range(3):
			for c in range(3):
				var p := (box_row + r) * 9 + (box_col + c)
				if p != pos and not peers.has(p):
					peers.append(p)
		result[pos] = peers
	return result

func _get_candidates(board: Array, pos: int) -> Array:
	var used := [false, false, false, false, false, false, false, false, false, false]
	for peer in _peers[pos]:
		var val: int = board[peer]
		if val != 0:
			used[val] = true
	var candidates: Array = []
	for num in range(1, 10):
		if not used[num]:
			candidates.append(num)
	return candidates

func is_valid(board: Array, pos: int, num: int) -> bool:
	for peer in _peers[pos]:
		if board[peer] == num:
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
	positions.sort_custom(func(a: int, b: int) -> bool:
		return _get_candidates(board, a).size() > _get_candidates(board, b).size()
	)
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
	var best_pos := -1
	var best_candidates: Array = []
	var best_size := 10
	for pos in range(81):
		if board[pos] == 0:
			var candidates := _get_candidates(board, pos)
			if candidates.is_empty():
				return
			if candidates.size() < best_size:
				best_size = candidates.size()
				best_pos = pos
				best_candidates = candidates
				if best_size == 1:
					break
	if best_pos == -1:
		count[0] += 1
		return
	for num in best_candidates:
		board[best_pos] = num
		if not _has_dead_peers(board, best_pos):
			_count_solutions(board, count)
		board[best_pos] = 0
		if count[0] >= 2:
			return

func _has_dead_peers(board: Array, pos: int) -> bool:
	for peer in _peers[pos]:
		if board[peer] == 0 and _get_candidates(board, peer).is_empty():
			return true
	return false

func is_complete(board: Array, solution: Array) -> bool:
	return board == solution
