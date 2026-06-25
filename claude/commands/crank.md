---
description: Resolve ambiguity in the current work, then drive it to completion
argument-hint: [optional extra context or constraints]
---
Look at the git diff (both staged and unstaged, and untracked files) to
understand what I've been working on. I've been using code as a way to think
through this, and now I want you to wrap it up.

First, resolve ambiguity: identify the open decisions, half-finished paths, and
TODOs in the diff. If anything material is unclear, ask me about it using
structured multiple-choice questions (AskUserQuestion) — group them, lead with
your recommended option, and only ask about things that actually change what you
build. Don't ask about things you can settle yourself from the diff.

Once the ambiguity is resolved, continue the work to completion: finish the
implementation, match the surrounding style, and build/test as appropriate.

Additional context for this run: $ARGUMENTS
