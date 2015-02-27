require_relative 'board.rb'

class Game

	def initialize
		@board = Board.new
	end

	def play

		until !!(winner)
			


	end

	def winner
		t = @board.pieces.none? { |piece| piece.team == :b }
		b = @board.pieces.none? { |piece| piece.team == :t }

		if t
			:t
		elsif b
			:b
		end
	end
end