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
