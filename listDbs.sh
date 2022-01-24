#cat $HOME/.zshrc | grep 'mysql --' | awk -F = '{ print $1 }' | awk '{ print $2 }'
gsed -n '/mysql --/p' ~/.zshrc | gsed -re 's,\s+, ,g' | cut -d" " -f 2- | awk -F'[=#]' ' {print $1 " -> " $4}'
