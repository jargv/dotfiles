# Claude Instructions

## File Opening Preference
When asked to open files, always use `vim -O <file1> <file2> ...` to open them in vim with vertical splits. Use relative paths from the current working directory. When a line number is specified or referenced in a snippet (e.g., file.txt:42, or "take me to that code"), append `+42` or the referenced line number to the vim command to jump to that line.
