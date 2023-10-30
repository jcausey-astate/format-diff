#!/usr/bin/env bash

if [ -z "${1}" ]; then
    echo "Usage: ${0} SOURCE-CODE-FILE"
    echo "   SOURCE-CODE-FILE : name of source code to check format.  (Required)"
    exit 1
fi

tmpfile=$(mktemp /tmp/format-compare.XXXXXX)

filename=$(basename -- "${1}")
extension="${filename##*.}"
formatted_filename="${1%.*}_formatted-version.${extension}"

cp "${1}" "${formatted_filename}"
clang-format -i "${formatted_filename}"
mv "${formatted_filename}" "${formatted_filename}"

icdiff --cols=160 "${1}" "${formatted_filename}" | aha > "${tmpfile}.html"
rm "${formatted_filename}"
[[ $? -eq 0 ]] && wkhtmltopdf "${tmpfile}.html" "${tmpfile}.pdf" >/dev/null 2>&1
[[ $? -eq 0 ]] && mv "${tmpfile}.pdf" "${1%.*}_format-diff.pdf"

rm "${tmpfile}.html" 2>/dev/null || true
rm "${tmpfile}.pdf"  2>/dev/null || true
