#!/bin/sh

data_dir="$1"
layouts_dir="$2"
output_dir="$3"
site_url="$4"
site_title="$5"

build_dir=$(dirname "$0")
posts_file="${data_dir}/posts.txt"

if [ ! -f "$posts_file" ]; then
    echo "Error: posts.txt not found. Run posts.sh first." >&2
    exit 1
fi

m4_escape() {
    sed 's/\[\[/\\[[/g; s/\]\]/\\]]/g'
}

# Build year links
years=$(awk -F'\t' '{print substr($1,1,4)}' "$posts_file" | sort -ru)
year_links=""
for y in $years; do
    if [ -n "$year_links" ]; then
        year_links="${year_links} | "
    fi
    year_links="${year_links}<a href=\"/archives/${y}/\">${y}</a>"
done

mkdir -p "${output_dir}/archives"

# Group posts by year using awk
awk -F'\t' '
{
    year = substr($1, 1, 4)
    count[year]++
    posts[year, count[year]] = $0
}
END {
    for (year in count) {
        print "YEAR:" year
        for (i = 1; i <= count[year]; i++)
            print posts[year, i]
        print "ENDYEAR"
    }
}
' "$posts_file" | while read marker; do
    case $marker in
        YEAR:*)
            year=$(echo "$marker" | sed 's/^YEAR://')
            entries=""
            ;;
        ENDYEAR)
            if [ -n "$entries" ]; then
                archive_title="Archives of &laquo;${year}&raquo; year"

                tmpm4=$(mktemp)
                printf "changequote([[, ]])dnl\n" > "$tmpm4"
                printf "define([[_archive_title]], [[%s]])dnl\n" "$archive_title" >> "$tmpm4"
                printf "define([[_archive_entries]], [[%s]])dnl\n" "$(printf '%s\n' "$entries" | m4_escape)" >> "$tmpm4"
                printf "include([[${layouts_dir}/archive.m4]])dnl\n" >> "$tmpm4"
                archive_body=$(m4 "$tmpm4" 2>/dev/null)
                rm -f "$tmpm4"

                tmpm4=$(mktemp)
                printf "changequote([[, ]])dnl\n" > "$tmpm4"
                printf "define([[_page_title]], [[%s * %s]])dnl\n" "$archive_title" "$site_title" >> "$tmpm4"
                printf "define([[_site_title]], [[%s]])dnl\n" "$site_title" >> "$tmpm4"
                printf "define([[_year_links]], [[%s]])dnl\n" "$year_links" >> "$tmpm4"
                printf "define([[_body_content]], [[%s]])dnl\n" "$(printf '%s\n' "$archive_body" | m4_escape)" >> "$tmpm4"
                printf "include([[${layouts_dir}/default.m4]])dnl\n" >> "$tmpm4"
                page_html=$(m4 "$tmpm4" 2>/dev/null)
                rm -f "$tmpm4"

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
                    if [ -n "$tag_html" ]; then
                        tag_html="${tag_html}, "
                    fi
                    tag_html="${tag_html}<a href=\"/tags/${tslug}/\">${t}</a>"
                done
                IFS=$OLD_IFS

                entry="<li><a href=\"${url}\">${title}</a><ul class=\"post-info\"><li>Date: ${date_fmt}</li><li>Tagged with: ${tag_html}</li></ul></li>"
                entries="${entries}${entry}
"
            fi
            ;;
    esac
done

echo "Archive generation complete"
