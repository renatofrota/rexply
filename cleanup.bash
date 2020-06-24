#!/bin/bash
rm -fv rexply-data/.tmp/tmp
rm -fv rexply-data/.log/log
git update-index --skip-worktree rexply.cfg
