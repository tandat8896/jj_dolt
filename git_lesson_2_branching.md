# Git Lesson 2: Branching Deep Dive

## Goal

Understand branches from first principles before studying merge, rebase, PRs,
and Jujutsu bookmarks.

You already know basic `git branch` usage. This lesson focuses on what a branch
is and how to inspect it.

## First principles

A Git commit is a snapshot plus metadata:

```text
commit -> tree snapshot + parent commit(s) + author + message
```

A branch is not a copy of files. A branch is a movable name pointing to a
commit.

```text
main
 |
 v
A---B---C
```

Here, `main` points to commit `C`.

When you commit while `main` is checked out:

```text
before:

A---B---C  main

after:

A---B---C---D  main
```

The branch moved from `C` to `D`.

## HEAD

`HEAD` means "where my working tree is currently based."

Usually, `HEAD` points to a branch:

```text
HEAD -> main -> C
```

That means:

- you are on branch `main`
- new commits move `main`

Check:

```sh
git status -sb
git symbolic-ref --short HEAD
```

## Detached HEAD

Detached `HEAD` means `HEAD` points directly to a commit, not to a branch.

```text
HEAD -> C
main -> D
```

This happens when you check out a commit directly:

```sh
git switch --detach HEAD~1
```

If you commit here, the commit is not attached to a branch name. It can be lost
from normal branch view unless you create a branch or recover it from reflog.

Recover by creating a branch:

```sh
git switch -c rescue-branch
```

Return to main:

```sh
git switch main
```

## Local branch vs remote-tracking branch

Local branch:

```text
main
```

Remote-tracking branch:

```text
origin/main
```

`origin/main` is your local record of where the remote `main` was at the last
fetch.

It does not update by itself. It updates when you run:

```sh
git fetch origin
```

Do not think `origin/main` is live GitHub state. It is a cached local ref.

Inspect:

```sh
git branch
git branch -r
git branch -vv
git log --oneline --graph --decorate --all -n 20
```

## Upstream branch

An upstream branch is the default remote branch that your local branch pulls
from and pushes to.

Example:

```text
local main tracks origin/main
```

Inspect:

```sh
git branch -vv
git rev-parse --abbrev-ref --symbolic-full-name @{u}
```

Set upstream:

```sh
git push -u origin my-branch
```

or:

```sh
git branch --set-upstream-to=origin/my-branch my-branch
```

## Common branching commands

Create branch:

```sh
git switch -c feature/branching-demo
```

Switch branch:

```sh
git switch main
git switch feature/branching-demo
```

Rename current branch:

```sh
git branch -m new-name
```

Delete merged branch:

```sh
git branch -d feature/branching-demo
```

Force delete unmerged branch:

```sh
git branch -D feature/branching-demo
```

## Practical maintainer workflow

Before working on a branch:

```sh
git fetch origin
git switch main
git pull --ff-only
git switch -c feature/small-change
```

Why `--ff-only` on `main`:

- it refuses to create an accidental merge commit
- it keeps local `main` exactly aligned with `origin/main`
- it is safer for maintainers

## Git vs JJ

```text
Git branch              JJ bookmark
Git HEAD                JJ working-copy commit @
Git branch auto-moves   JJ bookmark may need explicit `jj bookmark set`
origin/main             remote bookmark / Git remote state through jj git fetch
detached HEAD           normal-ish in jj because @ is explicit working copy
```

In Git:

```sh
git switch -c feature
git commit -m "message"
git push -u origin feature
```

In JJ:

```sh
jj new main
jj commit -m "message"
jj bookmark create feature -r @-
jj git push --bookmark feature --remote origin
```

## Exercise

Do this in the lab repo.

Start clean:

```sh
git status -sb
git branch -vv
git log --oneline --graph --decorate --all -n 12
```

Create a branch:

```sh
git switch -c feature/git-branching-demo
printf 'git branching lesson\n' > GIT_BRANCHING.md
git add GIT_BRANCHING.md
git commit -m "lesson: git branching basics"
```

Inspect:

```sh
git status -sb
git branch -vv
git log --oneline --graph --decorate --all -n 12
```

Do not push yet.

Paste the final output of:

```sh
git status -sb
git branch -vv
git log --oneline --graph --decorate --all -n 12
```

Then we will explain:

- where `HEAD` points
- where `main` points
- where `feature/git-branching-demo` points
- how this compares to `jj bookmark list`

