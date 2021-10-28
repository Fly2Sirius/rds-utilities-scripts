source ~/repos/utilities/config/config
if [ -z ${1} ]; then echo "You need to speciify an input file... ";exit; fi
file=$1

database=$(echo $1 | cut -d. -f1)
sp=$(echo $1 | cut -d. -f2)


echo "Applying $file to $server (Database -> $database , StoredProc -> $sp)"


echo "Is this correct [y/n]:"

read proceed

if [ "$proceed" != "y" ]; then
  echo "You didn't say yes, goodbye"
  exit 123
fi

echo "Okay you agreed, here we go!!!!"

mysql --defaults-file=$mysqlconfig -Bn -h $server -P $port $database < $1