#!/bin/bash

# The following vars are stored encrypted in TravisCI
# JENKINS_USER
# JENKINS_USER_PASS
# JENKINS_URL: Contains Token

if [[ $TRAVIS_BRANCH == 'master' && $TRAVIS_PULL_REQUEST == 'false' && $CANTALOUPE_VERSION == 'stable' ]]; then
  curl -I -u "${JENKINS_USER}:${JENKINS_USER_PASS}" "${JENKINS_URL}&GIT_COMMIT_HASH=${TRAVIS_COMMIT}"
fi

