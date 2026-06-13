#!/bin/sh

data_dir="$1"
layouts_dir="$2"
output_dir="$3"
site_url="$4"
site_title="$5"
site_repo="$6"

build_dir=$(dirname "$0")

posts_file="${data_dir}/posts.txt"

if [ ! -f "$posts_file" ]; then
    echo "Error: posts.txt not found. Run posts.sh first." >&2
    exit 1
fi

# Build year links from all posts
years=$(awk -F'\t' '{print substr($1,1,4)}' "$posts_file" | sort -ru)
year_links=""
for y in $years; do
    if [ -n "$year_links" ]; then
        year_links="${year_links} | "
    fi
    year_links="${year_links}<a href=\"/archives/${y}/\">${y}</a>"
done

# Take top 3 posts by date (file is already sorted, but sort to be sure)
latest=$(sort -t"$(printf '\t')" -k1,1r "$posts_file" | head -3)

articles=""
IFS='
'
for line in $latest; do
    [ -z "$line" ] && continue
    date_iso=$(echo "$line" | cut -f1)
    date_fmt=$(echo "$line" | cut -f2)
    title=$(echo "$line" | cut -f3)
    url=$(echo "$line" | cut -f4)
    tags=$(echo "$line" | cut -f5)

    # Read the post page and extract the first <p> after </header>
    post_file="${output_dir}${url}index.html"
    excerpt=""
    if [ -f "$post_file" ]; then
        excerpt=$(awk '
            /<\/header>/ { in_body = 1; next }
            in_body && /^[[:space:]]*<p[ >]/ { collecting = 1 }
            collecting { print }
            collecting && /<\/p>/ { exit }
        ' "$post_file")
    fi
    [ -z "$excerpt" ] && excerpt="<p>Read the full post for details.</p>"

    # Build tag links
    tag_html=""
    OLD_IFS=$IFS
    IFS=,
    for t in $tags; do
        t=$(echo "$t" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
        [ -z "$t" ] && continue
        tslug=$(echo "$t" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g; s/--*/-/g; s/^-//; s/-$//')
        if [ -n "$tag_html" ]; then
            tag_html="${tag_html}, "
        fi
        tag_html="${tag_html}<a href=\"/tags/${tslug}/\">${t}</a>"
    done
    IFS=$OLD_IFS

    article=$(m4 \
      -D _post_title="$title" \
      -D _post_date="$date_fmt" \
      -D _post_categories="" \
      -D _post_tags="$tag_html" \
      -D _post_content="$(printf '%s\n' "$excerpt"; printf "<p><a href=\"${url}\">Read more&hellip;</a></p>")" \
      "${layouts_dir}/post.m4" 2>/dev/null)

    if [ -n "$article" ]; then
        articles="${articles}${article}
"
    fi
done
unset IFS

result=$(m4 \
  -D _page_title="$site_title" \
  -D _site_title="$site_title" \
  -D _site_repo="$site_repo" \
  -D _year_links="$year_links" \
  -D _body_content="$articles" \
  "${layouts_dir}/default.m4" 2>/dev/null)

if [ -n "$result" ]; then
    printf '%s\n' "$result" > "${output_dir}/index.html"
    count=$(echo "$latest" | wc -l)
    printf "Generated index.html (%s posts)\n" "$(echo "$latest" | grep -c .)"
else
    echo "Failed to generate index.html" >&2
    exit 1
fi
