#!/usr/bin/env python3
import os
import re
import sys
import json
import subprocess
import tempfile
import shutil
import argparse
from datetime import datetime

MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']


def parse_frontmatter(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    m = re.match(r'^---\s*\n(.*?)\n---\s*\n(.*)', content, re.DOTALL)
    if not m:
        return None, content

    fm = {}
    for line in m.group(1).split('\n'):
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        if ':' in line:
            key, _, val = line.partition(':')
            key = key.strip()
            val = val.strip()
            if val.startswith('[') and val.endswith(']'):
                val = [v.strip().strip('"').strip("'") for v in val[1:-1].split(',')]
            elif val.lower() == 'true':
                val = True
            elif val.lower() == 'false':
                val = False
            else:
                val = val.strip('"').strip("'")
            fm[key] = val

    body = m.group(2)
    return fm, body


def slugify(title):
    s = title.lower()
    s = re.sub(r'[^a-z0-9]+', '-', s)
    s = s.strip('-')
    return s


def extract_excerpt(body):
    parts = re.split(r'\n\n+', body, maxsplit=1)
    return parts[0].strip()


def fmt_date(year, month, day):
    return f"{day} {MONTHS[month - 1]} {year}"


def build_tag_html(tags, site_url):
    if not tags:
        return ''
    links = []
    for t in tags:
        slug = slugify(t)
        links.append(f'<a href="{site_url}/tags/{slug}">{t}</a>')
    sep = ', ' if len(links) > 2 else ' and '
    if len(links) == 2:
        sep = ' and '
    return sep.join(links)


def run_lowdown(md_text):
    with tempfile.NamedTemporaryFile(mode='w', suffix='.md', delete=False) as f:
        f.write(md_text)
        md_path = f.name

    try:
        r = subprocess.run(['lowdown', '-thtml', md_path],
                           capture_output=True, text=True, check=True)
        return r.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"lowdown error: {e.stderr}", file=sys.stderr)
        return md_text
    finally:
        os.unlink(md_path)


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


def process_posts(posts_dir, layouts_dir, output_dir, site_url, site_title):
    posts_data = []
    posts_dir_abs = os.path.abspath(posts_dir)
    layouts_dir_abs = os.path.abspath(layouts_dir)

    default_m4 = os.path.join(layouts_dir_abs, 'default.m4')
    post_m4 = os.path.join(layouts_dir_abs, 'post.m4')

    files = sorted(os.listdir(posts_dir_abs))
    for fname in files:
        if not fname.endswith('.md'):
            continue

        m = re.match(r'^(\d{4})-(\d{2})-(\d{2})-(.+)\.md$', fname)
        if not m:
            print(f"Skipping {fname}: invalid filename pattern", file=sys.stderr)
            continue

        year, month, day = int(m.group(1)), int(m.group(2)), int(m.group(3))
        fpath = os.path.join(posts_dir_abs, fname)
        fm, body = parse_frontmatter(fpath)
        if fm is None:
            print(f"Skipping {fname}: no frontmatter", file=sys.stderr)
            continue

        title = fm.get('title', m.group(4).replace('-', ' ').title())
        tags = fm.get('tags', [])
        if isinstance(tags, str):
            tags = [tags]

        date_str = fmt_date(year, month, day)
        excerpt = extract_excerpt(body)

        # Determine output path from permalink or slug
        permalink = fm.get('permalink', '')
        if permalink and permalink.startswith('/'):
            url_path = permalink.strip('/')
        else:
            url_path = f"page/{slugify(title)}"

        # Build output directory
        out_dir = os.path.join(output_dir, url_path)
        os.makedirs(out_dir, exist_ok=True)
        out_file = os.path.join(out_dir, 'index.html')

        # Body HTML via lowdown
        body_html = run_lowdown(body)
        excerpt_html = run_lowdown(excerpt)

        # Tag links HTML
        tag_html = build_tag_html(tags, site_url)

        # Wrap in post template via m4
        post_defines = {
            '_post_title': title,
            '_post_date': date_str,
            '_post_categories': '',
            '_post_tags': tag_html,
            '_post_content': body_html,
        }
        post_result = run_m4(post_defines, post_m4)

        if not post_result:
            print(f"m4 failed for {fname}", file=sys.stderr)
            continue

        # Wrap in default layout via m4
        year_links = ''  # Will be filled later by index/archive generators
        page_defines = {
            '_page_title': f"{title} * {site_title}",
            '_site_title': site_title,
            '_year_links': year_links,
            '_body_content': post_result,
        }
        page_result = run_m4(page_defines, default_m4)

        if not page_result:
            print(f"m4 default layout failed for {fname}", file=sys.stderr)
            continue

        with open(out_file, 'w', encoding='utf-8') as f:
            f.write(page_result)

        print(f"  {fname} → /{url_path}/")

        posts_data.append({
            'title': title,
            'date': f"{year}-{month:02d}-{day:02d}",
            'date_fmt': date_str,
            'tags': tags,
            'url': f"/{url_path}/",
            'excerpt': excerpt_html,
            'body': body_html,
        })

    return posts_data


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--posts', required=True)
    parser.add_argument('--layouts', required=True)
    parser.add_argument('--output', required=True)
    parser.add_argument('--url', required=True)
    parser.add_argument('--title', required=True)
    args = parser.parse_args()

    posts_data = process_posts(args.posts, args.layouts, args.output,
                               args.url, args.title)

    data_dir = os.path.join(os.path.dirname(args.output), '_data')
    os.makedirs(data_dir, exist_ok=True)
    with open(os.path.join(data_dir, 'posts.json'), 'w', encoding='utf-8') as f:
        json.dump(posts_data, f, ensure_ascii=False, indent=2)

    print(f"\nProcessed {len(posts_data)} posts")


if __name__ == '__main__':
    main()
