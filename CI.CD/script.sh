#!/bin/bash

# BRANCH_NAME is a default variable set by Jenkins
#    on Jenkins agents it's equal to the branch that's being built

set -ex

export AWS_DEFAULT_REGION=us-east-1

# define current stage based on branch name
if [[ $BRANCH_NAME == dev-* ]]
then
    current_stage=dev
elif [[ $BRANCH_NAME == main-* ]]
then
    current_stage=prod
elif [[ $BRANCH_NAME == stage-* ]]
then
    current_stage=stage
fi

if [[ $current_stage == dev ]] || [[ $current_stage == staging ]] || [[ $current_stage == prod ]]
then
    pushd ../
    make build stage=$current_stage
    make push stage=$current_stage
    popd
    pushd api/
fi

pushd ../
make deploy stage=$current_stage
popd
