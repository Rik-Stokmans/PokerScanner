---
description: Resolve all unchecked todos in TODOS.md via parallel sub-agents (one agent per cluster of related todos), then commit each group's changes to the main branch
allowed-tools: Read, Write, Edit, Bash, Agent
---

## Context

Todo file: `/Users/rikstokmans/Claude/PokerScanner/TODOS.md`

Repo map (absolute path → branch):

| Short name    | Path                                         | Branch   |
|---------------|----------------------------------------------|----------|
| poker-scanner | /Users/rikstokmans/Claude/PokerScanner       | `master` |

Failure policy: **skip-and-continue**. A single failing todo or group must never block the others. Report everything at the end.

---

## Task

### 1. Pre-flight

Run `git -C /Users/rikstokmans/Claude/PokerScanner status --porcelain`. If the repo is dirty, **stop immediately** and print the dirty files. Do not proceed — the coordinator will use worktrees and needs a stable base.

### 2. Parse todos

Read `TODOS.md`. Collect every `- [ ]` item as one todo, including any indented continuation lines below it as part of the description. Ignore `- [x]` lines and the file header. Assign each unchecked todo a short stable id: `t1`, `t2`, … in file order.

If there are zero unchecked todos, print "No todos to resolve." and stop.

### 3. Cluster related todos into groups

Look at the todo texts and decide which ones clearly belong together. Two todos belong in the same group when any of the following is true:

- They describe work in the same screen, feature area, or widget.
- They would likely edit the same files or the same function.
- One is a prerequisite or sequel of the other.
- They are phrased as variations of the same underlying problem.

Otherwise, keep them separate. **When in doubt, prefer singleton groups** — over-clustering wastes an agent's context on unrelated todos and increases the blast radius of a single failure.

Form groups and assign each a short id: `g1`, `g2`, … A group contains 1+ todo ids. Every todo must belong to exactly one group.

Before dispatching, print a one-line per-group summary so the user can see the plan:
```
g1 [t1, t3]   → hand-ranking display
g2 [t2]       → dark mode flash
g3 [t4, t5]   → camera scanner + permissions
```

### 4. Dispatch one sub-agent per GROUP, in parallel

Send **one message containing all the Agent tool calls** so they run concurrently. For each group, call the `Agent` tool with:

- `subagent_type`: `general-purpose`
- `description`: `Resolve group <group-id>`
- `prompt`: the brief below, with `{{GROUP_ID}}`, `{{TODO_COUNT}}`, and `{{TODOS_BLOCK}}` substituted.

`{{TODOS_BLOCK}}` is the concatenation of every member todo in the group, formatted as:
```
Todo t1:
<<<
<full description, preserving indentation>
>>>

Todo t3:
<<<
<full description>
>>>
```

Do **not** pass `run_in_background`. We want to block until all agents finish.

---

#### Agent brief (substitute `{{GROUP_ID}}`, `{{TODO_COUNT}}`, `{{TODOS_BLOCK}}`)

```
You are resolving a GROUP of {{TODO_COUNT}} related todo(s) from the
PokerScanner Flutter codebase. Other agents are resolving other groups
in parallel — you must not touch their work or the shared repo checkout.

Group id: {{GROUP_ID}}
Todos in this group:

{{TODOS_BLOCK}}

Repo path and branch:
  poker-scanner  /Users/rikstokmans/Claude/PokerScanner  master

Procedure:

1. Explore the codebase enough to understand the relevant files and
   context. Do not guess — read the code first.

2. Create a private worktree so parallel agents never collide.
   Work exclusively inside the worktree path:

       REPO=/Users/rikstokmans/Claude/PokerScanner
       WT=/tmp/todo-{{GROUP_ID}}-poker-scanner
       git -C "$REPO" worktree add "$WT" -b "todo/{{GROUP_ID}}" HEAD

   All edits and commits happen inside $WT. Never touch $REPO directly.

3. Implement the change(s). Keep scope tight — solve only what the todos
   describe. No refactors, no drive-by fixes, no new abstractions.

   If the todos are genuinely related (same files/feature), group them
   into ONE cohesive commit. If a todo turns out to be unresolvable or
   out of scope, skip it and note that in the result JSON (see step 6).

4. Build the project inside the worktree to verify correctness:
       cd $WT && flutter analyze --no-fatal-infos
   This must pass (exit 0). If it fails, try to fix. If still failing
   after reasonable effort, do NOT commit.

5. If the analysis is green, stage and commit inside the worktree:
       git -C "$WT" add <relevant files>
       git -C "$WT" commit -m "<short imperative sentence>"
   Commit message: one short imperative sentence that accurately covers
   what the commit does. No emojis, no task-id prefix, no Co-Authored-By.

6. Write a JSON result file at `/tmp/todo-{{GROUP_ID}}-result.json`
   with exactly this shape:

   {
     "group_id": "{{GROUP_ID}}",
     "todo_ids": ["t1", "t3"],
     "status": "success" | "partial" | "failed",
     "reason": "<string, required when status != success>",
     "unresolved_todo_ids": ["t3"],
     "changes": [
       {
         "repo_path": "/Users/rikstokmans/Claude/PokerScanner",
         "short_name": "poker-scanner",
         "worktree_path": "/tmp/todo-{{GROUP_ID}}-poker-scanner",
         "branch": "todo/{{GROUP_ID}}",
         "commit_sha": "<full sha>",
         "commit_message": "<your message>",
         "resolved_todo_ids": ["t1"]
       }
     ]
   }

   Rules:
   - `resolved_todo_ids` lists the todo ids that commit actually addresses.
   - `unresolved_todo_ids` lists any todos you could NOT address. Empty
     array if you handled them all.
   - `status = "success"` iff every member todo is covered by at least
     one change AND the repo committed cleanly.
   - `status = "partial"` iff at least one commit landed but something
     else didn't — explain in `reason`.
   - `status = "failed"` iff nothing could be committed. `changes: []`.

7. Do NOT push. Do NOT edit TODOS.md. Do NOT remove worktrees. The
   coordinator handles all of that.

Your final message back to the coordinator: ≤ 3 lines. State the result
file path and a one-line outcome.
```

---

### 5. Collect results

After all agents return, read every `/tmp/todo-<group-id>-result.json` file. If a result file is missing for some group, treat every todo in that group as `failed` with reason `"agent did not produce a result file"`.

### 6. Coordinator phase — cherry-pick into master (serial)

Flatten every successful/partial group's `changes` entries, ordered by the smallest `todo_id` in `resolved_todo_ids` (so `t1` changes land before `t5` changes).

For each change:

1. In the **original** repo path:
   ```
   git -C /Users/rikstokmans/Claude/PokerScanner cherry-pick <commit_sha>
   ```
   If it fails:
   ```
   git -C /Users/rikstokmans/Claude/PokerScanner cherry-pick --abort
   ```
   Record every `todo_id` in that change's `resolved_todo_ids` as `"conflict"`, and continue.

2. After all cherry-picks, clean up **all** worktrees (for every group):
   ```
   git -C /Users/rikstokmans/Claude/PokerScanner worktree remove <worktree-path> --force
   git -C /Users/rikstokmans/Claude/PokerScanner branch -D <branch>
   ```
   Ignore errors from branches/worktrees that don't exist.

### 7. Update TODOS.md

Per-todo final state (derive from group results + cherry-pick outcomes):

- **done**: the todo appears in `resolved_todo_ids` of at least one change, AND that change cherry-picked cleanly → flip `- [ ]` to `- [x]`.
- **partial**: the todo was resolved by the agent but its change conflicted on cherry-pick → leave `- [ ]`, append an indented `> note: partial — cherry-pick conflict` line.
- **unresolved**: the todo appears in the group's `unresolved_todo_ids` → leave `- [ ]`, append `> note: <reason from group>`.
- **failed**: the group status is `failed`, or the group produced no result file → leave `- [ ]`, append `> note: <reason>`.

Edit `TODOS.md` accordingly. If any lines changed:
```
git -C /Users/rikstokmans/Claude/PokerScanner add TODOS.md
git -C /Users/rikstokmans/Claude/PokerScanner commit -m "chore: tick resolved todos"
```

### 8. Final summary

Print a concise report:

```
Groups:
  g1 [t1, t3]  → resolved, committed
  g2 [t2]      → analyze-failed
  g3 [t4, t5]  → t4 resolved, t5 unresolved (out of scope)

Resolved todos:
  - <todo text>

Unresolved / build-failed / conflicts:
  - <todo text>  →  <reason>
```

Omit sections that are empty.
