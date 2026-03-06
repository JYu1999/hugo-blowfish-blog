# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Start local dev server with live reload
hugo server

# Build the site
hugo

# Create a new post
hugo new content/posts/<slug>/index.md

# Create a new tweet
hugo new content/tweets/<slug>/index.md
```

## Architecture

This is a personal blog built with [Hugo](https://gohugo.io/) using the [Blowfish theme](https://blowfish.page/) (included as a git submodule at `themes/blowfish/`).

### Site Configuration

All config lives in `config/_default/`:
- `hugo.toml` — core Hugo settings (default language: `zh-tw`, taxonomy setup, pagination)
- `params.toml` — Blowfish theme parameters (layout, color scheme `terminal`, appearance)
- `languages.zh-tw.toml`, `languages.en.toml`, `languages.ja.toml` — per-language settings and author info
- `menus.*.toml` — navigation menus per language

### Content Structure

The blog has two main content types:

- **posts** (`content/posts/`) — long-form articles. Each post is a directory (page bundle) with `index.md` (zh-tw), optionally `index.en.md` (English), and image assets including `featured.png`.
- **tweets** (`content/tweets/`) — short-form microblog entries. Same bundle structure: `index.md` + optional `index.en.md`.

The site is trilingual (zh-tw primary, en, ja). Language variants use filename suffixes: `index.md` = zh-tw, `index.en.md` = en, `index.ja.md` = ja.

### Front Matter Conventions

```yaml
---
title: "Post Title"
date: 2026-01-01T00:00:00+08:00
draft: false
tags: ["tag1", "tag2"]
categories:
  - category-name
---
```

Tweets typically only use `title`, `date`, `draft`, and optionally `tags`. Posts may also include `description` and `series`.

### Allowed Tags

Tags are strictly controlled. Always use the exact string for the post's language.

| English | 中文 | 日文 |
|---|---|---|
| Technical | 技術 | 技術 |
| Career | 職涯 | キャリア |
| Life | 生活 | 生活 |
| Reading | 閱讀 | 読書 |
| Travel | 旅遊 | 旅行 |
| Goodidea Studio | 好想工作室 | グッドアイデアスタジオ |
| Japan | 日本 | 日本 |
| Security | 資安 | セキュリティ |
| Tools | 生產力工具 | 生産性ツール |
| Blog | 部落格 | ブログ |
| AI | 人工智慧 | AI |

### Allowed Tags

Tags are strictly controlled. Always use the exact string for the post's language.

| English | 中文 | 日文 |
|---|---|---|
| Technical | 技術 | 技術 |
| Career | 職涯 | キャリア |
| Life | 生活 | 生活 |
| Reading | 閱讀 | 読書 |
| Travel | 旅遊 | 旅行 |
| Goodidea Studio | 好想工作室 | グッドアイデアスタジオ |
| Japan | 日本 | 日本 |
| Security | 資安 | セキュリティ |
| Tools | 生產力工具 | 生産性ツール |
| Blog | 部落格 | ブログ |
| AI | 人工智慧 | AI |

### AI Translation Alert

All English posts (`index.en.md`) must begin with this alert immediately after the front matter:

```
{{< alert "circle-info">}}
This article was translated by AI. If you find any errors, please feel free to email me at jk29666338@gmail.com 🙏.
{{< /alert >}}
```

All Japanese posts (`index.ja.md`) must begin with this alert immediately after the front matter:

```
{{< alert "circle-info">}}
この記事はAIによって翻訳されています。誤りを見つけた場合は、jk29666338@gmail.com までメールでお知らせください 🙏。
{{< /alert >}}
```

This rule applies to **posts only**, not tweets.

### Key URLs and Identity

- Live site: `https://jyu1999.com`
- Author: 結語JYu
- Default language: Traditional Chinese (`zh-tw`)