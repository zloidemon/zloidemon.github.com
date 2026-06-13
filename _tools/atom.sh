#!/bin/sh

data_dir="$1"
output_dir="$2"
site_url="$3"
site_title="$4"
layouts_dir="$5"
site_author="$6"
site_email="$7"

build_dir=$(dirname "$0")
posts_file="${data_dir}/posts.txt"

if [ ! -f "$posts_file" ]; then
    echo "Error: posts.txt not found. Run posts.sh first." >&2
    exit 1
fi

xml_escape() {
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&apos;/g'
}

slugify() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g; s/--*/-/g; s/^-//; s/-$//'
}

now=$(date -u +'%Y-%m-%dT%H:%M:%SZ')

latest=$(sort -t"$(printf '\t')" -k1,1r "$posts_file" | head -10)

entries=""
IFS='
'
for line in $latest; do
    [ -z "$line" ] && continue
    date_iso=$(echo "$line" | cut -f1)
    title=$(echo "$line" | cut -f3)
    url=$(echo "$line" | cut -f4)
    tags=$(echo "$line" | cut -f5)

    # Read post page for body content
    post_file="${output_dir}${url}index.html"
    body=""
    if [ -f "$post_file" ]; then
        body=$(sed -n '/<\/header>/,/<\/article>/p' "$post_file" | sed '1d;$d')
    fi
    [ -z "$body" ] && body="<p>No content</p>"

    # Extract excerpt (first <p> after header)
    excerpt=""
    if [ -f "$post_file" ]; then
        excerpt=$(${AWK:-awk} -f "${build_dir}/extract-excerpt.awk" "$post_file")
    fi
    [ -z "$excerpt" ] && excerpt="<p>Read the full post for details.</p>"

    post_title=$(printf '%s' "$title" | xml_escape)
    link="http://${site_url}${url}"
    post_id="http://${site_url}/page/$(slugify "$title")"
    updated="${date_iso}T00:00:00Z"
    excerpt_esc=$(printf '%s' "$excerpt" | xml_escape)
    body_esc=$(printf '%s' "$body" | xml_escape)

    entry=$(printf '  <entry>\n    <title>%s</title>\n    <link href="%s"/>\n    <id>%s</id>\n    <updated>%s</updated>\n    <summary type="html">%s</summary>\n    <content type="html">%s</content>\n  </entry>\n' \
      "$post_title" "$link" "$post_id" "$updated" "$excerpt_esc" "$body_esc")
    entries="${entries}${entry}"
done
unset IFS

feed_title=$(printf '%s' "$site_title" | xml_escape)
m4 \
  -D _feed_title="$feed_title" \
  -D _feed_url="$site_url" \
  -D _feed_updated="$now" \
  -D _feed_author="$site_author" \
  -D _feed_email="$site_email" \
  -D _feed_entries="$entries" \
  "${layouts_dir}/atom.m4" 2>/dev/null > "${output_dir}/atom.xml"

echo "Generated atom.xml ($(echo "$latest" | grep -c .) entries)"
