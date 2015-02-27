require_relative 'piece.rb'
require 'colorize'

class Board
	def initialize(fill_board = true)

		create_starting_grid(fill_board)
	end

	def [](pos)
		row, col = pos

		@grid[row][col]
	end

	def []=(pos, piece)
		row, col = pos

		@grid[row][col] = piece
	end

	def add_piece(piece)
		self[piece.pos] = piece
	end

	def occupied?(pos)
		!self[pos].nil?
	end

	def valid?(pos)
		row, col = pos

		(row >= 0 && row <= 7) && (col >= 0 && col <= 7)
	end

	def render
		render_string = ""

		render_string += "  a  b  c  d  e  f  g  h\n".colorize(:red)

		@grid.each_with_index { |row, i| render_string += render_row(row, i) }

		render_string += "  a  b  c  d  e  f  g  h\n".colorize(:red)

		render_string
	end

	def clone
		cloned_board = Board.new(false)

		pieces.each { |piece| Piece.new(piece.team, cloned_board, piece.pos.dup) }

		cloned_board
	end

	private

	def render_row(row, i)
		render_string = ""

		render_string += "#{i}".colorize(:red)
		
		row.each do |tile|
			if tile.nil?
				render_string += " _ "
			else
				render_string += " #{tile.render} "
			end
		end

		render_string += "#{i}".colorize(:red)
		render_string += "\n"

		render_string
	end

	def create_starting_grid(fill_board)
		@grid = Array.new(8) { Array.new(8) }

		if fill_board
			[0, 2].each { |row| populate_row(row, :t, :even) }
			populate_row(1, :t, :odd)

			[5, 7].each { |row| populate_row(row, :b, :odd) }
			populate_row(6, :b, :even)
		end
	end

	def populate_row(row, team, place_at) 
		
		if place_at == :even
			@grid[row].each_with_index do |tile, col|
				next if col.odd?
				Piece.new(team, self, [row, col])
			end

		elsif place_at == :odd
			@grid[row].each_with_index do |tile, col|
				next if col.even?
				Piece.new(team, self, [row, col])
			end
		end
	end

	def pieces
		@grid.flatten.compact
	end
end

if __FILE__ == $PROGRAM_NAME
	b = Board.new
	b[[0,4]] = nil
	b[[5,1]].perform_slide([-1,-1])
	b[[2,2]].perform_slide([1, -1])
	# b[[4,0]].perform_jump([-2,2])
	puts b[[4,0]].perform_moves([[2,2], [0,4]])
	puts b.render
end