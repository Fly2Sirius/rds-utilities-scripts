sed -n '/mysql --/p' ~/.zshrc | sed -re 's,\s+, ,g' | cut -d" " -f 2- | awk -F'[=#]' ' {print $1} ' | expand -t 18
