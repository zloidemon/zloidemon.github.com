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

# Build year links
years=$(${AWK:-awk} -F'\t' '{print substr($1,1,4)}' "$posts_file" | sort -ru)
year_links=""
for y in $years; do
    link=$(m4 -D _year="$y" "${layouts_dir}/year-link.m4" 2>/dev/null)
    if [ -n "$year_links" ]; then
        year_links="${year_links} | ${link}"
    else
        year_links="$link"
    fi
done

mkdir -p "${output_dir}/archives"

# Group posts by year using awk
${AWK:-awk} -f "${build_dir}/group-by-year.awk" "$posts_file" | while read marker; do
    case $marker in
        YEAR:*)
            year=$(echo "$marker" | sed 's/^YEAR://')
            entries=""
            ;;
        ENDYEAR)
            if [ -n "$entries" ]; then
                archive_title="Archives of &laquo;${year}&raquo; year"

                archive_body=$(m4 \
                  -D _archive_title="$archive_title" \
                  -D _archive_entries="$entries" \
                  "${layouts_dir}/archive.m4" 2>/dev/null)

                page_html=$(m4 \
                  -D _page_title="$archive_title * $site_title" \
                  -D _site_title="$site_title" \
                  -D _site_repo="$site_repo" \
                  -D _year_links="$year_links" \
                  -D _body_content="$archive_body" \
                  "${layouts_dir}/default.m4" 2>/dev/null)

                mkdir -p "${output_dir}/archives/${year}"
                printf '%s\n' "$page_html" > "${output_dir}/archives/${year}/index.html"
                post_count=$(echo "$entries" | grep -c '<li>')
                printf "Generated archives/%s/ (%s posts)\n" "$year" "$post_count"
            fi
            ;;
        *)
            if [ -n "$marker" ]; then
                date_fmt=$(echo "$marker" | cut -f2)
                title=$(echo "$marker" | cut -f3)
                url=$(echo "$marker" | cut -f4)
                tags=$(echo "$marker" | cut -f5)

                tag_html=""
                OLD_IFS=$IFS
                IFS=,
                for t in $tags; do
                    t=$(echo "$t" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
                    [ -z "$t" ] && continue
                    tslug=$(echo "$t" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g; s/--*/-/g; s/^-//; s/-$//')
                    link=$(m4 -D _tag_slug="$tslug" -D _tag_name="$t" "${layouts_dir}/tag-link.m4" 2>/dev/null)
                    if [ -n "$tag_html" ]; then
                        tag_html="${tag_html}, ${link}"
                    else
                        tag_html="$link"
                    fi
                done
                IFS=$OLD_IFS

                entry=$(m4 \
                  -D _entry_url="$url" \
                  -D _entry_title="$title" \
                  -D _entry_date="$date_fmt" \
                  -D _entry_tags="$tag_html" \
                  "${layouts_dir}/entry.m4" 2>/dev/null)
                entries="${entries}${entry}
"
            fi
            ;;
    esac
done

echo "Archive generation complete"
