#!/bin/bash
# script to push my handwritten notes to my gh repo

# to be safe
rclone sync gdrive:GoodNotes/ ~/Documents/gdrive

source="$HOME/Documents/gdrive"
dest="$HOME/Documents/uni/notes-ig"

# did not need to declare a fancy array for this but i've never used bash arrays before so i wanted to try !
declare -A notes
notes["$source/algebra/algebra ALGEBRA.pdf"]="secondo anno/algebra.pdf"
notes["$source/algebra/REFILE/algebra FORMULE.pdf"]="secondo anno/algebra formule.pdf"
notes["$source/algebra/REFILE/algebra ES SHEET.pdf"]="secondo anno/algebra es sheet.pdf"
#notes["$source/algebra/REFILE/'algebra DIMOSTRAZIONI'.pdf'"]="'secondo anno'/'algebra dimostrazioni'.pdf"
notes["$source/probabilità/probabilità appunti.pdf"]="secondo anno/calcolo delle probabilità.pdf"

for file in "${!notes[@]}"; do
    cp "$file" "$dest/${notes[$file]}" || { echo "$file failed"; exit 1; }
done

cd "$dest" && git fetch

if [[ $(git status --porcelain) ]]; then
    git add . && git commit -m "automatic sync" && git push
else
    echo "no changes in the notes!"
fi
    
