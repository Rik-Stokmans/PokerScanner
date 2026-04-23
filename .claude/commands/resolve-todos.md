---
description: Resolve all unchecked todos in TODOS.md via parallel sub-agents (one agent per cluster of related todos), then commit each group's changes to the relevant repo(s)
allowed-tools: Read, Write, Edit, Bash, Agent
model: opus
---

## Context

Todo file: `/Users/rikstokmans/Claude/PokerScanner/TODOS.md`

Repo map (absolute path → branch):

| Short name      | Path                                           | Branch   | Stack |
|-----------------|------------------------------------------------|----------|-------|
| poker-scanner   | /Users/rikstokmans/Claude/PokerScanner         | `master` | Flutter (Dart) |
| poker-device    | /Users/rikstokmans/Claude/PokerScannerDevice   | `master` | Arduino C++ (ESP32-C3 + 2× MFRC522 RFID via SPI, NimBLE) |

The device firmware lives in a single sketch file: `Poker_RFID_Reader.ino`.

Failure policy: **skip-and-continue**. A single failing todo or group must never block the others. Report everything at the end.

---

## Task

### 1. Pre-flight

For each repo in the map, run `git -C <path> status --porcelain`. If any repo is dirty, **stop immediately** and print the dirty files. Do not proceed — the coordinator will use worktrees and needs a stable base.

### 2. Parse todos

Read `TODOS.md`. Collect every `- [ ]` item as one todo, including any indented continuation lines below it as part of the description. Ignore `- [x]` lines and the file header. Assign each unchecked todo a short stable id: `t1`, `t2`, … in file order.

If there are zero unchecked todos, print "No todos to resolve." and stop.

### 3. Cluster related todos into groups

Look at the todo texts and decide which ones clearly belong together. Two todos belong in the same group when any of the following is true:

- They describe work in the same screen, feature area, widget, or firmware function.
- They would likely edit the same files or the same function.
- One is a prerequisite or sequel of the other.
- They are phrased as variations of the same underlying problem.

Otherwise, keep them separate. **When in doubt, prefer singleton groups** — over-clustering wastes an agent's context on unrelated todos and increases the blast radius of a single failure.

Form groups and assign each a short id: `g1`, `g2`, … A group contains 1+ todo ids. Every todo must belong to exactly one group.

Before dispatching, print a one-line per-group summary so the user can see the plan:
```
g1 [t1, t3]   → hand-ranking display (poker-scanner)
g2 [t2]       → BLE scan interval (poker-device)
g3 [t4, t5]   → RFID power-down + battery reporting (poker-device)
```

### 4. Dispatch one sub-agent per GROUP, in parallel

Send **one message containing all the Agent tool calls** so they run concurrently. For each group, call the `Agent` tool with:

- `subagent_type`: `general-purpose`
- `model`: `sonnet`
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
PokerScanner codebase. Other agents are resolving other groups in
parallel — you must not touch their work or the shared repo checkouts.

Group id: {{GROUP_ID}}
Todos in this group:

{{TODOS_BLOCK}}

Repos and their branches:
  poker-scanner  /Users/rikstokmans/Claude/PokerScanner        master  (Flutter/Dart)
  poker-device   /Users/rikstokmans/Claude/PokerScannerDevice  master  (Arduino C++, ESP32-C3)

The device firmware is a single sketch: Poker_RFID_Reader.ino
Hardware: Seeed Studio XIAO ESP32-C3, 2× MFRC522 RFID readers on shared
SPI (SCK=D8/GPIO8, MISO=D9/GPIO9, MOSI=D10/GPIO10), CS pins D2/D3,
RST pins D4/D5. NimBLE for BLE. Battery sense on D0/GPIO0.

Procedure:

1. Decide which repo(s) the group requires changes in. Read the relevant
   files first — do not guess.

2. For each repo you will change, create a private worktree so parallel
   agents never collide. Work exclusively inside the worktree path:

       REPO=<absolute repo path>
       SHORT=<short name from the table>
       WT=/tmp/todo-{{GROUP_ID}}-$SHORT
       git -C "$REPO" worktree add "$WT" -b "todo/{{GROUP_ID}}-$SHORT" HEAD

   All edits and commits happen inside $WT. Never touch $REPO directly.

3. Implement the change(s). Keep scope tight — solve only what the todos
   describe. No refactors, no drive-by fixes, no new abstractions.

   If a todo turns out to be unresolvable or out of scope, skip it and
   note that in the result JSON (see step 6). Keep going on the others.

4. Verify correctness inside the worktree, based on the repo:

   poker-scanner (Flutter):
       cd $WT && flutter analyze --no-fatal-infos
     Must exit 0. If it fails, try to fix. If still failing after
     reasonable effort, do NOT commit for this repo.

   poker-device (Arduino C++):
     First check if arduino-cli is available:
       which arduino-cli
     If available, compile:
       arduino-cli compile \
         --fqbn esp32:esp32:XIAO_ESP32C3 \
         --libraries "$WT" \
         "$WT/Poker_RFID_Reader.ino"
     If arduino-cli is NOT installed, do a best-effort static check
     instead (look for obvious syntax errors, mismatched braces, use of
     undefined variables) and note in the result JSON that full
     compilation was skipped due to missing toolchain. This is acceptable
     — do NOT block the commit solely because arduino-cli is absent.

5. If verification passes (or is acceptably skipped for device firmware),
   stage and commit inside the worktree:
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
         "repo_path": "/Users/rikstokmans/Claude/<repo>",
         "short_name": "poker-scanner|poker-device",
         "worktree_path": "/tmp/todo-{{GROUP_ID}}-<short>",
         "branch": "todo/{{GROUP_ID}}-<short>",
         "commit_sha": "<full sha>",
         "commit_message": "<your message>",
         "resolved_todo_ids": ["t1"]
       }
     ]
   }

   Rules:
   - `resolved_todo_ids` on each change lists the todo ids that commit
     actually addresses. A todo id may appear on multiple changes if it
     spans both repos.
   - `unresolved_todo_ids` lists any todos you could NOT address. Empty
     array if you handled them all.
   - `status = "success"` iff every member todo is covered by at least
     one change AND every repo you intended to change committed cleanly.
   - `status = "partial"` iff at least one commit landed but something
     else didn't — list only successfully-committed repos in `changes`
     and explain in `reason`.
   - `status = "failed"` iff nothing could be committed. `changes: []`.

7. Do NOT push. Do NOT edit TODOS.md. Do NOT remove worktrees. The
   coordinator handles all of that.

Your final message back to the coordinator must be **detailed** so the
orchestrator can fully understand what was done and combine results
correctly. Include all of the following sections:

**Result file:** `/tmp/todo-{{GROUP_ID}}-result.json`

**Outcome:** `success | partial | failed` — one sentence explaining why.

**Todos resolved:** list each resolved todo id and a one-sentence
description of the specific change made to address it.

**Todos skipped / failed:** list each with a clear explanation of why it
could not be resolved (out of scope, build error, ambiguous spec, etc.).

**Files changed (per repo):** for each repo touched, list every file path
that was created, modified, or deleted, and briefly describe the change
made to that file (e.g. `lib/screens/hand_history.dart — added sort
button and wired SortOrder enum`).

**Commit details (per repo):**
- Worktree path
- Branch name
- Commit SHA (full)
- Commit message

**Build / verification result:** state whether `flutter analyze` passed,
was skipped, or failed, and why. For device firmware, state whether
arduino-cli compiled cleanly, static-check only, or was skipped.

**Anything the orchestrator should know:** flag any ambiguity you
resolved, any assumption you made, any side-effect the coordinator should
be aware of when cherry-picking (e.g. new dependencies added to
pubspec.yaml, new files the cherry-pick will introduce).
```

---

### 5. Collect results

After all agents return, read every `/tmp/todo-<group-id>-result.json` file. If a result file is missing for some group, treat every todo in that group as `failed` with reason `"agent did not produce a result file"`.

Each sub-agent also returns a detailed message. Cross-reference the agent's message with the JSON file — the message contains richer context (assumptions made, new dependencies, side-effects) that the JSON does not capture. Use that context to make better-informed decisions during cherry-pick and to write accurate TODOS.md notes.

### 6. Coordinator phase — cherry-pick into master (serial, one repo at a time)

Flatten every successful/partial group's `changes` entries and group by `repo_path`. Within each repo, order by the smallest `todo_id` in `resolved_todo_ids` (so `t1` lands before `t5`). For each repo:

1. In the **original** repo path:
   ```
   git -C <repo-path> cherry-pick <commit_sha>
   ```
   If it fails:
   ```
   git -C <repo-path> cherry-pick --abort
   ```
   Record every `todo_id` in that change's `resolved_todo_ids` as `"conflict"`, and continue.

2. After all cherry-picks for all repos, clean up **all** worktrees (for every group, both repos):
   ```
   git -C <repo-path> worktree remove <worktree-path> --force
   git -C <repo-path> branch -D <branch>
   ```
   Ignore errors from branches/worktrees that don't exist.

### 7. Update TODOS.md

Per-todo final state (derive from group results + cherry-pick outcomes):

- **done**: the todo appears in `resolved_todo_ids` of at least one change, AND that change cherry-picked cleanly → flip `- [ ]` to `- [x]`.
- **partial**: the todo was resolved by the agent but its change conflicted on cherry-pick → leave `- [ ]`, append an indented `> note: partial — cherry-pick conflict in <repo>` line.
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
  g1 [t1, t3]  → resolved, committed (poker-scanner)
  g2 [t2]      → resolved, committed (poker-device)
  g3 [t4, t5]  → t4 resolved, t5 unresolved (out of scope)

Resolved todos:
  - <todo text>

Unresolved / build-failed / conflicts:
  - <todo text>  →  <reason>
```

Omit sections that are empty.
