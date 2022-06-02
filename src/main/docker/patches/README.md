# Unofficial Cantaloupe Patches

This collection of unofficial Cantaloupe patches can be used to fix upstream issues for which official patches may be unavailable.

The naming scheme is `issue-{ISSUE_NUM}-{GIT_REVISION}.patch`, where:

- `{ISSUE_NUM}` is GitHub's identifier for the issue that the patch attempts to fix, such that a description of the issue may be found at https://github.com/cantaloupe-project/cantaloupe/issues/{ISSUE_NUM}
- `{GIT_REVISION}` is the recommended target Git revision, such that `git checkout {GIT_REVISION}` should be run before the patch is applied (although there may exist other revisions that the patch is compatible with)
