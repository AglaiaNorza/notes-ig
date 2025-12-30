#!/bin/bash
# script to push my handwritten notes to my gh repo
drive="$HOME/Documents/gdrive"
latex="$HOME/Documents/uni/latex"
dest="$HOME/Documents/uni/notes-ig"

declare -A notes

hname="PC"

if [ "$(uname -n )" = "aglaia-otg" ]; then
    hname="portatile"
elif ! mount | grep "gdrive" > /dev/null; then
    echo "mounting drive"
    rclone mount --daemon gdrive:GoodNotes/ ~/Documents/gdrive
    notes["$drive/automi/automi.pdf"]="terzo anno/automi, calcolabilità e complessità.pdf"
else
    echo "drive is mounted"
    notes["$drive/automi/automi.pdf"]="terzo anno/automi, calcolabilità e complessità.pdf"
fi

# did not need to declare a fancy array for this but i've never used bash arrays before so i wanted to try !
#notes["$drive/algebra/algebra ALGEBRA.pdf"]="secondo anno/algebra.pdf"
#notes["$drive/algebra/REFILE/algebra FORMULE.pdf"]="secondo anno/algebra formule.pdf"
#notes["$drive/algebra/REFILE/algebra ES SHEET.pdf"]="secondo anno/algebra es sheet.pdf"
#notes["$drive/algebra/REFILE/algebra DIMOSTRAZIONI.pdf"]=secondo anno/algebra dimostrazioni.pdf"
#notes["$drive/probabilità/probabilità appunti.pdf"]="secondo anno/calcolo delle probabilità.pdf"

notes["$latex/logmat/logmat.pdf"]="terzo anno/logica matematica.pdf"
notes["$latex/ldp/ldp.pdf"]="terzo anno/linguaggi di programmmazione.pdf"

notes["$latex/logmat/logmat.tex"]="terzo anno/tex/logica matematica.tex"
notes["$latex/ldp/ldp.tex"]="terzo anno/tex/linguaggi di programmmazione.tex"

for file in "${!notes[@]}"; do
    cp "$file" "$dest/${notes[$file]}" || { echo "$file failed"; exit 1; }
done

echo "updating notes repo"

cd "$dest" && git pull

if [ $? -eq 0 ] && [[ $(git status --porcelain) ]]; then

    # while read -r reads line by line from stdin and stores in 'f'
    # basename strips
    # paste -sd ',' - pastes lines with ',' delimiter
    # (just having fun w/bash)
    #pdf_list=$(git diff --name-only -- '*.pdf' | while read -r f; do
    #    basename "$f" .pdf
    #done | paste -sd '/' -)

    pdf_list=$(git -c core.quotepath=false diff --name-only -- '*.pdf' | while read -r f; do
    basename "$f" .pdf
done | paste -sd '/' -)

git add . && git commit -m "sync $(date +'%d-%m'): $pdf_list [$hname]" && git push
else
    echo "no changes in the notes!"
fi

echo "updating latex repo"

cd "$latex" && git pull

if [ $? -eq 0 ] && [[ $(git status --porcelain) ]]; then
    git add . && git commit -m "sync: $(date +'%d-%m'), $hname, $pdf_list" && git push
else
    echo "no changes in the .tex files!"
fi


