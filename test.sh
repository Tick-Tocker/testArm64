#!/bin/bash

test(){

TYPE=$1
    if [ -z "${TYPE}" ]; then
	    echo "11111111111111111111111111111111111111111111"
        return
    elif [ "${TYPE}" == "-google-vrp" ]; then
	    echo "type is ${TYPE}"
    else
	    echo 444444444444444444444444
    fi

    echo 99999999999999999999999999999999

}

test "-google-vrp"

test "xxxxxxxxxxxxx"


echo 22222222222222222


