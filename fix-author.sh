#!/bin/bash
FILTER_BRANCH_SQUELCH_WARNING=1
git filter-branch -f --env-filter '
export GIT_AUTHOR_NAME="HaiMingQAQ"
export GIT_AUTHOR_EMAIL="HaiMingQAQ@users.noreply.github.com"
export GIT_COMMITTER_NAME="HaiMingQAQ"
export GIT_COMMITTER_EMAIL="HaiMingQAQ@users.noreply.github.com"
' HEAD
