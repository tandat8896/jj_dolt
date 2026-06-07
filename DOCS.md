# JJ + Dolt Lab Notes

## Today learning log

Date: 2026-06-07

Goal:

- Learn Jujutsu (`jj`) from Git knowledge.
- Keep enough command/output notes to explain the workflow later.
- Use GitHub only through `jj` bookmarks and Git interop.

Current state:

```text
main -> docs: add jj learning roadmap
@    -> empty working-copy commit
```

Check state anytime:

```sh
jj status
jj log
jj bookmark list
```

## JJ learning roadmap

### Easy

1. Working copy, change, commit
   - Git habit: edit -> `git add` -> `git commit`
   - JJ habit: edit -> changes are already in `@` -> `jj commit`
   - Commands: `jj status`, `jj diff`, `jj log`, `jj commit`

2. Init and Git interop
   - Git: `git init`, `git clone`
   - JJ: `jj git init --colocate`, `jj git clone`
   - Colocated repos can still use Git/GitHub.

3. Bookmark basics
   - Git: branch moves automatically on commit
   - JJ: bookmark is a name that must be moved intentionally
   - Commands: `jj bookmark create`, `jj bookmark set`, `jj bookmark delete`

### Easy-Medium

4. Push and fetch through Git
   - Git: `git push origin main`
   - JJ: `jj git push --bookmark main --remote origin`
   - Avoid `jj git push --change @-` unless temporary branch names are fine.

5. No stash mindset
   - Git: `git stash`
   - JJ: create another working-copy commit with `jj new`, then come back later
   - Commands: `jj new`, `jj edit`, `jj squash`, `jj restore`

6. Restore and undo
   - Git: `git restore`, `git reset`, `git reflog`
   - JJ: `jj restore`, `jj abandon`, `jj undo`, `jj op log`

### Medium

7. Amend-like workflows
   - Git: `git commit --amend`
   - JJ: `jj describe`, `jj squash`

8. Partial commits
   - Git: `git add -p`
   - JJ: `jj split -i`, `jj commit -i`

9. Abandon and duplicate
   - Git: reset/cherry-pick patterns
   - JJ: `jj abandon`, `jj duplicate`

### Hard

10. Rebase
    - Git: `git rebase main`
    - JJ: `jj rebase -b <bookmark> -d <destination>`
    - Rebase moves changes, not just branches.

11. Conflict resolution
    - Git: edit conflict -> `git add` -> continue
    - JJ: `jj new <conflicted>`, edit, `jj diff`, `jj squash`

12. Revsets
    - Git: revision syntax like `HEAD~2`, branch names, ranges
    - JJ: query-like revision selectors
    - Examples: `@`, `@-`, `main..@`, `ancestors(@)`

### Very Hard

13. Smart history editing
    - Replace interactive rebase habits with `split`, `squash`, `describe`,
      `rebase`, and revsets.

14. Operation log
    - Git: `reflog`
    - JJ: `jj op log`, `jj undo`, `jj op restore`

15. Team workflow on GitHub
    - Local: use `jj`
    - Remote: expose clean bookmarks as Git branches
    - Commands: `jj bookmark set`, `jj git push`, `jj git fetch`

### Extreme

16. Multiple working copies
    - Similar goal to Git worktrees, but in JJ's model.

17. Stacked changes
    - Build chains of small reviewable commits and move/split/squash them safely.

18. Explaining "Git without pain"
    - No staging tax.
    - First-class undo.
    - History editing is normal.
    - Git interop remains available.

## Lesson 1: working copy, change, commit

First principle:

In Git, the working directory is separate from commits. In JJ, the working
copy is itself a commit named `@`.

Important names:

- `@`: current working-copy commit
- `@-`: parent of `@`
- change id: stable identity of a change across rewrites
- commit id: concrete snapshot id; it changes when history is rewritten

Git flow:

```sh
git status
git add .
git commit -m "message"
```

JJ flow:

```sh
jj status
jj diff
jj commit -m "message"
```

Exercise:

```sh
jj status
jj log
printf 'lesson 1\n' > LESSON1.md
jj status
jj diff
jj commit -m "lesson: understand jj working copy"
jj status
jj log
```

Paste the final `jj status` and `jj log` after doing the exercise.

## Lesson 2: init, colocated Git repo, and Git interop

First principle:

Jujutsu is not a Git replacement at the storage boundary. In normal GitHub
workflows, JJ can use a Git repository as its backend. That means you can work
locally with `jj`, while GitHub and teammates still see normal Git commits and
branches.

The setup used in this lab is a colocated repo:

```text
repo/
├── .git/   # Git storage and GitHub interop
└── .jj/    # Jujutsu metadata and operation log
```

Git command:

```sh
git init
```

JJ equivalent for an existing Git repo:

```sh
jj git init --colocate
```

In recent JJ versions, `--colocate` is the default for `jj git init` unless the
config says otherwise. Keeping the flag in notes is useful because it states the
intent clearly: Git and JJ operate in the same working directory.

### What changes from Git?

Git branches are refs that usually move as you commit. In JJ, Git-visible branch
names are represented as bookmarks. A bookmark is only a name pointing to a
commit. It does not automatically move just because you created a new commit.

That is why this pattern is common:

```sh
jj commit -m "message"
jj bookmark set main -r @-
jj git push --bookmark main --remote origin
```

Meaning:

- `jj commit`: describe the current working-copy commit and create a new `@`
- `@-`: the commit that was just created
- `jj bookmark set main -r @-`: move Git-visible `main` to that commit
- `jj git push --bookmark main --remote origin`: push that bookmark to GitHub

### Git interop commands

Inspect Git remote:

```sh
git remote -v
```

Fetch Git remote data into JJ:

```sh
jj git fetch --remote origin
```

Push a bookmark to GitHub:

```sh
jj git push --bookmark main --remote origin
```

Create a feature bookmark and push it:

```sh
jj bookmark create lesson-2-demo -r @-
jj git push --bookmark lesson-2-demo --remote origin
```

Delete a bookmark and delete it remotely:

```sh
jj bookmark delete lesson-2-demo
jj git push --deleted --remote origin
```

### Do not confuse these

Temporary push by change:

```sh
jj git push --change @- --remote origin
```

This is convenient for quick experiments, but it can create generated branch
names like:

```text
push-rovytxzsyoxt
```

For clean GitHub work, prefer named bookmarks:

```sh
jj bookmark create my-feature -r @-
jj git push --bookmark my-feature --remote origin
```

### Compare with Git

```text
Git                         JJ
git init                    jj git init --colocate
git clone URL               jj git clone URL
git branch feature          jj bookmark create feature -r @-
git switch feature          jj new feature / jj edit feature
git push origin main        jj git push --bookmark main --remote origin
git fetch origin            jj git fetch --remote origin
git branch -d feature       jj bookmark delete feature
```

Important difference:

In Git, "being on a branch" is central. In JJ, "where `@` is" and "where the
bookmark points" are separate ideas.

### Exercise

Run:

```sh
jj status
jj log
jj bookmark list
git remote -v
```

Create a small Lesson 2 commit:

```sh
printf 'lesson 2: jj uses git interop through bookmarks\n' > LESSON2.md
jj status
jj diff
jj commit -m "lesson: understand jj git interop"
```

Move `main` to the new commit and push:

```sh
jj bookmark set main -r @-
jj git push --bookmark main --remote origin
```

Check the final state:

```sh
jj status
jj log
jj bookmark list
```

Paste the final `jj status`, `jj log`, and `jj bookmark list`.

Do not continue to Lesson 3 until this output makes sense.

## Repo setup

This repo is a small lab for learning Jujutsu (`jj`) and Dolt with Nix.

Useful files:

- `flake.nix`: dev shell with `dolt` and `jujutsu`
- `.envrc`: loads the flake through direnv
- `.gitignore`: ignores local tool metadata

Enter the shell:

```sh
direnv allow
```

## Jujutsu basics

`jj` tracks file changes like Git, but it does not use Git's staging area.

Common commands:

```sh
jj status
jj diff
jj log
jj commit -m "message"
```

Important revisions:

- `@`: current working-copy commit
- `@-`: parent of `@`, usually the commit just created after `jj commit`

After `jj commit`, `@` becomes a new empty working-copy commit. This is normal.

## Bookmarks and pushing

In `jj`, Git branches are represented as bookmarks.

Move `main` to the latest created commit:

```sh
jj bookmark set main -r @-
jj git push --bookmark main --remote origin
```

Create and push a feature bookmark:

```sh
jj bookmark create my-feature -r @-
jj git push --bookmark my-feature --remote origin
```

For later commits on the same feature bookmark:

```sh
jj bookmark set my-feature -r @-
jj git push --bookmark my-feature --remote origin
```

Avoid using this for long-lived work unless you are okay with temporary branch names:

```sh
jj git push --change @- --remote origin
```

It creates generated branch/bookmark names like `push-rovytxzsyoxt`.

Delete a pushed bookmark:

```sh
jj bookmark delete my-feature
jj git push --deleted --remote origin
```

## Rebase demo

Goal shape before rebase:

```text
base
├─ main
└─ rebase-demo
```

Current lab created this kind of shape:

```text
main        -> docs add main line
rebase-demo -> docs add feature line
```

Run:

```sh
jj rebase -b rebase-demo -d main
jj log
```

Meaning:

- `-b rebase-demo`: move the branch/bookmark and its descendants
- `-d main`: place it on top of `main`

If the rebase is confusing or wrong:

```sh
jj undo
```

## Rebase conflict demo

Create a real conflict by making two branches write different content to the
same file.

Feature side:

```sh
jj new main
printf 'feature version\n' > CONFLICT.md
jj commit -m "feature: write conflict file"
jj bookmark create conflict-demo -r @-
```

Main side:

```sh
jj new main
printf 'main version\n' > CONFLICT.md
jj commit -m "main: write conflict file"
jj bookmark set main -r @-
```

Rebase feature onto main:

```sh
jj rebase -b conflict-demo -d main
```

Expected result:

```text
New conflicts appeared in 1 commits:
  <change-id> <commit-id> conflict-demo | (conflict) feature: write conflict file
```

To resolve, create a working-copy commit on top of the conflicted commit:

```sh
jj new conflict-demo
```

Open the conflicted file:

```sh
nvim CONFLICT.md
```

Jujutsu conflict markers can look like this:

```text
<<<<<<< conflict 1 of 1
%%%%%%% diff from: <base> "docs add jj and dolt lab notes" (parents of rebased revision)
\\\\\\\        to: <main> "main: write conflict file" (rebase destination)
+main version
+++++++ <feature> "feature: write conflict file" (rebased revision)
feature version
>>>>>>> conflict 1 of 1 ends
```

If choosing the main version, leave only:

```text
main version
```

Then check status:

```sh
jj status
```

The useful hint is:

```text
Conflict in parent commit has been resolved in working copy
```

Move the resolution into the conflicted commit:

```sh
jj squash
```

After `jj squash`, the conflicted commit is rewritten without `(conflict)`:

```sh
jj log
jj status
```

Sample transcript from this lab:

```text
$ jj log
@  wuyvzzlk ... 3ee852c2
│  (empty) (no description set)
○  kmwsxmwm ... 017448b2
│  main: write conflict file
│ ○  pmlrvuvx ... conflict-demo d3ccf658
├─╯  feature: write conflict file
◆  rsvvyyks ... main 61ae7472
│  docs add jj and dolt lab notes
~

$ jj bookmark set main -r @-
Moved 1 bookmarks to kmwsxmwm 017448b2 main* | main: write conflict file

$ jj rebase -b conflict-demo -d main
Rebased 1 commits to destination
New conflicts appeared in 1 commits:
  pmlrvuvx f806acba conflict-demo | (conflict) feature: write conflict file
Hint: To resolve the conflicts, start by creating a commit on top of
the conflicted commit:
  jj new pmlrvuvx

$ jj status
The working copy has no changes.
Working copy  (@) : wuyvzzlk 3ee852c2 (empty) (no description set)
Parent commit (@-): kmwsxmwm 017448b2 main* | main: write conflict file

$ jj new pmlrvuvx
Working copy  (@) now at: omlrnyon 9cc63f15 (conflict) (empty) (no description set)
Parent commit (@-)      : pmlrvuvx f806acba conflict-demo | (conflict) feature: write conflict file
Warning: There are unresolved conflicts at these paths:
CONFLICT.md    2-sided conflict

$ nvim CONFLICT.md
# Leave only:
# main version

$ jj status
Working copy changes:
M CONFLICT.md
Working copy  (@) : omlrnyon 45a9b48f (no description set)
Parent commit (@-): pmlrvuvx f806acba conflict-demo | (conflict) feature: write conflict file
Hint: Conflict in parent commit has been resolved in working copy

$ jj diff
Resolved conflict in CONFLICT.md:
   1     : <<<<<<< conflict 1 of 1
   2     : %%%%%%% diff from: rsvvyyks 61ae7472 "docs add jj and dolt lab notes" (parents of rebased revision)
   3     : \\\\\\\        to: kmwsxmwm 017448b2 "main: write conflict file" (rebase destination)
   4    1: +main version
   5     : +++++++ pmlrvuvx d3ccf658 "feature: write conflict file" (rebased revision)
   6     : feature version
   7     : >>>>>>> conflict 1 of 1 ends

$ jj squash
Working copy  (@) now at: pkrqxltu b7b60a3b (empty) (no description set)
Parent commit (@-)      : pmlrvuvx d21dc763 conflict-demo | feature: write conflict file
Existing conflicts were resolved or abandoned from 1 commits.

$ jj log
@  pkrqxltu ... b7b60a3b
│  (empty) (no description set)
○  pmlrvuvx ... conflict-demo d21dc763
│  feature: write conflict file
○  kmwsxmwm ... main* 017448b2
│  main: write conflict file
◆  rsvvyyks ... main@origin 61ae7472
│  docs add jj and dolt lab notes
~

$ jj status
The working copy has no changes.
Working copy  (@) : pkrqxltu b7b60a3b (empty) (no description set)
Parent commit (@-): pmlrvuvx d21dc763 conflict-demo | feature: write conflict file
```

If the conflict demo gets messy:

```sh
jj undo
```

## Empty commits

If `jj status` is clean and you run:

```sh
jj commit -m "another change"
```

`jj` can create an empty commit. Remove the previous commit:

```sh
jj abandon @-
```

## Dolt basics

Dolt versions SQL database state: tables, rows, and schema.

Common commands:

```sh
dolt status
dolt diff
dolt log --graph --oneline
dolt sql -q "select * from notes;"
```

Create a table and data:

```sh
dolt sql -q "create table notes (id int primary key, title varchar(100), body varchar(255));"
dolt sql -q "insert into notes values (1, 'learn jj', 'jj has no staging area'), (2, 'learn dolt', 'dolt versions sql tables');"
dolt add notes
dolt commit -m "create notes table"
```

Unlike `jj`, Dolt has staging:

```sh
dolt add notes
dolt commit -m "message"
```

## Dolt branches and conflicts

Create a conflict by changing the same row and column on two branches.

Feature side:

```sh
dolt checkout feature
dolt sql -q "update notes set body = 'change from feature' where id = 2;"
dolt add notes
dolt commit -m "feature changes note 2"
```

Main side:

```sh
dolt checkout main
dolt sql -q "update notes set body = 'change from main' where id = 2;"
dolt add notes
dolt commit -m "main changes notes 2"
```

Merge:

```sh
dolt merge feature
```

Inspect conflicts:

```sh
dolt conflicts cat notes
dolt sql -q "select * from dolt_conflicts_notes;"
```

Conflict rows mean:

- `base`: value before branches diverged
- `ours`: value on the current branch
- `theirs`: value from the branch being merged

Resolve with current branch:

```sh
dolt conflicts resolve --ours notes
dolt add notes
dolt commit -m "resolve notes conflict using main"
```

Resolve with incoming branch:

```sh
dolt conflicts resolve --theirs notes
dolt add notes
dolt commit -m "resolve notes conflict using feature"
```

## Git ignore choices

For normal GitHub usage, ignore local metadata:

```gitignore
.direnv/
.jj/
.dolt/
```

This lab intentionally tracked `.doltcfg/branch_control.db` once to see what Dolt creates. It is binary/internal Dolt config, not table data.

Do not commit `.dolt/` to GitHub. Share Dolt databases with Dolt remotes/DoltHub instead.
