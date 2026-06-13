{
    while (match($0, /\{% asset [^ ]+ %\}/)) {
        tag = substr($0, RSTART, RLENGTH)
        path = substr(tag, 10, length(tag) - 12)
        fpath = assets_root "/" path
        content = ""
        while ((getline line < fpath) > 0)
            content = content line "\n"
        close(fpath)
        if (content == "") {
            content = ""
        } else {
            print path >> list_file
        }
        $0 = substr($0, 1, RSTART-1) content substr($0, RSTART+RLENGTH)
    }
    print
}
