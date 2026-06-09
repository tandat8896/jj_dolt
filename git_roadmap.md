# Git Roadmap Before Jujutsu

This roadmap uses Git as the primary learning path. Jujutsu (`jj`) comparisons
are included only to build intuition for later.

## Already Known: Easy

These are assumed known and will not be taught from scratch:

- `status`
- `add`
- `commit`
- `log`
- `clone`
- `pull`
- `push`

JJ comparison:

```text
Git add/commit/log/status -> jj status, jj diff, jj commit, jj log
Git staging area          -> jj has no Git-style staging area
Git branch after commit   -> jj uses bookmarks that may need explicit movement
```

## Easy-Medium

1. Branching
   - Branch as a pointer/ref
   - `HEAD`
   - detached `HEAD`
   - local branch vs remote-tracking branch
   - upstream branch
   - JJ comparison: bookmark

2. Remotes
   - `origin`
   - `origin/main`
   - fetch vs pull
   - tracking branches
   - prune stale remote refs
   - JJ comparison: `jj git fetch`, `jj git push`

3. Merging
   - fast-forward merge
   - true merge commit
   - `--no-ff`
   - squash merge
   - merge strategy at PR level
   - JJ comparison: rebase/squash/bookmark movement

4. Stash
   - save temporary work
   - staged vs unstaged behavior
   - `apply` vs `pop`
   - stash branch
   - JJ comparison: `jj new`, anonymous commits, `jj restore`

5. Tags
   - lightweight tags
   - annotated tags
   - release tags
   - push/delete tags
   - JJ comparison: Git tags still matter for GitHub releases

## Medium

6. Merge conflicts
   - conflict markers
   - ours/theirs
   - `git add` after resolving
   - merge vs rebase conflict flow
   - rerere
   - JJ comparison: conflicted commits, `jj new <conflicted>`, `jj squash`

7. Rebase
   - replaying commits
   - rebase branch onto updated base
   - `--onto`
   - abort/continue/skip
   - JJ comparison: `jj rebase -b/-s/-r -d`

8. Cherry-pick
   - apply selected commits
   - backporting
   - conflict handling
   - JJ comparison: `jj duplicate`, `jj rebase`, sometimes new commits

9. Reset
   - `--soft`
   - `--mixed`
   - `--hard`
   - when reset is dangerous
   - JJ comparison: `jj restore`, `jj abandon`, `jj undo`

10. Revert
    - inverse commit
    - reverting merges
    - safe shared-history rollback
    - JJ comparison: `jj backout`

11. Reflog
    - finding old branch positions
    - recovering lost commits
    - expiration caveats
    - JJ comparison: `jj op log`, `jj undo`, `jj op restore`

## Hard

12. Bisect
    - binary search history
    - manual and scripted bisect
    - regression debugging

13. Hooks
    - pre-commit
    - pre-push
    - commit-msg
    - shared hook strategy
    - JJ comparison: pre-commit tooling, `jj-pre-push`, CI

14. Submodules
    - when not to use them
    - update/init
    - pinning dependency repos
    - alternatives

15. Interactive rebase
    - pick/reword/edit/squash/fixup/drop
    - splitting commits
    - safe force push
    - JJ comparison: `jj split`, `jj squash`, `jj describe`, `jj rebase`

16. Debugging history
    - `git log --graph`
    - `git show`
    - `git blame`
    - `git diff A..B`
    - `git range-diff`

## Very Hard

17. Recovering lost commits
    - reflog
    - fsck
    - dangling commits
    - stash recovery

18. Rewriting history safely
    - force-with-lease
    - branch protection
    - shared vs private history
    - communication rules

19. Internals
    - object database
    - blobs, trees, commits, tags
    - refs
    - index
    - packfiles

20. Large repos
    - shallow clone
    - partial clone
    - sparse checkout
    - LFS
    - performance constraints

## Extreme

21. Monorepo
    - ownership
    - sparse checkout
    - CI path filtering
    - release strategy

22. Polyrepo
    - dependency management
    - cross-repo changes
    - versioning
    - release coordination

23. Enterprise Git workflow design
    - branch protection
    - PR policy
    - merge strategy
    - release trains
    - auditability

24. Migration
    - SVN/Git migration
    - repo split/merge
    - history filtering
    - preserving tags/authors

## Current Lesson

Start at Easy-Medium:

```text
Git Lesson 2: Branching Deep Dive
```

