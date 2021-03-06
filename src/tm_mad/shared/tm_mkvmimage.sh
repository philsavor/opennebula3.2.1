#!/bin/bash

# -------------------------------------------------------------------------- #
# Copyright 2002-2012, OpenNebula Project Leads (OpenNebula.org)             #
#                                                                            #
# Licensed under the Apache License, Version 2.0 (the "License"); you may    #
# not use this file except in compliance with the License. You may obtain    #
# a copy of the License at                                                   #
#                                                                            #
# http://www.apache.org/licenses/LICENSE-2.0                                 #
#                                                                            #
# Unless required by applicable law or agreed to in writing, software        #
# distributed under the License is distributed on an "AS IS" BASIS,          #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
# See the License for the specific language governing permissions and        #
# limitations under the License.                                             #
#--------------------------------------------------------------------------- #

SRC=$1
DST=$2
ONE_LOCATION="/opt/nebula/ONE"
if [ -z "${ONE_LOCATION}" ]; then
    TMCOMMON=/usr/lib/one/mads/tm_common.sh
    VAR_LOCATION=/var/lib/one/
else
    TMCOMMON=$ONE_LOCATION/lib/mads/tm_common.sh
    VAR_LOCATION=$ONE_LOCATION/var/
fi
. $TMCOMMON

get_vmdir

SRC_PATH=`arg_path $SRC`
DST_PATH=`arg_path $DST`

#add by gaojp
SRC_PATH=`arg_path $SRC_PATH`
DST_PATH=`arg_path $DST_PATH`


DST_DIR=`dirname $DST_PATH`

fix_paths

if [ "$SRC_PATH" == "$DST_PATH" ]; then
    log "Will not move, source and destination are equal"
else
    if [ -d "$SRC_PATH" ]; then
        log "Will not move, is not saving image"
    else
        log "Moving $SRC_PATH"
        echo "mkdir -p $DST_DIR"
        echo "cp -r $SRC_PATH $DST_PATH"
        #exec_and_log "mkdir -p $DST_DIR"
        #exec_and_log "cp -r $SRC_PATH $DST_PATH"
    fi
fi

