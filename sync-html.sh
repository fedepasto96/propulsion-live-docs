#!/usr/bin/env bash
#
# sync-html.sh — Syncs all HTML files from the E4 Battery Planning shared drive
# to the local git repo and pushes changes to GitHub for GitHub Pages deployment.
#
# Usage:
#   ./sync-html.sh              # Sync all HTML files
#   ./sync-html.sh --dry-run    # Show what would change without committing
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR"
SRC_DIR="/h/Shared drives/ENG - Elios 3, payloads and accessories program/Harmony Project/03_Technical/03_08_Batteries/E4 Battery Project/01_Project Management/01_03_Planning"

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "[DRY RUN] Showing changes without committing."
fi

FOLDERS=(
    "Charger Suppliers"
    "Cost Evaluation Material"
    "Pack Assemblers"
    "project updates"
    "Regulatory"
    "Reports"
    "Supplier Engagement"
)

cd "$REPO_DIR"

CHANGED=0

for folder in "${FOLDERS[@]}"; do
    src_folder="$SRC_DIR/$folder"
    dst_folder="$REPO_DIR/$folder"

    mkdir -p "$dst_folder"

    if ls "$src_folder/"*.html 1>/dev/null 2>&1; then
        for src_file in "$src_folder/"*.html; do
            filename="$(basename "$src_file")"
            dst_file="$dst_folder/$filename"

            if [[ ! -f "$dst_file" ]] || ! cmp -s "$src_file" "$dst_file"; then
                if $DRY_RUN; then
                    echo "  [CHANGED] $folder/$filename"
                else
                    cp "$src_file" "$dst_file"
                    echo "  Updated: $folder/$filename"
                fi
                CHANGED=$((CHANGED + 1))
            fi
        done
    fi

    # Detect new HTML files in source that don't exist in any known folder
    if ls "$src_folder/"*.html 1>/dev/null 2>&1; then
        for src_file in "$src_folder/"*.html; do
            filename="$(basename "$src_file")"
            dst_file="$dst_folder/$filename"
            if [[ ! -f "$dst_file" ]] && ! $DRY_RUN; then
                cp "$src_file" "$dst_file"
                echo "  New file: $folder/$filename"
                CHANGED=$((CHANGED + 1))
            fi
        done
    fi
done

# Also check for new subfolders containing HTML
while IFS= read -r html_file; do
    rel_path="${html_file#"$SRC_DIR/"}"
    dst_file="$REPO_DIR/$rel_path"
    dst_dir="$(dirname "$dst_file")"

    if [[ ! -f "$dst_file" ]]; then
        if $DRY_RUN; then
            echo "  [NEW] $rel_path"
        else
            mkdir -p "$dst_dir"
            cp "$html_file" "$dst_file"
            echo "  New file: $rel_path"
        fi
        CHANGED=$((CHANGED + 1))
    fi
done < <(find "$SRC_DIR" -name "*.html" -not -path "*/.cursor/*" 2>/dev/null || true)

if [[ $CHANGED -eq 0 ]]; then
    echo "No changes detected. Everything is up to date."
    exit 0
fi

if $DRY_RUN; then
    echo ""
    echo "$CHANGED file(s) would be updated."
    exit 0
fi

echo ""
echo "$CHANGED file(s) updated. Committing and pushing..."

git add -A
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
git commit -m "$(cat <<EOF
Sync HTML documents — $TIMESTAMP

Auto-sync of $CHANGED modified file(s) from shared drive.
EOF
)"

git push origin main

echo ""
echo "Done. Changes pushed to GitHub. GitHub Pages will update shortly."
echo "View at: https://fedepasto-96.github.io/e4-battery-planning-docs/"
