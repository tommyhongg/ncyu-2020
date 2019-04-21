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
PROJECT_BRANCH=ex1

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

COMMIT_MSG="[Example 1] $GIT_NAME"

if ! [ -d .git ] || [ `git remote -v | wc -l ` -ne 0 ]; then
	echo "[ERROR] Initialize the new Git repository first."
	exit 1
fi

# update local and remote code base
git remote add origin $PROJECT_URL
git remote add official https://github.com/jrjang/ncyu-2020
git fetch -q --all
echo "[STATUS] Example 1: Git fetch done"

git checkout --detach

if [[ "`git branch`" =~ "$PROJECT_BRANCH" ]]; then
	git branch -D $PROJECT_BRANCH
fi

git checkout -b $PROJECT_BRANCH
git rebase official/$PROJECT_BRANCH

flag=

if [[ "`git show HEAD`" =~ "Signed-off-by:" ]]; then
	flag=-s
fi

git commit $flag -q --amend -m "$COMMIT_MSG"
echo "[STATUS] Example 1: Git commit amend done"

git push -f -q origin HEAD:refs/heads/$PROJECT_BRANCH
echo "[STATUS] Example 1: Git push done"

hub pull-request -b jrjang/ncyu-2020:$PROJECT_BRANCH -h $GITHUB_REPO:$PROJECT_BRANCH -m "$COMMIT_MSG"
echo "[STATUS] Example 1: Github pull requests done"

echo "[STATUS] Example 1: done"
