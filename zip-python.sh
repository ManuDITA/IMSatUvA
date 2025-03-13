#!/bin/bash

PARENT_DIR="./lambdas"
MODULES_DIR="${PARENT_DIR}/modules"

for LAMBDA_DIR in "$PARENT_DIR"/*/; do
    # Create the requirements.txt file
    pip freeze > "${LAMBDA_DIR}/requirements.txt"
    echo "requirements.txt created in $LAMBDA_DIR"
    # Get the function name from the directory name
    FUNCTION_NAME="$(basename "$LAMBDA_DIR")"
    ZIP_FILE="${LAMBDA_DIR}/${FUNCTION_NAME}.zip"

    # Remove the old zip file if it exists
    if [ -f "$ZIP_FILE" ]; then
        rm "$ZIP_FILE"
    fi

    # Create a new zip file containing all Python files in the directory
    zip -r "$ZIP_FILE" "${LAMBDA_DIR}"*.py "$MODULES_DIR"

    echo "Lambda function '${FUNCTION_NAME}' zipped to: $ZIP_FILE"
done
