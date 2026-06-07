# Lesson 2: JJ Git Interop and Bookmarks

## Goal

Understand how Jujutsu (`jj`) works with a normal Git/GitHub repository.

This repo is colocated:

```text
repo/
├── .git/   # Git storage and GitHub remote interop
└── .jj/    # Jujutsu metadata and operation log
```

That means:

- GitHub still sees normal Git commits and branches.
- Locally, we use `jj` commands.
- Git-visible branch names are managed by JJ bookmarks.

## Current lesson output

Starting state:

```text
$ jj status
The working copy has no changes.
Working copy  (@) : lyymzrkt dd22b1b4 (empty) (no description set)
Parent commit (@-): vrlvmsns a925f7de main | docs: add jj lesson 2 git interop
```

```text
$ jj log
@  lyymzrkt ... dd22b1b4
│  (empty) (no description set)
◆  vrlvmsns ... main a925f7de
│  docs: add jj lesson 2 git interop
~
```

Bookmarks:

```text
$ jj bookmark list
conflict-demo: pmlrvuvx d21dc763 feature: write conflict file
main: vrlvmsns a925f7de docs: add jj lesson 2 git interop
my-feature: zlyuprsl dde0f350 track dolt branch control config
```

Remote:

```text
$ git remote -v
origin  git@github.com:tandat8896/jj_dolt.git (fetch)
origin  git@github.com:tandat8896/jj_dolt.git (push)
```

## Exercise commit

Create a file:

```sh
printf 'lesson 2: jj uses git interop through bookmarks\n' > LESSON2.md
```

Inspect:

```sh
jj status
jj diff
```

Commit:

```sh
jj commit -m "lesson: understand jj git interop"
```

After commit, JJ creates a new empty working-copy commit `@`. The real commit is
now `@-`.

Example final state:

```text
$ jj status
The working copy has no changes.
Working copy  (@) : pyvzuyso c126c5d4 (empty) (no description set)
Parent commit (@-): lyymzrkt 298a10ad main | lesson: understandjj git interop
```

```text
$ jj log
@  pyvzuyso ... c126c5d4
│  (empty) (no description set)
◆  lyymzrkt ... main 298a10ad
│  lesson: understandjj git interop
~
```

## Bookmark idea

In Git, a branch usually moves as you commit.

In JJ, a bookmark is just a name pointing at a commit. It does not always move
just because a new commit exists.

Move `main` to the commit just created:

```sh
jj bookmark set main -r @-
```

Push `main` to GitHub:

```sh
jj git push --bookmark main --remote origin
```

This is the clean GitHub workflow:

```sh
jj commit -m "message"
jj bookmark set main -r @-
jj git push --bookmark main --remote origin
```

## Mistake: typo in commit message

The first message had a typo:

```text
lesson: understandjj git interop
```

Wanted:

```text
lesson: understand jj git interop
```

The correct command syntax is:

```sh
jj describe -r main -m "lesson: understand jj git interop"
```

Wrong command:

```sh
jj describe -r main "lesson : understand jj git interop"
```

Why it failed:

- Without `-m`, JJ treats the quoted text as a revision expression.
- The `:` made the revset parser fail.

## Immutable commit error

JJ may reject editing a commit message with:

```text
Error: Commit <id> is immutable
Hint: Immutable commits are used to protect shared history.
```

First principle:

Changing a commit message rewrites the commit. It creates a new commit id.

```text
before:
298a10ad lesson: understandjj git interop

after:
ac730ab6 lesson: understand jj git interop
```

JJ protects commits that look shared or remote-tracked. That is what immutable
means.

Safe choice while learning:

```sh
jj git push --bookmark main --remote origin
```

Force-rewrite choice, only when you know it is safe:

```sh
jj describe -r main --ignore-immutable -m "lesson: understand jj git interop"
```

## Git comparison

```text
Git                                  JJ
git branch                           jj bookmark list
git push origin main                 jj git push --bookmark main --remote origin
git commit --amend -m "new message"  jj describe -r <rev> -m "new message"
git reflog                           jj op log
```

## Lesson takeaway

Remember:

```text
Git branch = moving ref
JJ bookmark = Git-visible name pointing to a commit
@ = current working-copy commit
@- = parent of @, usually the commit just made
Changing message = rewriting commit
Immutable = JJ is protecting shared history
```
