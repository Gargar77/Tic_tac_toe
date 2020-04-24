

class Board
  attr_reader :rows

  def self.blank_grid
    Array.new(3) { Array.new(3) }
    # this class variable will create a new 3x3 grid wihtout an instance
  end

  def initialize(rows = self.class.blank_grid)
    #self.class will be able to access its own class method.
    #in this case, its accessing Board::blank_grid
    @rows = rows
  end

  def [](pos)
    row, col = pos[0], pos[1]
    @rows[row][col]
  end

  def []=(pos, mark)
    raise "mark already placed there!" unless empty?(pos)

    row, col = pos[0], pos[1]
    @rows[row][col] = mark
  end

  def cols
    #this method does what Array#transpose does.
    #it creates an array of columns
    cols = [[], [], []]
    @rows.each do |row|
      row.each_with_index do |mark, col_idx|
        cols[col_idx] << mark
      end
    end
    cols
  end

  def diagonals
    down_diag = [[0, 0], [1, 1], [2, 2]] #down diag positions
    up_diag = [[0, 2], [1, 1], [2, 0]]   #up diag positions

    [down_diag, up_diag].map do |diag|
      # Note the `row, col` inside the block; this unpacks, or
      # "destructures" the argument. Read more here:
      # https://thoughtbot.com/blog/stupid-ruby-tricks

      diag.map { |row, col| @rows[row][col] }
    end
  end

  def dup
    duped_rows = rows.map(&:dup)
    #outputs a duplicate of the  current rows
    self.class.new(duped_rows)
    #this is then put in a new class
    #we use self.class so that it uses the same class this method is in
  end

  def empty?(pos)
    self[pos].nil?
  end

  def tied?
    return false if won?

    # no empty space?
    @rows.all? { |row| row.none? { |el| el.nil? }}
  end

  def over?
    # don't use Ruby's `or` operator; always prefer `||`
    won? || tied?
  end

  def winner
    (rows + cols + diagonals).each do |triple|
      return :x if triple == [:x, :x, :x]
      return :o if triple == [:o, :o, :o]
    end

    nil
  end

  def won?
    !winner.nil?
  end
end

# Notice how the Board has the basic rules of the game, but no logic
# for actually prompting the user for moves. This is a rigorous
# decomposition of the "game state" into its own pure object
# unconcerned with how moves are processed.

class TicTacToe

  class IllegalMoveError < RuntimeError
    #this allows IllegalMoveError class to inheret RuntimeError class
    # RuntimeError class : https://ruby-doc.org/core-2.5.0/RuntimeError.html
    # so whenever you get an error that usually causes RuntimeError to be called,
    #you will instead see IllegalMoveError
    #notice how this will only happen in a TicTacToe instance
  end

  attr_reader :board, :players, :turn

  def initialize(player1, player2)
    @board = Board.new
    @players = { :x => player1, :o => player2 }
    @turn = :x
  end

  def run
    until self.board.over?
      play_turn
    end

    if self.board.won?
      winning_player = self.players[self.board.winner]
      puts "#{winning_player.name} won the game!"
    else
      puts "No one wins!"
    end
  end

  def show
    # not very pretty printing!
    self.board.rows.each { |row| p row }
  end

  private
  def place_mark(pos, mark)
    if self.board.empty?(pos)
      self.board[pos] = mark
      true
    else
      false
    end
  end

  def play_turn
    loop do
      #useful if you want to loop without a beggining boolean
      #in this case it will only stop with a break keyword
      current_player = self.players[self.turn]
      pos = current_player.move(self, self.turn)

      break if place_mark(pos, self.turn)
      #this will break if the return value of #place_mark == true
      #this means that the player successfully placed a mark.
    end

    # swap next whose turn it will be next
    @turn = ((self.turn == :x) ? :o : :x)
  end
end

class HumanPlayer
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def move(game, mark)
    game.show
    while true
      puts "#{@name}: please select your space"
      row, col = gets.chomp.split(",").map(&:to_i)
      if HumanPlayer.valid_coord?(row, col)
        return [row, col]
      else
        puts "Invalid coordinate!"
      end
    end
  end

  private
  def self.valid_coord?(row, col)
    [row, col].all? { |coord| (0..2).include?(coord) }
  end
end

class ComputerPlayer
  attr_reader :name

  def initialize
    @name = "Tandy 400"
  end

  def move(game, mark)
    #checks for a winning move, 
    #if winner_move returns nil, then it does random_move
    winner_move(game, mark) || random_move(game)
  end

  private
  def winner_move(game, mark)
    (0..2).each do |row|
      (0..2).each do |col|
        #duplicates current board state
        board = game.board.dup
        #will iterate through each position in the board
        pos = [row, col]

        next unless board.empty?(pos)
        #if the position happens to be empty, 
        #it will mark it
        board[pos] = mark
        #return that position only if that position lets the computer win the game
        return pos if board.winner == mark
        #the each loop will iterte to another position if pos is not returned
        #each iteration will make a completely new duplpicate of the board and will repeat the previous logic.
      end
    end

    # if at the end of iterating through the whole board, pos is not returned, then there is no winning move
    #therefore nil is returned
    nil
  end

  def random_move(game)
    board = game.board
    while true
      range = (0..2).to_a
      pos = [range.sample, range.sample]

      return pos if board.empty?(pos)
    end
  end
end

if __FILE__ == $PROGRAM_NAME  # if we are running as script
  puts "Play the dumb computer!"
  hp = HumanPlayer.new("Ned")
  cp = ComputerPlayer.new

  TicTacToe.new(hp, cp).run
end
