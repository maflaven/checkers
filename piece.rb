require_relative 'invalid_move_error.rb'
require 'byebug'


class Piece
	attr_reader :team
	attr_accessor :king, :board, :pos

	TOP_SLIDE = [[1, 1], [1, -1]]

	TOP_JUMP = [[2, 2], [2, -2]]

	BOTTOM_SLIDE = [[-1, 1], [-1, -1]]

	BOTTOM_JUMP = [[-2, 2], [-2, -2]]

	KING_SLIDE = [[1, 1], [1, -1], [-1, 1], [-1, -1]]

	KING_JUMP = [[2, 2], [2, -2], [-2, 2], [-2, -2]]

	def initialize(team, board, pos, king = false)
		@team = team
		@board = board
		@king = king
		@pos = pos

		board.add_piece(self)
	end

	def king?
		self.king
	end

	def perform_slide(delta, board = self.board)
		pos_old = self.pos
		pos_row, pos_col = self.pos

		pos_new = [pos_row + delta[0], pos_col + delta[1]]

		update_pos(pos_old, pos_new, board)
	end

	def perform_jump(delta, board = self.board)
		pos_old = self.pos
		pos_row, pos_col = self.pos

		pos_new = [pos_row + delta[0], pos_col + delta[1]]
		pos_death = [pos_new[0] - (delta[0] / 2), pos_new[1] - (delta[1] / 2)]

		unless board[pos_death].nil?
			board[pos_death].pos = nil
			board[pos_death] = nil
		end

		update_pos(pos_old, pos_new, board)		
	end

	def render
		self.team
	end

	def moves
		test_board = board.clone
		test_piece = Piece.new(self.team, test_board, self.pos, self.king)
		
		slides = []
		jumps = []

		delta(:slide).each do |delta|
			slides << test_piece.possible_slide(delta, test_board)
		end

		delta(:jump).each do |delta|
			jumps << test_piece.possible_jump(delta, test_board)
		end

		(slides + jumps).compact
	end

	def perform_moves(destinations)
		raise InvalidMoveError.new 'invalid move' unless valid_move_seq?(destinations)

		perform_moves!(destinations, self.board)
	end

	def valid_move_seq?(destinations)
		test_board = board.clone
		test_piece = Piece.new(self.team, test_board, self.pos, self.king)

		begin
			test_piece.perform_moves!(destinations, test_board)
		rescue => e
			return false
		end

		true
	end

	def update_pos(pos_old, pos_new, board)
		self.pos = pos_new
		board[pos_old] = nil
		board[pos_new] = self
		self.promote if board.at_edge_row?(self.pos[0])
	end

	def possible_slide(delta, board)
		destination = [self.pos[0] + delta[0], self.pos[1] + delta[1]]
		
		if board.valid?(destination)
			if !board.occupied?(destination)
				return destination
			end
		end

		nil
	end

	def possible_jump(delta, board)
		destination = [self.pos[0] + delta[0], self.pos[1] + delta[1]]
		pos_kill = [self.pos[0] + (delta[0] / 2), self.pos[1] + (delta[1] / 2)]
	
		if board.valid?(destination) && !(board[pos_kill].nil?)
		 	if !board.occupied?(destination) && board[pos_kill].team != self.team
				return destination
			end
		end

		nil
	end

	def perform_moves!(destinations, board)
		if destinations.count == 1
			raise InvalidMoveError.new 'invalid move' unless self.moves.include?(destinations.first)

			delta = [destinations.first[0] - self.pos[0], destinations.first[1] - self.pos[1]]

			if delta[0].abs == 1
				perform_slide(delta, board)
			else
				perform_jump(delta, board)
			end
		elsif destinations.count > 1
			destinations.each do |destination|

				raise InvalidMoveError.new "invalid move #{destination}" unless self.moves.include?(destination)

				delta = [destination[0] - self.pos[0], destination[1] - self.pos[1]]

				perform_jump(delta, board)
			end
		end
	end

	def delta(move_type)
		if self.king?
			move_type == :slide ? KING_SLIDE : KING_JUMP
		else
			if self.team == :t
				move_type == :slide ? TOP_SLIDE : TOP_JUMP
			else
				move_type == :slide ? BOTTOM_SLIDE : BOTTOM_JUMP
			end
		end
	end

	def promote
		@king = true
	end
end