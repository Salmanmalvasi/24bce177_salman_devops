#!/bin/bash
# Create submission ZIP for salman malvasi (24bce1277)

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
ZIP_NAME="24bce1277_salman_malvasi_DevOps_Project.zip"

cd "$PROJECT_DIR/.."
zip -r "$ZIP_NAME" "$(basename "$PROJECT_DIR")" \
  -x "*.git*" \
  -x "*__pycache__*" \
  -x "*.DS_Store"

echo "Created: $(pwd)/$ZIP_NAME"
