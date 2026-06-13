BEGIN { s = 0; title = ""; tags = ""; permalink = "" }
s < 2 && /^---$/ { s++; next }
s == 1 {
    if (/^title:/) {
        sub(/^title:[[:space:]]*/, ""); sub(/[[:space:]]+$/, "")
        gsub(/'/, "'\\''")
        title = $0
    }
    if (/^tags:/) {
        sub(/^tags:[[:space:]]*/, ""); gsub(/^\[|\]$/, "")
        gsub(/[[:space:]]*,[[:space:]]*/, ",")
        gsub(/^[[:space:]]+|[[:space:]]+$/, "")
        gsub(/'/, "'\\''")
        tags = $0
    }
    if (/^permalink:/) {
        sub(/^permalink:[[:space:]]*/, ""); sub(/[[:space:]]+$/, "")
        gsub(/'/, "'\\''")
        permalink = $0
    }
    next
}
END {
    print "_title='" title "'"
    print "_tags='" tags "'"
    print "_permalink='" permalink "'"
}
