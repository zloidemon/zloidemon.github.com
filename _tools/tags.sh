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

m4_escape() {
    sed 's/\[\[/\\[[/g; s/\]\]/\\]]/g'
}

slugify() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g; s/--*/-/g; s/^-//; s/-$//'
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

mkdir -p "${output_dir}/tags"

# Build tag→posts map with awk
awk -F'\t' '
function slugify(s) {
    gsub(/[^a-zA-Z0-9]/, "-", s)
    gsub(/--+/, "-", s)
    gsub(/^-|-$/, "", s)
    return tolower(s)
}
{
    date_fmt = $2
    title = $3
    url = $4
    tags_str = $5
    n = split(tags_str, taglist, ",")
    for (i = 1; i <= n; i++) {
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", taglist[i])
        if (taglist[i] == "") continue
        tag = taglist[i]
        slug = slugify(tag)
        count[tag]++
        map[tag, count[tag]] = $0
    }
}
END {
    for (tag in count) {
        print "TAG:" tag
        print "SLUG:" slugify(tag)
        for (i = 1; i <= count[tag]; i++)
            print map[tag, i]
        print "ENDTAG"
    }
}
' "$posts_file" | while read marker; do
    case $marker in
        TAG:*)
            tag=$(echo "$marker" | sed 's/^TAG://')
            slug=""
            entries=""
            ;;
        SLUG:*)
            slug=$(echo "$marker" | sed 's/^SLUG://')
            ;;
        ENDTAG)
            if [ -n "$entries" ] && [ -n "$slug" ]; then
                archive_title="Articles tagged with &laquo;${tag}&raquo;"

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
                printf "define([[_site_repo]], [[%s]])dnl\n" "$site_repo" >> "$tmpm4"
                printf "define([[_year_links]], [[%s]])dnl\n" "$year_links" >> "$tmpm4"
                printf "define([[_body_content]], [[%s]])dnl\n" "$(printf '%s\n' "$archive_body" | m4_escape)" >> "$tmpm4"
                printf "include([[${layouts_dir}/default.m4]])dnl\n" >> "$tmpm4"
                page_html=$(m4 "$tmpm4" 2>/dev/null)
                rm -f "$tmpm4"

                mkdir -p "${output_dir}/tags/${slug}"
                printf '%s\n' "$page_html" > "${output_dir}/tags/${slug}/index.html"
                post_count=$(echo "$entries" | grep -c '<li>')
                printf "Generated tags/%s/ (%s posts)\n" "$slug" "$post_count"
            fi
            ;;
        *)
            if [ -n "$marker" ]; then
                date_fmt=$(echo "$marker" | cut -f2)
                title_post=$(echo "$marker" | cut -f3)
                url=$(echo "$marker" | cut -f4)
                tags_line=$(echo "$marker" | cut -f5)

                tag_html=""
                OLD_IFS=$IFS
                IFS=,
                for t in $tags_line; do
                    t=$(echo "$t" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
                    [ -z "$t" ] && continue
                    tslug=$(slugify "$t")
                    if [ -n "$tag_html" ]; then
                        tag_html="${tag_html}, "
                    fi
                    tag_html="${tag_html}<a href=\"/tags/${tslug}/\">${t}</a>"
                done
                IFS=$OLD_IFS

                entry="<li><a href=\"${url}\">${title_post}</a><ul class=\"post-info\"><li>Date: ${date_fmt}</li><li>Tagged with: ${tag_html}</li></ul></li>"
                entries="${entries}${entry}
"
            fi
            ;;
    esac
done

tag_count=$(find "${output_dir}/tags" -name '*.html' | wc -l)
echo "Tag generation complete (${tag_count} tags)"
