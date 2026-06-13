/<\/header>/ { in_body = 1; next }
in_body && /^[[:space:]]*<p[ >]/ { collecting = 1 }
collecting { print }
collecting && /<\/p>/ { exit }
