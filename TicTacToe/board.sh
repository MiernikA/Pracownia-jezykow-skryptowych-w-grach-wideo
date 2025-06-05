print_board() {
  echo
  echo "     1   2   3"
  echo "   -------------"
  echo " 1 | ${board[0]} | ${board[1]} | ${board[2]} |"
  echo "   |---+---+---|"
  echo " 2 | ${board[3]} | ${board[4]} | ${board[5]} |"
  echo "   |---+---+---|"
  echo " 3 | ${board[6]} | ${board[7]} | ${board[8]} |"
  echo "   -------------"
  echo
}
