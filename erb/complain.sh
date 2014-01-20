
if [ "$#" -lt 2 ] ; then
  echo "Usage : ./complain.sh currentFileName newFileName"
fi

TMP_OUT=`mktemp /tmp/complain.XXX`

echo "Begin rename : $1 to $2"

for dir in include/*; do
  if [ -d "$dir"  ] ; then
    if [ `basename $dir` = "templates" ] ; then
      for file in $dir/*; do
        if [ -f "$file" ] ; then
          echo "rename $1 to $2 in $file"
          sed -e "s/$1/$2/g" $file > $TMP_OUT; cp $TMP_OUT $file
        fi
      done
    elif [ -f "$dir/references/$1" ] ; then
      echo "move $dir/references/$1 to $dir/references/$2"
      git mv $dir/references/$1 $dir/references/$2 || mv $dir/references/$1 $dir/references/$2
    fi
  fi
done

rm $TMP_OUT
