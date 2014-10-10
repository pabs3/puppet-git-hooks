#!/bin/bash

# This script expects $1 to be passed and for $1 to be the filesystem location
# to a json file for which it will run syntax checks against.

syntax_errors=0
error_msg=$(mktemp /tmp/error_msg_json-syntax.XXXXX)

if [ $2 ]; then
    module_path=$(echo $1 | sed -e 's|'$2'||')
else
    module_path=$1
fi

# Get list of new/modified manifest and template files to check (in git index)
# Check json file syntax
echo -e "\x1B[0;36mChecking json syntax for $module_path...\x1B[0m"
ruby -e "require 'json'; JSON.parse(File.read($1))" 2> $error_msg > /dev/null
if [ $? -ne 0 ]; then
    echo -en "\x1B[0;31m"
    cat $error_msg
    syntax_errors=`expr $syntax_errors + 1`
    echo -e "Error: json syntax error in $module_path (see above)\x1B[0m"
fi
rm -f $error_msg

if [ "$syntax_errors" -ne 0 ]; then
    echo -e "\x1B[0;31mError: $syntax_errors syntax error(s) found in json file.  Commit will be aborted.\x1B[0m"
    exit 1
fi

exit 0
