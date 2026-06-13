#!/bin/sh

posts_dir="$1"
layouts_dir="$2"
output_dir="$3"
site_url="$4"
site_title="$5"
assets_dir="$6"
data_dir="$7"
site_repo="$8"

build_dir=$(dirname "$0")
mkdir -p "$data_dir" "$output_dir"
posts_file="${data_dir}/posts.txt"

: > "$posts_file"

month_name() {
    case $1 in
        01) echo Jan ;; 02) echo Feb ;; 03) echo Mar ;;
        04) echo Apr ;; 05) echo May ;; 06) echo Jun ;;
        07) echo Jul ;; 08) echo Aug ;; 09) echo Sep ;;
        10) echo Oct ;; 11) echo Nov ;; 12) echo Dec ;;
    esac
}

slugify() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g; s/--*/-/g; s/^-//; s/-$//'
}

for f in "$posts_dir"/*.md; do
    [ -f "$f" ] || continue

    fname=$(basename "$f")

    year=$(echo "$fname" | cut -d- -f1)
    month=$(echo "$fname" | cut -d- -f2)
    day=$(echo "$fname" | cut -d- -f3)
    date_iso="${year}-${month}-${day}"
    date_fmt="$day $(month_name "$month") $year"

    eval "$(awk -f "${build_dir}/frontmatter.awk" "$f")"

    if [ -n "$_permalink" ]; then
        url_path=$(echo "$_permalink" | sed 's|^/||')
    else
        url_path="page/$(slugify "$_title")"
    fi

    printf '  %s -> /%s/\n' "$fname" "$url_path"

    body=$(awk 'BEGIN{s=0} s<2&&/^---$/{s++;next} s==1{next} {print}' "$f")

    alist=$(mktemp)
    : > "$alist"
    resolved=$(printf '%s\n' "$body" | awk -v assets_root="$assets_dir" -v list_file="$alist" -f "${build_dir}/resolve-assets.awk")

    body_html=$(printf '%s\n' "$resolved" | lowdown -thtml 2>/dev/null)

    downloads=""
    if [ -s "$alist" ]; then
        paths=$(sort -u "$alist")
        items=""
        for ap in $paths; do
            aname=$(basename "$ap")
            items="${items}<li><a href=\"/assets/posts/${ap}\">Download ${aname}</a></li>
"
        done
        downloads="<section class=\"downloads\"><h2>Downloadable bits</h2><ul>${items}</ul></section>"
    fi
    rm -f "$alist"

    if [ -n "$downloads" ]; then
        body_html="${body_html}
${downloads}"
    fi

    tag_html=""
    OLD_IFS=$IFS
    IFS=,
    for t in $_tags; do
        t=$(echo "$t" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
        [ -z "$t" ] && continue
        tslug=$(slugify "$t")
        if [ -n "$tag_html" ]; then
            tag_html="${tag_html}, "
        fi
        tag_html="${tag_html}<a href=\"/tags/${tslug}\">${t}</a>"
    done
    IFS=$OLD_IFS

    excerpt=$(printf '%s\n' "$resolved" | awk 'BEGIN{RS="";ORS="\n\n"} {print; exit}')
    excerpt_html=$(printf '%s\n' "$excerpt" | lowdown -thtml 2>/dev/null)

    gen_page() {
        local content="$1"
        local post_html
        post_html=$(m4 \
          -D _post_title="$_title" \
          -D _post_date="$date_fmt" \
          -D _post_categories="" \
          -D _post_tags="$tag_html" \
          -D _post_content="$content" \
          "${layouts_dir}/post.m4" 2>/dev/null)

        m4 \
          -D _page_title="$_title * $site_title" \
          -D _site_title="$site_title" \
          -D _site_repo="$site_repo" \
          -D _year_links="" \
          -D _body_content="$post_html" \
          "${layouts_dir}/default.m4" 2>/dev/null
    }

    full_html=$(gen_page "$body_html")
    out_dir="${output_dir}/${url_path}"
    mkdir -p "$out_dir"
    printf '%s\n' "$full_html" > "${out_dir}/index.html"

    printf '%s\t%s\t%s\t/%s/\t%s\n' "$date_iso" "$date_fmt" "$_title" "$url_path" "$_tags" >> "$posts_file"
done

count=$(wc -l < "$posts_file")
printf '\nProcessed %s posts\n' "$count"
