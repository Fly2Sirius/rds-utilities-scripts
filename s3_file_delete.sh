s3bucket="s3://lendio-lake-bi-output"
s3dirpath="s3://lendio-lake-bi-output/"
aws s3 ls $s3dirpath --recursive | while read -r line;
    do
     createDate=`echo $line|awk {'print $1" "$2'}`
     createDate=`gdate -d"$createDate" +%s`
     olderThan=`gdate --date "2 days ago" +%s`
     if [[ $createDate -lt $olderThan ]]
        then
         fileName=`echo $line|awk '{a="";for (i=4;i<=NF;i++){a=a" "$i}print a}' |awk '{ sub(/^[ \t]+/, ""); print }'`

         if [[ $fileName != "" ]]
         then
                 echo "$s3bucket/$fileName"
                 aws s3 rm "$s3bucket/$fileName"
         fi
    fi

    done;
