#!/usr/bin/env python3
import os
import sys
import json
import argparse
import re
from datetime import datetime, timezone
from xml.sax.saxutils import escape


def slugify(s):
    s = s.lower()
    s = re.sub(r'[^a-z0-9]+', '-', s)
    s = s.strip('-')
    return s


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--data', required=True)
    parser.add_argument('--output', required=True)
    parser.add_argument('--url', required=True)
    parser.add_argument('--title', required=True)
    args = parser.parse_args()

    with open(args.data, 'r', encoding='utf-8') as f:
        posts_data = json.load(f)

    posts_data.sort(key=lambda p: p['date'], reverse=True)
    latest = posts_data[:10]

    now = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')

    lines = []
    lines.append('<?xml version="1.0" encoding="utf-8"?>')
    lines.append(f'<feed xmlns="http://www.w3.org/2005/Atom">')
    lines.append(f'  <title>{escape(args.title)}</title>')
    lines.append(f'  <id>{args.url}/</id>')
    lines.append(f'  <updated>{now}</updated>')
    lines.append(f'  <author>')
    lines.append(f'    <name>Veniamin Gvozdikov</name>')
    lines.append(f'    <email>vg@FreeBSD.org</email>')
    lines.append(f'  </author>')

    for p in latest:
        title = escape(p['title'])
        link = f"{args.url}{p['url']}"
        post_id = f"{args.url}/page/{slugify(p['title'])}"
        updated = f"{p['date']}T00:00:00Z"
        excerpt = escape(p.get('excerpt', ''))
        content = escape(p.get('body', ''))

        lines.append(f'  <entry>')
        lines.append(f'    <title>{title}</title>')
        lines.append(f'    <link href="{link}"/>')
        lines.append(f'    <id>{post_id}</id>')
        lines.append(f'    <updated>{updated}</updated>')
        lines.append(f'    <summary type="html">{excerpt}</summary>')
        lines.append(f'    <content type="html">{content}</content>')
        lines.append(f'  </entry>')

    lines.append(f'</feed>')

    result = '\n'.join(lines) + '\n'
    out_path = os.path.join(args.output, 'atom.xml')
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(result)
    print(f"Generated atom.xml ({len(latest)} entries)")


if __name__ == '__main__':
    main()
