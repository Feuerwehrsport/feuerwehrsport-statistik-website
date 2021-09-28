#!/bin/bash

for_directory() 
{
  temp_file=/tmp/$RANDOM.tmp
  touch $temp_file
  for file in $(find $1/ -type f -name "*.rb") ; do 
    length=${#1}-${#2}
    if ! test -f "spec/${file:length:(-3)}_spec.rb" ; then 
      echo $file >> $temp_file
    fi
  done

  if [[ $(cat $temp_file | wc -l) -ge 1 ]] ; then
    echo "Directory: $1"
    echo ""
    cat $temp_file
    echo ""
  else
    echo "Directory: $1 -> OK"
  fi
  rm $temp_file
}

for_directory "lib" "lib"
for_directory "app/controllers" "controllers"
for_directory "app/models" "models"
for_directory "app/helpers" "helpers"
for_directory "app/mailers" "mailers"
for_directory "app/serializers" "serializers"
for_directory "app/uploaders" "uploaders"
