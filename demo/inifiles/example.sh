#!/bin/bash

source inifiles.sh

ini_eval user 'example.ini'

echo "User Name  : $user_name"
echo "User Email : $user_email"
