BEGIN { FS = "\t" }
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
