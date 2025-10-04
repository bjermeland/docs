#!/bin/bash

echo "=== Validating MDX files ==="
echo ""

# Check frontmatter exists
echo "Checking frontmatter..."
for file in $(find . -name "*.mdx" -not -path "./node_modules/*" -not -path "./.git/*"); do
  if ! head -1 "$file" | grep -q "^---"; then
    echo "❌ Missing frontmatter: $file"
  fi
done

# Check for unclosed tags
echo ""
echo "Checking for unclosed tags..."
for file in $(find . -name "*.mdx" -not -path "./node_modules/*" -not -path "./.git/*"); do
  # Count opening and closing tags
  open_card=$(grep -o "<Card" "$file" | wc -l)
  close_card=$(grep -o "</Card>" "$file" | wc -l)

  open_cardgroup=$(grep -o "<CardGroup" "$file" | wc -l)
  close_cardgroup=$(grep -o "</CardGroup>" "$file" | wc -l)

  open_accordion=$(grep -o "<Accordion" "$file" | wc -l)
  close_accordion=$(grep -o "</Accordion>" "$file" | wc -l)

  if [ "$open_card" != "$close_card" ]; then
    echo "❌ Unclosed Card tags in $file (open: $open_card, close: $close_card)"
  fi

  if [ "$open_cardgroup" != "$close_cardgroup" ]; then
    echo "❌ Unclosed CardGroup tags in $file (open: $open_cardgroup, close: $close_cardgroup)"
  fi

  if [ "$open_accordion" != "$close_accordion" ]; then
    echo "❌ Unclosed Accordion tags in $file (open: $open_accordion, close: $close_accordion)"
  fi
done

# Check for invalid internal links
echo ""
echo "Checking internal links..."
NAV_FILES=$(cat docs.json | jq -r '.. | .pages? // empty | .[]')

for file in $(find . -name "*.mdx" -not -path "./node_modules/*" -not -path "./.git/*"); do
  # Extract internal links
  grep -o 'href="/[^"]*"' "$file" | grep -v 'https://' | grep -v 'mailto:' | while read -r line; do
    href=$(echo "$line" | sed 's/href="\/\(.*\)"/\1/')

    # Check if href exists in navigation
    if ! echo "$NAV_FILES" | grep -q "^${href}$"; then
      # Allow certain paths
      if [[ ! "$href" =~ ^api-reference/(websocket|introduction)$ ]]; then
        echo "⚠️  Potential broken link in $file: $line"
      fi
    fi
  done
done

echo ""
echo "✅ Validation complete!"
