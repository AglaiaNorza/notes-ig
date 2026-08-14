#!/bin/bash
# script to push my handwritten notes to my gh repo
drive="$HOME/Documents/gdrive"
latex="$HOME/Documents/BSc/latex"
dest="$HOME/Documents/BSc/notes-ig"

declare -A notes

hname="PC"

if [ "$(uname -n )" = "aglaia-otg" ]; then
    hname="portatile"
elif ! mount | grep "gdrive" > /dev/null; then
    echo "mounting drive"
    rclone mount --daemon gdrive:GoodNotes/ ~/Documents/gdrive
    notes["$drive/automi/automi.pdf"]="y3/automi, calcolabilità e complessità.pdf"
else
    echo "drive is mounted"
    notes["$drive/automi/automi.pdf"]="y3/automi, calcolabilità e complessità.pdf"
fi

# did not need to declare a fancy array for this but i've never used bash arrays before so i wanted to try !
#notes["$drive/algebra/algebra ALGEBRA.pdf"]="y2/algebra.pdf"
#notes["$drive/algebra/REFILE/algebra FORMULE.pdf"]="y2/algebra formule.pdf"
#notes["$drive/algebra/REFILE/algebra ES SHEET.pdf"]="y2/algebra es sheet.pdf"
#notes["$drive/algebra/REFILE/algebra DIMOSTRAZIONI.pdf"]=y2/algebra dimostrazioni.pdf"
#notes["$drive/probabilità/probabilità appunti.pdf"]="y2/calcolo delle probabilità.pdf"

notes["$latex/logmat/logmat.pdf"]="y3/logica matematica.pdf"
notes["$latex/ldp/ldp.pdf"]="y3/linguaggi di programmazione.pdf"
notes["$latex/ia/ia.pdf"]="y3/intelligenza artificiale.pdf"
notes["$latex/tpfi/tpfi.pdf"]="y3/tpfi.pdf"

notes["$latex/logmat/logmat.tex"]="y3/tex/logica matematica.tex"
notes["$latex/ldp/ldp.tex"]="y3/tex/linguaggi di programmazione.tex"
notes["$latex/ia/ia.tex"]="y3/tex/intelligenza artificiale.tex"
notes["$latex/tpfi/tpfi.tex"]="y3/tex/tpfi/tpfi.tex"
notes["$latex/tpfi/1-le-basi.tex"]="y3/tex/tpfi/1-le-basi.tex"
notes["$latex/tpfi/2-lambda-calcolo.tex"]="y3/tex/tpfi/2-lambda-calcolo.tex"
notes["$latex/tpfi/3-tipi.tex"]="y3/tex/tpfi/3-tipi.tex"
notes["$latex/tpfi/4-temi-avanzati.tex"]="y3/tex/tpfi/4-temi-avanzati.tex"

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


