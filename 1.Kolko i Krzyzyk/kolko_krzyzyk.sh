#!/bin/bash

SAVE_FILE="save_game.txt"
board=( " " " " " " " " " " " " " " " " " " )
current_player="X"
vs_computer=false

save_game() {
  > "$SAVE_FILE"
  for i in "${!board[@]}"; do
    echo "$((i+1)): ${board[$i]}" >> "$SAVE_FILE"
  done
  echo "player: $current_player" >> "$SAVE_FILE"
  echo "Gra została zapisana."
}

load_game() {
  if [[ -f "$SAVE_FILE" ]]; then
    while IFS= read -r line; do
      if [[ "$line" =~ ^([1-9]):[[:space:]]*(.)$ ]]; then
        index=$(( ${BASH_REMATCH[1]} - 1 ))
        value="${BASH_REMATCH[2]}"
        board[$index]="$value"
      elif [[ "$line" =~ ^player:[[:space:]]*(.)$ ]]; then
        current_player="${BASH_REMATCH[1]}"
      fi
    done < "$SAVE_FILE"
    echo "Gra została wczytana."
  else
    echo "Brak zapisanej gry."
  fi
}

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
    echo "Komputer wykonał ruch: ${row} - ${col}"
  fi
}

echo "Wybierz tryb gry:"
echo "1 - Gracz vs Gracz"
echo "2 - Gracz vs Komputer"
read -r mode
[[ "$mode" == "2" ]] && vs_computer=true

read -r -p "Czy chcesz wczytać zapisaną grę? (t/n): " choice
[[ "$choice" == "t" || "$choice" == "T" ]] && load_game

while true; do
  print_board

  if [[ "$vs_computer" == true && "$current_player" == "O" ]]; then
    sleep 1
    computer_move
  else
    echo "Wpisz ruch (wiersz|kolumna), z - zapisz grę, q - zakończ: "
    read -r -p "Gracz $current_player: " move

    if [[ "$move" == "z" ]]; then
      save_game
      continue
    elif [[ "$move" == "q" ]]; then
      echo "Zakończono grę."
      break
    elif ! [[ "$move" =~ ^[1-3][1-3]$ ]]; then
      echo "Niepoprawny ruch. Podaj dwie cyfry (1-3), np. 23."
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
  fi

  if check_game_state; then
    print_board
    rm -f "$SAVE_FILE"
    break
  fi

  current_player=$([[ "$current_player" == "X" ]] && echo "O" || echo "X")
done
