#!/bin/bash -e

cd "$1" || exit 1

CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "dist" ]; then
    echo "Not on dist branch, skipping."
    exit 0
fi

KEEP_RECENT=9
TOTAL_COMMITS=$(git rev-list --count HEAD)

echo "Total commits: $TOTAL_COMMITS"

if [ "$TOTAL_COMMITS" -le 10 ]; then
    echo "No squash needed."
    exit 0
fi

SQUASH_COUNT=$((TOTAL_COMMITS - KEEP_RECENT))
echo "Squashing oldest $SQUASH_COUNT commits into 1, keeping recent $KEEP_RECENT"

GIT_SEQUENCE_EDITOR="sed -i '2,${SQUASH_COUNT}s/^pick/fixup/'" \
git rebase -i --root

echo "Done. Commits now: $(git rev-list --count HEAD)"
