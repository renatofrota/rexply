#!/bin/bash
rm -f rexply-data/.tmp/tmp
rm -f rexply-data/.log/log
touch rexply-data/.tmp/tmp
touch rexply-data/.log/log
git update-index --skip-worktree rexply-data/.cfg/cfg
