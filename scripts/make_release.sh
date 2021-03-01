#!/bin/bash

set -e
set -u

ATL_GH_PATH=/tmp/atl-github

if [[ -d "${ATL_GH_PATH}" ]];
then
    pushd "${ATL_GH_PATH}"
    git pull origin master
    popd
else
    git clone git@github.com:ESEO-Tech/ATL-Tools-Library.git "${ATL_GH_PATH}"
fi

tag_name=$(git describe --tags)
# found on SO https://stackoverflow.com/a/26132640/4780219
tag_msg=$(git cat-file -p $(git rev-parse $(git tag -l | tail -n1)) | tail -n +6)

rsync --delete -a --exclude 'private' --exclude '.git' . "${ATL_GH_PATH}"

pushd "${ATL_GH_PATH}"

git add .
git commit -m "${tag_msg}"
git tag -a "${tag_name}" -m "${tag_msg}"

git push origin master
git push origin "${tag_name}"