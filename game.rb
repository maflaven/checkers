require_relative 'board.rb'

class Game
	attr_accessor :board

	def initialize
		@board = Board.new
	end

	def play

		until !!(winner)
			puts "\ec"
			display
			begin
				current_piece = board[get_starting_piece]
				move_destinations = get_move_sequence
				current_piece.perform_moves(move_destinations)
			rescue => e
				puts "invalid coordinates. try again"
				retry
			end
		end
		
		display

		puts "#{winner} wins!"
	end

	def winner
		t = @board.pieces.none? { |piece| piece.team == :b }
		b = @board.pieces.none? { |piece| piece.team == :t }

		if t
			"Top"
		elsif b
			"Bottom"
		end
	end

	def display
		puts @board.render
	end

	def get_coordinates(starting)
		puts "enter destination coordinates (e.g. 3,1), or leave blank" unless starting

		input = gets.chomp.split(',')

		return [] if input.empty?

		input.map! { |num| num.to_i }

		raise 'invalid coordinates' if !board.valid?(input)

		input
	end

	def get_move_sequence
		move_sequence = []

		move = [[]]
		until move.first.nil?
			move = get_coordinates(false)
			move_sequence << move
		end

		move_sequence.delete_if { |el| el.first.nil? }

		move_sequence
	end

	def get_starting_piece
		puts "enter starting coordinates (e.g. 2,0)"
		get_coordinates(true)
	end

end

if __FILE__ == $PROGRAM_NAME
	game = Game.new
	game.play
end