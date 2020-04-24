require_relative 'tic_tac_toe_node'

class SuperComputerPlayer < ComputerPlayer
  def move(game, mark)
    node = TicTacToeNode.new(game.board,mark)
    node.children.each do |child|
      if child.winning_node?(mark)
        return child.prev_move_pos if node
      end
    end

    node.children.each do |child|
      if !child.losing_node?(mark)
        return child.prev_move_pos if node
      end
    end
    raise "Oh crap, im going to lose?!"
  end
end

if __FILE__ == $PROGRAM_NAME
  puts "Play the brilliant computer!"
  hp = HumanPlayer.new("Jeff")
  cp = SuperComputerPlayer.new

  TicTacToe.new(hp, cp).run
end
