#!/usr/bin/env bash

if [ -z "${1}" ]; then
    echo "Usage: ${0} SOURCE-CODE-FILE"
    echo "   SOURCE-CODE-FILE : name of source code to check format.  (Required)"
    exit 1
fi

if [ -z "${WIDTH}" ]; then
    WIDTH=180
fi

LINEWIDTH=$(( WIDTH / 2 ))

tmpdir=$(mktemp -d /tmp/format-diff.XXXXXX)

filename=$(basename -- "${1}")
extension="${filename##*.}"
formatted_filename="${1%.*}-formatted-version.${extension}"

cp "${1}" "${formatted_filename}"
clang-format -i "${formatted_filename}"
mv "${formatted_filename}" "${formatted_filename}"

delta --side-by-side --light --width="${WIDTH}" --line-buffer-size=64 --max-line-length="${LINEWIDTH}" --paging=never --true-color=always --diff-highlight  "${1}" "${formatted_filename}" | aha > "${tmpdir}/${filename}.html"
rm "${formatted_filename}"
[[ $? -eq 0 ]] && wkhtmltopdf "${tmpdir}/${filename}.html" "${tmpdir}/${filename}.pdf" >/dev/null 2>&1
[[ $? -eq 0 ]] && mv "${tmpdir}/${filename}.pdf" "${1%.*}_${extension}-format-diff.pdf"

rm -rf "${tmpdir}"
