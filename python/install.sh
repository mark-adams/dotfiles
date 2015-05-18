#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

sudo pip install -r "$DIR/requirements.txt" --upgrade
