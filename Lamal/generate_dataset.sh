#!/bin/bash

set -euo pipefail

declare -A files=(
  [Archiv_Praemien_2011.zip]="https://bag-files.opendata.swiss/owncloud/index.php/s/8PI18oOi1X59uO3/download"
  [Archiv_Praemien_2012.zip]="https://bag-files.opendata.swiss/owncloud/index.php/s/hRqm0C0CZPasv1u/download"
  [Archiv_Praemien_2013.zip]="https://bag-files.opendata.swiss/owncloud/index.php/s/lFnpuNJl84hzucs/download"
  [Archiv_Praemien_2014.zip]="http://bar-opendata-ch.s3.amazonaws.com/ch.bag/Praemien/Archiv_Praemien_2014.zip"
  [Archiv_Praemien_2015.zip]="https://bag-files.opendata.swiss/owncloud/index.php/s/UL36nzYZuRrkHDA/download"
  [Archiv_Praemien_2016.zip]="https://bag-files.opendata.swiss/owncloud/index.php/s/8cUU1beTqcNtk8H/download"
  [Archiv_Praemien_2017.zip]="https://bag-files.opendata.swiss/owncloud/index.php/s/3FgYDP6uFhfe2jV/download"
  [Archiv_Praemien_2018.zip]="https://bag-files.opendata.swiss/owncloud/index.php/s/vx33hTA4J0ZcwYf/download"
  [Archiv_Praemien_2019.zip]="https://bag-files.opendata.swiss/owncloud/index.php/s/JtGQs8Bkp61oCL1/download"
  [Archiv_Praemien_2020.zip]="https://bag-files.opendata.swiss/owncloud/index.php/s/yTDcw7dBRnfwZj2/download"
  [Archiv_Praemien_2021.zip]="https://bag-files.opendata.swiss/owncloud/index.php/s/NaxmnWZEdiwopNr/download"
  [Archiv_Praemien_2022.zip]="https://bag-files.opendata.swiss/owncloud/index.php/s/nfcN79zT5eaJ7yn/download"
  [Archiv_Praemien_2023.zip]="https://bag-files.opendata.swiss/owncloud/index.php/s/Brbwzs4kWPP83Qm/download"
  [Archiv_Praemien_2024.zip]="https://bag-files.opendata.swiss/owncloud/index.php/s/5qptAxHT7Pii9WL/download"
)

last_year=2025
last_url_ch="https://bag-files.opendata.swiss/owncloud/index.php/s/83Vtexg1buoOk6M/download"
last_url_eu="https://bag-files.opendata.swiss/owncloud/index.php/s/xfkW838taWpI7XX/download"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp_dir="$script_dir/datasource/praemien_tmp"

mkdir -p "$tmp_dir"

echo "📥 Downloading ZIP files..."
for filename in "${!files[@]}"; do
  url="${files[$filename]}"
  curl -sL -o "$tmp_dir/$filename" "$url"
done

echo "📦 Extracting and fixing filenames..."
cd "$tmp_dir"
for zipfile in *.zip; do
  year=$(echo "$zipfile" | grep -o '[0-9]\{4\}')
  target_dir="../$year"

  if [ -d "$target_dir" ]; then
    echo "⚠️  Skipping $year (already exists)"
    continue
  fi

  mkdir -p "$target_dir"
  unzip -qq "$zipfile" -d "$target_dir"

  find "$target_dir" -type f | while read -r file; do
    clean_name=$(basename "$file" | iconv -f ISO-8859-1 -t UTF-8//IGNORE | sed -E 's/Pr[ÄäДд]/Prae/g' | sed 's/[^a-zA-Z0-9_.-]/_/g')
    clean_name=$(echo "$clean_name" | sed -E 's/__+/_/g' | sed -E 's/_+\.csv$/.csv/')
    if [[ "$file" != "$target_dir/$clean_name" ]]; then
      mv "$file" "$target_dir/$clean_name"
    fi
  done
done
cd ..
rm -rf "$tmp_dir"

echo "📥 Downloading raw CSVs for $last_year..."
mkdir -p "$last_year"
for type in CH EU; do
  url_var="last_url_${type,,}"
  target_file="$last_year/Praemien_${type}.csv"
  tmp_file="$target_file.tmp"
  curl -sL -o "$tmp_file" "${!url_var}"

  encoding=$(file -bi "$tmp_file" | sed 's/.*charset=//')
  if [[ "$encoding" != "utf-8" ]]; then
    iconv -f "$encoding" -t utf-8 "$tmp_file" > "$target_file"
  else
    cp "$tmp_file" "$target_file"
  fi

  sep=$(head -n 1 "$target_file" | grep -q ";" && echo ";" || echo ",")
  if [[ "$sep" == "," ]]; then
    sed -i 's/,/;/g' "$target_file"
  fi

  rm -f "$tmp_file"
done

echo "🧹 Normalizing all CSVs and building metadata..."
output_json="config.json"
echo '{ "primes": [' > "$output_json"
first=1

for year in */; do
  year="${year%/}"
  file_ch=$(find "$year" -iname "*CH*.csv" | grep -v "Praemien_CH.csv" | head -n1 || true)
  file_eu=$(find "$year" -iname "*EU*.csv" | grep -v "Praemien_EU.csv" | head -n1 || true)

  target_ch="$year/Praemien_CH.csv"
  target_eu="$year/Praemien_EU.csv"

  for src in "$file_ch" "$file_eu"; do
    [[ -f "$src" ]] || continue
    dst="$year/$(basename "$src" | sed -E 's/.*CH.*/Praemien_CH.csv/' | sed -E 's/.*EU.*/Praemien_EU.csv/')"

    encoding=$(file -bi "$src" | sed 's/.*charset=//')
    if [[ "$encoding" != "utf-8" ]]; then
      iconv -f "$encoding" -t utf-8 "$src" > "$dst.tmp"
    else
      cp "$src" "$dst.tmp"
    fi

    sep=$(head -n 1 "$dst.tmp" | grep -q ";" && echo ";" || echo ",")
    if [[ "$sep" == "," ]]; then
      sed 's/,/;/g' "$dst.tmp" > "$dst"
    else
      mv "$dst.tmp" "$dst"
    fi
    rm -f "$dst.tmp"
  done

  [[ -f "$target_ch" && -f "$target_eu" ]] || {
    echo "⚠️  Skipping $year (missing CH or EU CSV)"
    continue
  }

  [[ "$first" -eq 0 ]] && echo "," >> "$output_json"
  first=0
  echo "  { \"id\": \"l$year\", \"year\": $year, \"path_ch\": \"$target_ch\", \"path_eu\": \"$target_eu\", \"encoding_ch\": \"utf-8\", \"encoding_eu\": \"utf-8\", \"sep\":\";\" }" >> "$output_json"
done

echo "] }" >> "$output_json"
echo "✅ Done. Metadata saved to $output_json"
