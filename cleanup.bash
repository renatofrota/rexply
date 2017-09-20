#!/bin/bash
rm -fv rexply-data/.tmp/tmp
rm -fv rexply-data/.log/log
#touch rexply-data/.tmp/tmp
#touch rexply-data/.log/log
git update-index --skip-worktree rexply.cfg
