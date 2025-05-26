#!/bin/bash

board=( " " " " " " " " " " " " " " " " " " )
current_player="X"

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

check_game_state() {
  for combo in "0 1 2" "3 4 5" "6 7 8" "0 3 6" "1 4 7" "2 5 8" "0 4 8" "2 4 6"; do
    set -- $combo
    if [[ "${board[$1]}" != " " && "${board[$1]}" == "${board[$2]}" && "${board[$2]}" == "${board[$3]}" ]]; then
      echo "Gracz $current_player wygrał!"
      return 0
    fi
  done

  for cell in "${board[@]}"; do
    [[ "$cell" == " " ]] && return 1
  done

  echo "Remis!"
  return 0
}

while true; do
  print_board
  read -r -p "Gracz $current_player, wybierz pole (wiersz i kolumna): " move

  if ! [[ "$move" =~ ^[1-3][1-3]$ ]]; then
    echo "Niepoprawny ruch. Podaj dwie cyfry (1-3) np. 23 dla 2. wiersza i 3. kolumny."
    continue
  fi

  row=$(( ${move:0:1} - 1 ))    
  col=$(( ${move:1:1} - 1 ))
  index=$(( row * 3 + col ))

  if [[ "${board[$index]}" != " " ]]; then
    echo "To pole jest już zajęte. Wybierz inne."
    continue
  fi

  board[$index]=$current_player

  if check_game_state; then
    print_board
    break
  fi

  current_player=$([[ "$current_player" == "X" ]] && echo "O" || echo "X")
done
