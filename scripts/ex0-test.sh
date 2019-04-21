#!/bin/bash

GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
GITHUB_ACCOUNT=$1
GITHUB_PROJECT=$2
CHINESE_NAME=$3

for var in $@; do
	if [[ $var =~ "-h" ]]; then
		echo "Usage: $0 GITHUB_ACCOUNT GITHUB_PROJECT CHINESE_NAME"
		echo ""
		echo "Parameters:"
		echo "GITHUB_ACCOUNT   Github account"
		echo "GITHUB_PROJECT   Project name on Github"
		echo "CHINESE_NAME     Your chinese name"

		exit 0
	fi
done

if [ "$GITHUB_ACCOUNT" == "" ] || [ "$GITHUB_PROJECT" == "" ] || [ "$CHINESE_NAME" == "" ]; then
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
PROJECT_BRANCH=ex0

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

GIT_EMAIL=`git config -l --show-scope | grep local | grep user.email`

if [ "$GIT_EMAIL" == "" ]; then
	GIT_EMAIL=`git config -l --show-scope | grep global | grep user.email`
fi

if [ "$GIT_EMAIL" != "" ]; then
	GIT_EMAIL=`echo $GIT_EMAIL | cut -d '=' -f 2`
else
	echo "[ERROR] Can not find user.email in git config"
	exit 1
fi

COMMIT_MSG="[Example 0] $GIT_NAME"

if [ -d $GITHUB_PROJECT ]; then
	echo "[ERROR] $GITHUB_PROJECT exists. Remove it first. "
	exit 1
fi

git clone https://github.com/jrjang/ncyu-2020 -b $PROJECT_BRANCH $GITHUB_PROJECT
pushd $GITHUB_PROJECT
hub fork
echo "[STATUS] Example 0: Github fork done"
popd

rm -rf $GITHUB_PROJECT
git clone $PROJECT_URL -b $PROJECT_BRANCH
cd $GITHUB_PROJECT
git remote add official https://github.com/jrjang/ncyu-2020
git fetch -q official
echo "[STATUS] Example 0: Re-clone repository done"

git checkout --detach official/ex0
echo "${CHINESE_NAME::1}◯${CHINESE_NAME: -1},$GIT_NAME,$GIT_EMAIL" | base64 >> ex0.txt
git add ex0.txt
echo "[STATUS] Example 0: Git add done"

git commit -s -m "$COMMIT_MSG"
echo "[STATUS] Example 0: Git commit done"

git push -f -q origin HEAD:refs/heads/$PROJECT_BRANCH
echo "[STATUS] Example 0: Git push done"

hub pull-request -b jrjang/ncyu-2020:$PROJECT_BRANCH -h $GITHUB_REPO:$PROJECT_BRANCH -m "$COMMIT_MSG"
echo "[STATUS] Example 0: Github pull requests done"

echo "[STATUS] Example 0: done"
