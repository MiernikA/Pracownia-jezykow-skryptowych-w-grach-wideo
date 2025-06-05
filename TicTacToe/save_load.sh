SAVE_FILE="save_game.txt"

save_game() {
  > "$SAVE_FILE"
  for i in "${!board[@]}"; do
    echo "$((i+1)): ${board[$i]}" >> "$SAVE_FILE"
  done
  echo "player: $current_player" >> "$SAVE_FILE"
  echo "Game has been saved."
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
    echo "Game has been loaded."
  else
    echo "No saved game found."
  fi
}
