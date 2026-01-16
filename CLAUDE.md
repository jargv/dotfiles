# Claude Instructions

## Git Commits
The user handles all git commits. Don't offer to commit changes.

## Editor
Neovim is the primary editor. The config includes custom plugins:
- `gitato.lua` - git status/diff viewer
- `newb.lua` - file/buffer navigator
- `background_build.lua` - build system integration

When suggesting workflow improvements, check if existing tools can solve the problem before recommending new ones.

## Code Style
zshrc and init.lua use vim-style folds (`{{{1`, `{{{2`) for organization. New sections should follow this pattern.

## File Opening Preference
When asked to open files, always use `vim -O <file1> <file2> ...` to open them in vim with vertical splits. Use relative paths from the current working directory. When a line number is specified or referenced in a snippet (e.g., file.txt:42, or "take me to that code"), append `+42` or the referenced line number to the vim command to jump to that line.
