#!/bin/bash

source ./board.sh
source ./save_load.sh
source ./game_logic.sh

vs_computer=false
current_player="X"
board=( " " " " " " " " " " " " " " " " " " )

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
