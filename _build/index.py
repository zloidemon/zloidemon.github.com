#!/usr/bin/env python3
import os
import sys
import json
import subprocess
import tempfile
import argparse
import re


def slugify(s):
    s = s.lower()
    s = re.sub(r'[^a-z0-9]+', '-', s)
    s = s.strip('-')
    return s


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

    posts_data.sort(key=lambda p: p['date'], reverse=True)
    latest = posts_data[:3]

    year_links = build_year_links(posts_data, args.url)

    post_m4 = os.path.join(args.layouts, 'post.m4')
    default_m4 = os.path.join(args.layouts, 'default.m4')

    articles = []
    for p in latest:
        tag_html = ', '.join(
            f'<a href="{args.url}/tags/{slugify(t)}">{t}</a>'
            for t in p['tags']
        )

        post_defines = {
            '_post_title': p['title'],
            '_post_date': p['date_fmt'],
            '_post_categories': '',
            '_post_tags': tag_html,
            '_post_content': p['excerpt'] + f'\n<p><a href="{p["url"]}">Read more&hellip;</a></p>',
        }
        article = run_m4(post_defines, post_m4)
        if article:
            articles.append(article)

    body = '\n'.join(articles)
    page_defines = {
        '_page_title': args.title,
        '_site_title': args.title,
        '_year_links': year_links,
        '_body_content': body,
    }
    result = run_m4(page_defines, default_m4)

    if result:
        with open(os.path.join(args.output, 'index.html'), 'w', encoding='utf-8') as f:
            f.write(result)
        print(f"Generated index.html ({len(latest)} posts)")
    else:
        print("Failed to generate index.html", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
