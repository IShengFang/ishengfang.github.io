# I-Sheng Fang Personal Website

Static Jekyll source for a redesigned personal research website.

## Local development

This site is designed for GitHub Pages. With Ruby and Bundler available:

```sh
bundle install
bundle exec jekyll serve
```

The production target is `https://ishengfang.github.io/`. This directory is a staging workspace before replacing the existing GitHub Pages source.

## Instagram post updates

The Instagram preview is generated from `_data/photography.yml` and cached image files in `assets/img/photography/`.

To refresh it locally, create an Instagram long-lived user access token, then run:

```sh
INSTAGRAM_ACCESS_TOKEN=your_token ruby scripts/update_instagram_posts.rb
```

The script downloads the latest 9 posts, saves them as `assets/img/photography/instagram-post-*.jpg` or matching image extensions, and rewrites `_data/photography.yml`.

For automatic updates on GitHub, add a repository secret named `INSTAGRAM_ACCESS_TOKEN`. The workflow in `.github/workflows/update-instagram.yml` runs every day and commits changes when the Instagram feed changes.
