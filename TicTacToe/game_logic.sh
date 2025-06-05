check_game_state() {
  for combo in "0 1 2" "3 4 5" "6 7 8" "0 3 6" "1 4 7" "2 5 8" "0 4 8" "2 4 6"; do
    set -- $combo
    if [[ "${board[$1]}" != " " && "${board[$1]}" == "${board[$2]}" && "${board[$2]}" == "${board[$3]}" ]]; then
      echo "Player $current_player has won!"
      return 0
    fi
  done

  for cell in "${board[@]}"; do
    [[ "$cell" == " " ]] && return 1
  done

  echo "It's a draw!"
  return 0
}

computer_move() {
  empty_cells=()
  for i in "${!board[@]}"; do
    [[ "${board[$i]}" == " " ]] && empty_cells+=($i)
  done
  if [[ ${#empty_cells[@]} -gt 0 ]]; then
    index=${empty_cells[$((RANDOM % ${#empty_cells[@]}))]}
    board[$index]="O"
    row=$(( index / 3 + 1 ))
    col=$(( index % 3 + 1 ))
    echo "Computer moved to: ${row} - ${col}"
  fi
}
