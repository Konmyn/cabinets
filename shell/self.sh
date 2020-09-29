#!/usr/bin/env bash

echo "start process"

echo "$0 $@"

echo "call self"

# trick: this is the bash, not the script
/proc/self/exe

echo "end process"
