#!/bin/bash

source ./board.sh
source ./save_load.sh
source ./game_logic.sh

vs_computer=false
current_player="X"
board=( " " " " " " " " " " " " " " " " " " )

echo "Choose game mode:"
echo "1 - Player vs Player"
echo "2 - Player vs Computer"
read -r mode
[[ "$mode" == "2" ]] && vs_computer=true

read -r -p "Do you want to load a saved game? (y/n): " choice
[[ "$choice" == "y" || "$choice" == "Y" ]] && load_game

while true; do
  print_board

  if [[ "$vs_computer" == true && "$current_player" == "O" ]]; then
    sleep 1
    computer_move
  else
    echo "Enter your move (row|column), z - save game, q - quit: "
    read -r -p "Player $current_player: " move

    if [[ "$move" == "z" ]]; then
      save_game
      continue
    elif [[ "$move" == "q" ]]; then
      echo "Game ended."
      break
    elif ! [[ "$move" =~ ^[1-3][1-3]$ ]]; then
      echo "Invalid move. Enter two digits (1-3), e.g., 23."
      continue
    fi

    row=$(( ${move:0:1} - 1 ))
    col=$(( ${move:1:1} - 1 ))
    index=$(( row * 3 + col ))

    if [[ "${board[$index]}" != " " ]]; then
      echo "This cell is already taken. Choose another one."
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
