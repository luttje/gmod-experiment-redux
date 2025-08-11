#!/bin/bash

# This script updates the content addon on workshop with gmpublish.
# This script is only intended to be run on Windows, by luttje (or someone else with contributor access to the workshop).
#
# 1.    Ensure you have the path to the garrysmod bin directory setup in the .env file.
#
# 2.    Make this script executable:
#       chmod +x ./update-workshop-content.sh
#
# 3.    Run this script with the update message as the first argument, e.g:
#       ./update-workshop-content.sh "Updated materials and models"
#
# Add --dry-run flag to see what commands would be executed without running them:
#       ./update-workshop-content.sh "Updated materials and models" --dry-run

SCRIPT_BASEDIR=$(dirname "$0")
CONFIG_FILE="$SCRIPT_BASEDIR/.env"

# File extensions to exclude from copying to server content (because they aren't on the gmpublish allowlist)
EXCLUDED_EXTENSIONS=(
    ".sw.vtx"
    ".pdn"
    ".blend"
    ".blend1"
    ".qc"
    ".smd"
    ".txt"
    ".md"
    ".tga"
    ".woff"
)

# Check for dry-run flag
DRY_RUN=false
if [[ "$*" == *"--dry-run"* ]]; then
    DRY_RUN=true
    echo "DRY RUN MODE - Publish command will not be executed"
    echo "==================================================="
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found at $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

if [ -z "$GM_BIN_PATH" ]; then
    echo "Error: Garry's Mod bin path (GM_BIN_PATH) not found in $CONFIG_FILE"
    exit 1
fi

WORKSHOP_ID="3546782165"
SOURCE_CONTENT_DIR="$SCRIPT_BASEDIR/../content"
WORKSHOP_CONTENT_DIR="$SCRIPT_BASEDIR/../workshop-addons/content"

# Remove --dry-run from arguments to get the actual message
ARGS=("$@")
FILTERED_ARGS=()
for arg in "${ARGS[@]}"; do
    if [[ "$arg" != "--dry-run" ]]; then
        FILTERED_ARGS+=("$arg")
    fi
done

if [ ${#FILTERED_ARGS[@]} -eq 0 ]; then
    echo "Error: Update message required as first argument"
    exit 1
fi

UPDATE_MESSAGE="${FILTERED_ARGS[0]}"

# Check if source content directory exists
if [ ! -d "$SOURCE_CONTENT_DIR" ]; then
    echo "Error: Source content directory not found at $SOURCE_CONTENT_DIR"
    exit 1
fi

# Check if workshop content directory exists
if [ ! -d "$WORKSHOP_CONTENT_DIR" ]; then
    echo "Error: Workshop content directory not found at $WORKSHOP_CONTENT_DIR"
    exit 1
fi

# Build find exclusion patterns - much more efficient than post-processing
build_find_exclusions() {
    local exclusions=""

    # Exclude by extension
    for ext in "${EXCLUDED_EXTENSIONS[@]}"; do
        exclusions+=" -not -name '*$ext'"
    done

    # Exclude source_files directories
    exclusions+=" -not -path '*/source_files/*'"

    echo "$exclusions"
}

# Optimized function to copy folder with file filtering using rsync-like approach
copy_folder_filtered_fast() {
    local source_folder="$1"
    local dest_folder="$2"
    local folder_name="$3"

    echo "Copying $folder_name folder (excluding specified file types)..."

    # Create destination directory
    mkdir -p "$dest_folder"

    # Build exclusion patterns for find
    local find_exclusions=$(build_find_exclusions)

    # Use find with built-in exclusions and xargs for bulk operations
    eval "find '$source_folder' -type f $find_exclusions -print0" | \
    while IFS= read -r -d '' file; do
        # Get relative path from source folder
        relative_path="${file#$source_folder/}"
        dest_file="$dest_folder/$relative_path"

        # Create destination directory if it doesn't exist
        dest_dir=$(dirname "$dest_file")
        mkdir -p "$dest_dir"

        # Copy the file
        cp "$file" "$dest_file"
    done
}

# Even faster version using rsync if available
copy_folder_filtered_rsync() {
    local source_folder="$1"
    local dest_folder="$2"
    local folder_name="$3"

    echo "Copying $folder_name folder using rsync (excluding specified file types)..."

    # Build rsync exclusion patterns
    local rsync_exclusions=""
    for ext in "${EXCLUDED_EXTENSIONS[@]}"; do
        rsync_exclusions+=" --exclude=*$ext"
    done
    rsync_exclusions+=" --exclude=source_files/"

    # Create destination parent directory
    mkdir -p "$(dirname "$dest_folder")"

    # Use rsync for efficient copying with exclusions
    eval "rsync -av '$source_folder/' '$dest_folder/' $rsync_exclusions"
}

# Alternative super-fast version using tar with exclusions
copy_folder_filtered_tar() {
    local source_folder="$1"
    local dest_folder="$2"
    local folder_name="$3"

    echo "Copying $folder_name folder using tar (excluding specified file types)..."

    # Build tar exclusion patterns
    local tar_exclusions=""
    for ext in "${EXCLUDED_EXTENSIONS[@]}"; do
        tar_exclusions+=" --exclude=*$ext"
    done
    tar_exclusions+=" --exclude=source_files"

    # Create destination directory
    mkdir -p "$dest_folder"

    # Use tar for very fast copying with exclusions
    eval "tar -C '$source_folder' $tar_exclusions -cf - . | tar -C '$dest_folder' -xf -"
}

# Choose the best available copy method
choose_copy_method() {
    if command -v rsync >/dev/null 2>&1; then
        echo "rsync"
    elif command -v tar >/dev/null 2>&1; then
        echo "tar"
    else
        echo "find"
    fi
}

# Define folders to sync
FOLDERS_TO_SYNC=("materials" "models" "particles" "sound" "resource")

echo "Cleaning and updating content folders..."
echo "========================================"
echo "Excluded file extensions: ${EXCLUDED_EXTENSIONS[*]}"

# Detect best copy method
COPY_METHOD=$(choose_copy_method)
echo "Using copy method: $COPY_METHOD"
echo ""

# Clean existing folders in workshop directory efficiently
echo "Cleaning existing folders..."
for folder in "${FOLDERS_TO_SYNC[@]}"; do
    if [ -d "$WORKSHOP_CONTENT_DIR/$folder" ]; then
        rm -rf "$WORKSHOP_CONTENT_DIR/$folder"
    fi
done

echo ""

# Copy folders from source to workshop directory with filtering
for folder in "${FOLDERS_TO_SYNC[@]}"; do
    if [ -d "$SOURCE_CONTENT_DIR/$folder" ]; then
        case $COPY_METHOD in
            "rsync")
                copy_folder_filtered_rsync "$SOURCE_CONTENT_DIR/$folder" "$WORKSHOP_CONTENT_DIR/$folder" "$folder"
                ;;
            "tar")
                copy_folder_filtered_tar "$SOURCE_CONTENT_DIR/$folder" "$WORKSHOP_CONTENT_DIR/$folder" "$folder"
                ;;
            *)
                copy_folder_filtered_fast "$SOURCE_CONTENT_DIR/$folder" "$WORKSHOP_CONTENT_DIR/$folder" "$folder"
                ;;
        esac
    else
        echo "Warning: Source folder $folder not found, skipping..."
    fi
done

echo ""
echo "Content sync completed."

# Create the GMA file
echo ""
echo "Creating GMA file..."
"$GM_BIN_PATH/gmad.exe" create -folder "$WORKSHOP_CONTENT_DIR" -out "$WORKSHOP_CONTENT_DIR/../content.gma"

if [ "$DRY_RUN" = true ]; then
    echo ""
    echo "DRY RUN MODE - The following publish command would be executed:"
    echo "============================================================="
    echo "Publish to workshop:"
    echo "   \"$GM_BIN_PATH/gmpublish.exe\" update -id \"$WORKSHOP_ID\" -addon \"$WORKSHOP_CONTENT_DIR/../content.gma\" -changes \"$UPDATE_MESSAGE\""
    echo ""
    echo "DRY RUN COMPLETE - GMA file created but not published"
else
    # Publish the GMA file to the workshop
    echo "Publishing to workshop..."
    "$GM_BIN_PATH/gmpublish.exe" update -id "$WORKSHOP_ID" -addon "$WORKSHOP_CONTENT_DIR/../content.gma" -changes "$UPDATE_MESSAGE"
    echo "Workshop content update completed!"
fi
