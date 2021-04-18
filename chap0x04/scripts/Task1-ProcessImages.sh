#!/bin/bash
 
check_dependencies(){
    if [[ -z "$(convert -v 2>/dev/null)" ]];then
        echo "You haven't install ImageMagick"
    fi
}

describe() {
    cat << EOF
    Description:
        Use bash to write a picture batch script to realize the function 
        of processing pictures

    Usage:
        bash $0 [-q <dir> <Q>] [-r <dir> <R>] [-w <dir> <content> <position> <size> <transparent>] 
                [-p <dir> <prefix>] [-s <dir> <suffix>] [-t <dir>] 
    
    Author:
        Eddie Xu

    Options:
        -q      JPEG compression level.
        -r      Compress the jpeg/png/svg images with resolution of R    
        -w      Add transparent or solid watermark to the image
        -p      Add prefix to the origin name
        -s      Add suffix to the origin name
        -t      Transform png/svg images into jpg images
    
    Arguments:
        dir         The directory you want to process,input the target directory
        Q           The quality you want,input a number between 1-100
        R           The resolution you want to change,input a number between 1-100
        content     The content of watermark,input string
        position    The position of the watermark,you can input 'NorthWest, North, 
                    NorthEast, West, East, SouthWest, South, SouthEast'
        size        The size of watermark,you need to input a number
        transparent You can make your watermark transparent or not,input 'y' or 'n' 
        prefix      The prefix you want to add,input string
        suffix      The suffix you want to add,input string
    
EOF
}

CompressQuality(){
    Q=$2    
    for jpg in "$1"/* ;do  
        mgk_num=$(xxd  -p  -l  3  "$jpg" )
        if [[ "$mgk_num" == "ffd8ff" ]]; then
            convert -strip -interlace Plane -gaussian-blur 0.01 -quality "$Q" "$jpg" "$jpg"
            echo Quality of "${jpg}" is compressed into "$Q" 
        else
            echo "warn: $jpg is not a jpeg image "
        fi
    done
    exit 0 
}


CompressResolution(){
    R=$2
    for img in "$1"/* ;do
        mgk_num=$(xxd  -p  -l  3  "$img" )
        suffix=${img##*.}
        if [[ "$mgk_num" == "ffd8ff" || "$mgk_num" == "89504e" || "$suffix" == "svg" || "$suffix" == "SVG" ]]; then
            convert -resize "$R" "$img" "$img"
            echo Resolution of "${img}" is resized into "$R"
        else
            echo "warn: $img is not a jpeg/png/svg image"
        fi
    done
    exit 0
}


WaterMark(){
    content=$2
    position=$3
    size=$4
    if [[ $5 == 'y' ]]; then
        transparent=true
    elif [[ $5 == 'n' ]]; then
        transparent=false
    else    
        echo "You can only input y or n"
        exit 1
    fi
    if [[ $transparent ]]; then
        for img in "$1"/* ;do
            convert "${img}" -pointsize "$size" -fill 'rgba(221, 34, 17, 0.25)' -gravity "$position" -draw "text 10,10 '$content'" "${img}"
            echo "${img} is watermarked with $content."
        done
    else
        for img in "$1"/* ;do
            convert  -size 100x100  xc:none  \
            -fill '#d90f02'  -pointsize "$size"  -font 'cochin.ttc'  \
            -gravity "$position" -draw "rotate -45 text 0,0 '$content'"  \
            -resize 60%  miff:-  |  composite  -tile  -dissolve 25  -  "$img"  "$img"
            echo "${img} is watermarked with $content."
        done      
    fi
    exit 0
}

Prefix(){
    prefix=$2
    for img in "$1"/*; do
        name=${img##*/}
        new_name=$1"/"${prefix}${name}
        mv "${img}" "${new_name}"
    done
    exit 0
}

Suffix(){
    suffix=$2
    for img in "$1"/*; do
        type=${img##*.}
        new_name=${img%.*}${suffix}"."${type}
        mv "${img}" "${new_name}"
    done
    exit 0
}

Transform(){
    for img in "$1"/* ;do
        format="$(identify -format "%m" "$img")"
        suffix=${img##*.}
        if [[ "$format" == "PNG" || "$format" == "SVG" ]]; then
            new_img=${img%.*}".jpg"
            convert "${img}" "$new_img"
            echo "${img}" has transformed into "$new_img"
        fi
    done
    exit 0
}


[ $# -eq 0 ] && describe
while getopts 'q:r:w:p:s:t:h' OPT; do
    case $OPT in
        q)  
            CompressQuality "$2" "$3"
            ;;
        r)
            CompressResolution "$2" "$3"
            ;;
        w)  
            WaterMark "$2" "$3" "$4" "$5" "$6"
            ;;
        p)
            Prefix "$2" "$3"
            ;;
        s)
            Suffix "$2" "$3"
            ;;
        t)
            Transform "$2"
            ;;
        h | *) 
            describe 
            ;;

    esac
done
check_dependencies