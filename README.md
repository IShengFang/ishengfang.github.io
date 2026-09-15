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

### Recover from an expired or invalid token

`OAuthException` with code `190` indicates an expired or invalid access token. A message such as `Session has expired` requires a new token; rerunning the workflow with the same expired secret will keep failing.

1. Open your app in the [Meta App Dashboard](https://developers.facebook.com/apps/), reauthorize the Instagram account if needed, and generate a new long-lived Instagram user access token. Use the Instagram Login setup for the account whose posts appear on this site.
2. Open this repository's [Actions secrets settings](https://github.com/IShengFang/ishengfang.github.io/settings/secrets/actions) and edit the repository secret `INSTAGRAM_ACCESS_TOKEN` with the new value.
3. Open **Actions > Update Instagram Posts > Run workflow** to start a new run.

The script exits with a failure on authentication errors and leaves the existing photography data and cached images in place. The site continues to display those cached posts until authentication is restored. Keep the token in GitHub Secrets or your local environment, never in source files or logs.

### Token renewal

Fetching posts does not renew the token, and this workflow does not automatically refresh or replace the repository secret. Long-lived Instagram Login tokens normally last 60 days. Set a reminder to renew before expiry, for example every 30 days.

Meta's [refresh endpoint](https://developers.facebook.com/docs/instagram-platform/reference/refresh_access_token/) accepts a long-lived token that is at least 24 hours old and has not expired. Save the returned `access_token` back to the `INSTAGRAM_ACCESS_TOKEN` repository secret and track its `expires_in` value. Once a token has expired, follow the recovery steps above.

Run the updater's offline regression tests with:

```sh
ruby test/update_instagram_posts_test.rb
```
