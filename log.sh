#!/usr/bin/env bash
# bikin catatan harian, commit, push
set -e
cd "$(dirname "$0")"

TODAY=$(date +%F)
DIR="logs/$(date +%Y)/$(date +%m)"
FILE="$DIR/$TODAY.md"
mkdir -p "$DIR"

if [ -n "$EDITOR" ]; then ED="$EDITOR"
elif command -v code >/dev/null 2>&1; then ED="code --wait"
else ED="nano"; fi

if [ ! -f "$FILE" ]; then
  DONE=$(find logs -name '*.md' 2>/dev/null | wc -l)
  TOTAL=$(wc -l < plan.txt)
  N=$(( DONE % TOTAL + 1 ))
  LINE=$(sed -n "${N}p" plan.txt)
  TOPIC=$(echo "$LINE" | cut -d'|' -f1 | xargs)
  TASK=$(echo "$LINE" | cut -d'|' -f2- | xargs)

  cat > "$FILE" << TPL
# $TODAY: $TOPIC

**Latihan hari ini:** $TASK

## Yang saya pelajari
-

## Error atau bingung yang ketemu
-

## Cara saya menyelesaikannya
-

## Besok mau coba
-
TPL
  cp "$FILE" "$FILE.orig"
  echo "Topik hari ini: $TOPIC"
fi

$ED "$FILE"

# belum diisi = jangan commit
if [ -f "$FILE.orig" ] && cmp -s "$FILE" "$FILE.orig"; then
  rm "$FILE.orig" "$FILE"
  echo "Catatan masih kosong. Isi dulu, baru jalankan lagi."
  exit 1
fi
rm -f "$FILE.orig"

TITLE=$(head -n1 "$FILE" | sed 's/^# //')
git add "$FILE"
git commit -m "log: $TITLE"
git push
echo "Beres, sudah ter-push."