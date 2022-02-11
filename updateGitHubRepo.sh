#!/bin/bash
destination_base="/Users/krisdavey/repos/api/"
source_base="/Users/krisdavey/repos/lendio-infra/repositories/api/"
branch="SeederRound1"
message="Updating seeder script"
file1="app/Console/Commands/RefreshDatabase.php"
file2="config/database.php"
file3="database/seeds/DatabaseSeeder.php"

files=($file1 $file2 $file3)

cd $destination_base

git checkout $branch

git pull

for file in "${files[@]}"
do
   :
   echo "cp $source_base$file $destination_base$file"
done
