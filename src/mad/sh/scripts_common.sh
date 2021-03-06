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

# Paths for utilities
export PATH=/bin:/sbin:/usr/bin:$PATH
AWK=awk
BASH=bash
CUT=cut
DATE=date
DD=dd
DU=du
LVCREATE=lvcreate
LVREMOVE=lvremove
LVS=lvs
MD5SUM=md5sum
MKFS=/sbin/mkfs
MKISOFS=mkisofs
MKSWAP=mkswap
SCP=scp
SED=sed
SSH=ssh
SUDO=sudo
WGET=wget
READLINK=readlink

# Used for log messages
SCRIPT_NAME=`basename $0`

# Formats date for logs
function log_date
{
    $DATE +"%a %b %d %T %Y"
}

# Logs a message, alias to log_info
function log
{
    log_info "$1"
}

# Log function that knows how to deal with severities and adds the
# script name
function log_function
{
    echo "$1: $SCRIPT_NAME: $2" 1>&2
}

# Logs an info message
function log_info
{
    log_function "INFO" "$1"
}

# Logs an error message
function log_error
{
    log_function "ERROR" "$1"
}

# Logs a debug message
function log_debug
{
    log_function "DEBUG" "$1"
}

# This function is used to pass error message to the mad
function error_message
{
    (
        echo "ERROR MESSAGE --8<------"
        echo "$1"
        echo "ERROR MESSAGE ------>8--"
    ) 1>&2
}

# Executes a command, if it fails returns error message and exits
# If a second parameter is present it is used as the error message when
# the command fails
function exec_and_log
{
    message=$2
    output=`$1 2>&1 1>/dev/null`
    code=$?
    if [ "x$code" != "x0" ]; then
        log_error "Command \"$1\" failed."
        log_error "$output"
        if [ -z "$message" ]; then
            error_message "$output"
        else
            error_message "$message"
        fi
        exit $code
    fi
    log "Executed \"$1\"."
}

########################################add by gaozh for oNest begin##########################################################
# Executes a command, if it fails returns error message and not exits
# If a second parameter is present it is used as the error message when
# the command fails
function exec_and_log_unexit
{
    message=$2
    output=`$1 2>&1 1>/dev/null`
    code=$?
    if [ "x$code" != "x0" ]; then
        log_error "Command \"$1\" failed."
        log_error "$output"
        if [ -z "$message" ]; then
            error_message "$output"
        else
            error_message "$message"
        fi
    fi
    log "Executed \"$1\"."
    echo $code
}
########################################add by gaozh for oNest end###########################################################


# Like exec_and_log but the first argument is the number of seconds
# before here is timeout and kills the command
#
# NOTE: if the command is killed because a timeout the exit code
# will be 143 = 128+15 (SIGHUP)
function timeout_exec_and_log
{
    TIMEOUT=$1
    shift

    CMD="$1"

    exec_and_log "$CMD" &
    CMD_PID=$!

    # timeout process
    (
        sleep $TIMEOUT
        kill $CMD_PID 2>/dev/null
        log_error "Timeout executing $CMD"
        error_message "Timeout executing $CMD"
        exit -1
    ) &
    TIMEOUT_PID=$!

    # stops the execution until the command finalizes
    wait $CMD_PID 2>/dev/null
    CMD_CODE=$?

    # if the script reaches here the command finished before it
    # consumes timeout seconds so we can kill timeout process
    kill $TIMEOUT_PID 2>/dev/null 1>/dev/null
    wait $TIMEOUT_PID 2>/dev/null

    # checks the exit code of the command and exits if it is not 0
    if [ "x$CMD_CODE" != "x0" ]; then
        exit $CMD_CODE
    fi
}

# This function will return a command that upon execution will format a
# filesystem with its proper parameters based on the filesystem type
function mkfs_command {
    DST=$1
    FSTYPE=${2:-ext3}

    # Specific options for different FS
    case "$FSTYPE" in
        "ext2"|"ext3"|"ext4"|"ntfs")
            OPTS="-F"
            ;;

        "reiserfs")
            OPTS="-f -q"
            ;;

        "jfs")
            OPTS="-q"
            ;;
        *)
            OPTS=""
            ;;
    esac

    echo "$MKFS -t $FSTYPE $OPTS $DST"
}
