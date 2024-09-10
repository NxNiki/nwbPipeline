#!/bin/bash
diskutil unmountDisk force /Users/XinNiuAdmin/HoffmanMount

rm -rf /Users/XinNiuAdmin/HoffmanMount
mkdir /Users/XinNiuAdmin/HoffmanMount
echo "Mounting Hoffman_Mount"

sshfs xinniu@hoffman2.idre.ucla.edu://u/project/ifried/ /Users/XinNiuAdmin/HoffmanMount -o allow_other,defer_permissions,volname=HoffmanMount
