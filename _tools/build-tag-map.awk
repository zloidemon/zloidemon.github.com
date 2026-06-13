BEGIN { FS = "\t" }
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
