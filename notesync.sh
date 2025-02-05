#!/bin/bash
# script to push my handwritten notes to my gh repo

source="$HOME/Documents/gdrive"
dest="$HOME/Documents/uni/notes-ig"

if ! mount | grep "gdrive" > /dev/null; then
    rclone mount --daemon gdrive:GoodNotes/ ~/Documents/gdrive
fi

# did not need to declare a fancy array for this but i've never used bash arrays before so i wanted to try !
declare -A notes
notes["$source/algebra/algebra ALGEBRA.pdf"]="secondo anno/algebra.pdf"
notes["$source/algebra/REFILE/algebra FORMULE.pdf"]="secondo anno/algebra formule.pdf"
notes["$source/algebra/REFILE/algebra ES SHEET.pdf"]="secondo anno/algebra es sheet.pdf"
#notes["$source/algebra/REFILE/algebra DIMOSTRAZIONI.pdf"]=secondo anno/algebra dimostrazioni.pdf"
notes["$source/probabilità/probabilità appunti.pdf"]="secondo anno/calcolo delle probabilità.pdf"

for file in "${!notes[@]}"; do
    cp "$file" "$dest/${notes[$file]}" || { echo "$file failed"; exit 1; }
done

cd "$dest" && git pull

if [ $? -eq 0 ] && [[ $(git status --porcelain) ]]; then
    git add . && git commit -m "sync: $(date +'%d-%m')" && git push
else
    echo "no changes in the notes!"
fi
    
