#!/bin/bash
function cal_gcd(){
    m=$1
    if [[ $2 -lt $m ]]; then
    m=$2
    fi
    while [[ $m -ne 0 ]]; do
        x=$($1 % "$m")
        y=$($2 % "$m")
        if [[ $x -eq 0 && $y -eq 0 ]];then
            echo "gcd of $1 and $2 is $m"
            break
    fi
    m=$($m - 1)
    done
}

if [[ "$#" -ne 2 ]];then
    echo "The number of input must be 2"
# elif [[ false ]];then
#     echo ""
else 
    cal_gcd "$1" "$2"
fi

