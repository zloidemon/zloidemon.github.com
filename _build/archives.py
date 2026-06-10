#!/usr/bin/env python3
import os
import sys
import json
import argparse
import subprocess
import tempfile


def run_m4(defines, template_path):
    src = "changequote([[, ]])dnl\n"
    for k, v in defines.items():
        v_escaped = v.replace('[[', '\\[[').replace(']]', '\\]]')
        src += f"define([[{k}]], [[{v_escaped}]])dnl\n"
    src += f"include([[{template_path}]])dnl\n"

    with tempfile.NamedTemporaryFile(mode='w', suffix='.m4', delete=False) as f:
        f.write(src)
        m4_path = f.name

    try:
        r = subprocess.run(['m4', m4_path],
                           capture_output=True, text=True, check=True)
        return r.stdout
    except subprocess.CalledProcessError as e:
        print(f"m4 error: {e.stderr}", file=sys.stderr)
        return ''
    finally:
        os.unlink(m4_path)


def build_year_links(posts_data, site_url):
    years = sorted(set(p['date'][:4] for p in posts_data), reverse=True)
    links = []
    for y in years:
        links.append(f'<a href="{site_url}/archives/{y}">{y}</a>')
    return ' | '.join(links)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--data', required=True)
    parser.add_argument('--layouts', required=True)
    parser.add_argument('--output', required=True)
    parser.add_argument('--url', required=True)
    parser.add_argument('--title', required=True)
    args = parser.parse_args()

    with open(args.data, 'r', encoding='utf-8') as f:
        posts_data = json.load(f)

    # Group by year
    archives = {}
    for p in posts_data:
        year = p['date'][:4]
        archives.setdefault(year, []).append(p)

    archive_m4 = os.path.join(args.layouts, 'archive.m4')
    default_m4 = os.path.join(args.layouts, 'default.m4')
    year_links = build_year_links(posts_data, args.url)

    os.makedirs(os.path.join(args.output, 'archives'), exist_ok=True)

    for year in sorted(archives.keys(), reverse=True):
        posts = sorted(archives[year], key=lambda p: p['date'], reverse=True)
        entries = []
        for p in posts:
            tag_html = ', '.join(
                f'<a href="{args.url}/tags/{t.lower().replace(" ", "-").replace(".", "")}">{t}</a>'
                for t in p['tags']
            )
            entries.append(
                f'<li><a href="{p["url"]}">{p["title"]}</a>'
                f'<ul class="post-info">'
                f'<li>Date: {p["date_fmt"]}</li>'
                f'<li>Tagged with: {tag_html}</li>'
                f'</ul></li>'
            )

        archive_entries = '\n'.join(entries)
        archive_title = f"Archives of &laquo;{year}&raquo; year"

        archive_defines = {
            '_archive_title': archive_title,
            '_archive_entries': archive_entries,
        }
        archive_result = run_m4(archive_defines, archive_m4)

        if not archive_result:
            continue

        page_defines = {
            '_page_title': f"{archive_title} * {args.title}",
            '_site_title': args.title,
            '_year_links': year_links,
            '_body_content': archive_result,
        }
        page_result = run_m4(page_defines, default_m4)

        if page_result:
            out_path = os.path.join(args.output, 'archives', f'{year}.html')
            with open(out_path, 'w', encoding='utf-8') as f:
                f.write(page_result)
            print(f"Generated archives/{year}.html ({len(posts)} posts)")

    print("Archive generation complete")


if __name__ == '__main__':
    main()
