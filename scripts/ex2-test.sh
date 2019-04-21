#!/bin/bash

GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
GITHUB_ACCOUNT=$1
GITHUB_PROJECT=$2

for var in $@; do
	if [[ $var =~ "-h" ]]; then
		echo "Usage: $0 GITHUB_ACCOUNT GITHUB_PROJECT"
		echo ""
		echo "Parameters:"
		echo "GITHUB_ACCOUNT   Github account"
		echo "GITHUB_PROJECT   Project name on Github"

		exit 0
	fi
done

if [ "$GITHUB_ACCOUNT" == "" ] || [ "$GITHUB_PROJECT" == "" ]; then
	echo "[ERROR] Incorrect parameters. Please run below command to see help."
	echo "  $0 -h"
	exit 1
fi

if ! [[ "`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -T git@github.com 2>&1`" =~ "successfully authenticated" ]]; then
	echo "[ERROR] Check your SSH public key on github.com"
	exit 1
fi

GITHUB_REPO=$GITHUB_ACCOUNT/$GITHUB_PROJECT
PROJECT_URL=git@github.com:$GITHUB_REPO
PROJECT_BRANCH=ex2

GIT_NAME=`git config -l --show-scope | grep local | grep user.name`

if [ "$GIT_NAME" == "" ]; then
	GIT_NAME=`git config -l --show-scope | grep global | grep user.name`
fi

if [ "$GIT_NAME" != "" ]; then
	GIT_NAME=`echo $GIT_NAME | cut -d '=' -f 2`
else
	echo "[ERROR] Can not find user.name in git config"
	exit 1
fi

COMMIT_MSG="[Example 2] $GIT_NAME"

git fetch -q official $PROJECT_BRANCH
git reset --soft official/$PROJECT_BRANCH
git commit -s -q -m "$COMMIT_MSG"
echo "[STATUS] Example 2: Git commit amend done"

git push -f -q origin HEAD:refs/heads/$PROJECT_BRANCH
echo "[STATUS] Example 2: Git push done"

hub pull-request -b jrjang/ncyu-2020:$PROJECT_BRANCH -h $GITHUB_REPO:$PROJECT_BRANCH -m "$COMMIT_MSG"
echo "[STATUS] Example 2: Github pull requests done"

echo "[STATUS] Example 2: done"
