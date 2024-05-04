#!/bin/bash

#
# This script generates a JSON file containing information on all buyable items in the schema and plugins directories.
# It is used by the balancing tool in ../web
#
# 1.  Make sure this script is executable by running:
#     chmod +x generate_items.sh
#
# 2.  Run the script from the root of the project:
#     ./tools/generate-items-json.sh
#

OUTPUT_PATH=./web/assets/items.json
DIRECTORIES=(plugins schema)

echo "[" > "$OUTPUT_PATH"

add_to_json() {
    echo "  {\"name\": \"$1\", \"price\": $2, \"category\": \"$3\"}," >> "$OUTPUT_PATH"
}

for dir in "${DIRECTORIES[@]}"; do
    if [ -d "$dir" ]; then
        grep -r -H --include='*.lua' "ITEM.name =" "$dir" | while read -r name_line; do
            file=$(echo "$name_line" | cut -d: -f1)
            name=$(echo "$name_line" | sed -n "s/.*ITEM.name = \"\(.*\)\".*/\1/p")
            if [ -n "$name" ]; then
                price=$(grep "ITEM.price = " "$file" | sed -n "s/.*ITEM.price = \([0-9]*\).*/\1/p")
                if [ -n "$price" ]; then
                    category=$(grep "ITEM.category = " "$file" | sed -n "s/.*ITEM.category = \"\(.*\)\".*/\1/p")
                    weaponCategory=$(grep "ITEM.weaponCategory = " "$file" | sed -n "s/.*ITEM.weaponCategory = \"\(.*\)\".*/\1/p")

                    if [ -z "$category" ]; then
                        if [ -n "$weaponCategory" ]; then
                            category="Weapon: $weaponCategory"
                        else
                            category=$(echo "$file" | rev | cut -d'/' -f2 | rev)
                        fi
                    fi

                    add_to_json "$name" "$price" "$category"
                fi
            fi
        done
    fi
done

# Remove the last comma
sed -i '$ s/,$//' "$OUTPUT_PATH"

echo "]" >> "$OUTPUT_PATH"
