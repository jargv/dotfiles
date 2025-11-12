# Simple directory jumper - zero dependencies
# Maintains ~/.zshmarks file with frecency scoring

j() {
  local marks_file="$HOME/.zshmarks"
  [[ ! -f "$marks_file" ]] && touch "$marks_file"

  if [[ $# -eq 0 ]]; then
    # List all marks sorted by frequency
    grep '|' "$marks_file" 2>/dev/null | sort -rn | cut -d'|' -f2 | head -20
    return
  fi

  local query="$1"
  local match=$(grep -i "$query" "$marks_file" | sort -rn | head -1 | cut -d'|' -f2)

  if [[ -n "$match" && -d "$match" ]]; then
    cd "$match" || return 1
    # Increment score
    local score=$(grep -F "$match" "$marks_file" | head -1 | cut -d'|' -f1)
    # Validate score is numeric
    [[ ! "$score" =~ ^[0-9]+$ ]] && score=0
    score=$((score + 1))
    grep -v -F "$match" "$marks_file" > "$marks_file.tmp.$$" 2>/dev/null || true
    echo "$score|$match" >> "$marks_file.tmp.$$"
    mv "$marks_file.tmp.$$" "$marks_file"
  else
    # Fallback to regular cd behavior
    cd "$query"
  fi
}

# Track directory changes
chpwd_track_dirs() {
  local marks_file="$HOME/.zshmarks"
  local pwd_escaped="$PWD"

  # Don't track home, tmp, or very deep paths
  [[ "$PWD" == "$HOME" ]] && return
  [[ "$PWD" =~ ^/tmp ]] && return
  [[ $(echo "$PWD" | tr '/' '\n' | wc -l) -gt 8 ]] && return

  # Ensure marks file exists
  [[ ! -f "$marks_file" ]] && touch "$marks_file"

  local score=$(grep -F "$pwd_escaped" "$marks_file" 2>/dev/null | head -1 | cut -d'|' -f1)
  # Validate score is numeric
  [[ ! "$score" =~ ^[0-9]+$ ]] && score=0
  score=$((score + 1))

  grep -v -F "$pwd_escaped" "$marks_file" 2>/dev/null > "$marks_file.tmp.$$" || touch "$marks_file.tmp.$$"
  echo "$score|$pwd_escaped" >> "$marks_file.tmp.$$"
  mv "$marks_file.tmp.$$" "$marks_file"
}

# Hook into zsh directory changes
if [[ -n "$ZSH_VERSION" ]]; then
  chpwd_functions+=(chpwd_track_dirs)
fi
