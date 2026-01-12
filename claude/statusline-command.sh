#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Define ANSI color codes
CYAN='\033[36m'        # Model name - cyan for clarity
GREEN='\033[32m'       # Progress bar - green (0-25%)
YELLOW='\033[33m'      # Percentage - yellow for attention / Progress bar (26-50%)
ORANGE='\033[38;5;208m' # Progress bar - orange (51-75%)
RED='\033[31m'         # Progress bar - red (76-100%)
MAGENTA='\033[35m'     # Tokens - magenta for metrics
BLUE='\033[34m'        # Git branch - blue for source control
WHITE='\033[37m'       # Project name - white for emphasis
GRAY='\033[90m'        # Separators - gray for neutral
RESET='\033[0m'        # Reset color

# Extract current directory
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
dir_name=$(basename "$current_dir")

# Get git branch if in a git repo (skip optional locks)
git_branch=""
if git -C "$current_dir" rev-parse --git-dir > /dev/null 2>&1; then
    git_branch=$(git -C "$current_dir" --no-optional-locks branch --show-current 2>/dev/null)
fi

# Get model display name
model_name=$(echo "$input" | jq -r '.model.display_name')

# Calculate context usage and create progress bar
usage=$(echo "$input" | jq '.context_window.current_usage')
progress_bar=""
percentage=""
token_info=""
bar_color=""

if [ "$usage" != "null" ]; then
    current=$(echo "$usage" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
    size=$(echo "$input" | jq '.context_window.context_window_size')
    pct=$((current * 100 / size))

    # Select color based on percentage
    if [ $pct -le 25 ]; then
        bar_color="$GREEN"
    elif [ $pct -le 50 ]; then
        bar_color="$YELLOW"
    elif [ $pct -le 75 ]; then
        bar_color="$ORANGE"
    else
        bar_color="$RED"
    fi

    # Create progress bar (20 characters wide)
    bar_width=20
    filled=$((pct * bar_width / 100))
    empty=$((bar_width - filled))

    progress_bar="["
    for ((i=0; i<filled; i++)); do progress_bar+="="; done
    for ((i=0; i<empty; i++)); do progress_bar+="$(printf '\033[90m')-$(printf '\033[0m')"; done
    progress_bar+="]"

    percentage="${pct}%"
    token_info="${current}/${size}"
fi

# Build output with colors - exact order: Model | Progress | Percentage | Tokens | Branch | Project
printf "${CYAN}%s${RESET}" "$model_name"

if [ -n "$progress_bar" ]; then
    printf " ${GRAY}|${RESET} ${bar_color}%s${RESET}" "$progress_bar"
    printf " ${GRAY}|${RESET} ${YELLOW}%s${RESET}" "$percentage"
    printf " ${GRAY}|${RESET} ${MAGENTA}%s${RESET}" "$token_info"
fi

if [ -n "$git_branch" ]; then
    printf " ${GRAY}|${RESET} ${BLUE}%s${RESET}" "$git_branch"
fi

printf " ${GRAY}|${RESET} ${WHITE}%s${RESET}" "$dir_name"
