# JJ + Dolt Lab Notes

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
