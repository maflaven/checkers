require_relative 'board.rb'

class Game

	def initialize
		@board = Board.new
	end

	def play

		until !!(winner)
			display
			begin
				get_move_sequence
			rescue InvalidMoveError => e
				puts e
				retry
			ensure
				display
			end
		end
			
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

	def get_coordinates
		input = gets.chomp.split(',')

		input.map! { |num| num.strip } unless input.nil?

		raise 'invalid coordinates' if @board.valid?(input)

		input 
	end

	def get_move_sequence
		move_sequence = []

		begin
			move = [nil]
			until move.empty?
				move = get_coordinates
				move_sequence << move
			end
		rescue => e
			puts e
			retry
		end

		move_sequence
	end
end