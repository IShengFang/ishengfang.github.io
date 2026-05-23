#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "net/http"
require "time"
require "uri"
require "yaml"
require "fileutils"

ROOT = File.expand_path("..", __dir__)
DATA_PATH = File.join(ROOT, "_data", "photography.yml")
IMAGE_DIR = File.join(ROOT, "assets", "img", "photography")
POST_LIMIT = Integer(ENV.fetch("INSTAGRAM_POST_LIMIT", "9"))
ACCESS_TOKEN = ENV["INSTAGRAM_ACCESS_TOKEN"].to_s.strip
FIELDS = "id,caption,media_type,media_url,permalink,thumbnail_url,timestamp,username"

abort "Set INSTAGRAM_ACCESS_TOKEN before running this script." if ACCESS_TOKEN.empty?

def fetch_response(uri, limit: 5)
  raise "Too many redirects while fetching #{uri}" if limit <= 0

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = "NewPersonalWebsite Instagram updater"
    http.request(request)
  end

  case response
  when Net::HTTPSuccess
    response
  when Net::HTTPRedirection
    fetch_response(URI(response.fetch("location")), limit: limit - 1)
  else
    raise "Request failed for #{uri}: #{response.code} #{response.message}\n#{response.body}"
  end
end

def fetch_json(uri)
  JSON.parse(fetch_response(uri).body)
end

def image_extension(content_type, uri)
  case content_type.to_s.split(";").first
  when "image/jpeg" then ".jpg"
  when "image/png" then ".png"
  when "image/webp" then ".webp"
  else
    File.extname(uri.path).downcase.empty? ? ".jpg" : File.extname(uri.path).downcase
  end
end

def yaml_quote(value)
  escaped = value.to_s.gsub("\\", "\\\\\\").gsub('"', '\"').gsub("\n", " ")
  "\"#{escaped}\""
end

def compact_caption(caption)
  first_line = caption.to_s.lines.first.to_s
  cleaned = first_line.gsub(/#[[:word:]_]+/, "").gsub(/\s+/, " ").strip
  return "" if cleaned.empty?
  return cleaned if cleaned.length <= 140

  "#{cleaned[0, 137].sub(/\s+\S*\z/, "")}..."
end

def write_photography_data(path, data)
  lines = []
  lines << "handle: #{yaml_quote(data.fetch("handle"))}"
  lines << "url: #{yaml_quote(data.fetch("url"))}"
  lines << "summary: #{yaml_quote(data.fetch("summary"))}"
  lines << "photos:"

  data.fetch("photos").each do |photo|
    lines << "  - src: #{yaml_quote(photo.fetch("src"))}"
    lines << "    href: #{yaml_quote(photo.fetch("href"))}"
    lines << "    posted: #{yaml_quote(photo.fetch("posted"))}"
    lines << "    alt: #{yaml_quote(photo.fetch("alt"))}"
  end

  File.write(path, "#{lines.join("\n")}\n")
end

photography = YAML.load_file(DATA_PATH)
FileUtils.mkdir_p(IMAGE_DIR)

media_uri = URI("https://graph.instagram.com/me/media")
media_uri.query = URI.encode_www_form(
  fields: FIELDS,
  limit: POST_LIMIT,
  access_token: ACCESS_TOKEN
)

response = fetch_json(media_uri)
posts = response.fetch("data").first(POST_LIMIT)
abort "Instagram returned no media posts." if posts.empty?

photos = posts.each_with_index.map do |post, index|
  media_url = post["media_type"] == "VIDEO" ? post["thumbnail_url"] : post["media_url"]
  media_url ||= post["media_url"]
  raise "Instagram post #{post["id"]} did not include a media URL." if media_url.to_s.empty?

  image_uri = URI(media_url)
  image_response = fetch_response(image_uri)
  extension = image_extension(image_response["content-type"], image_uri)
  basename = format("instagram-post-%02d", index + 1)
  destination = File.join(IMAGE_DIR, "#{basename}#{extension}")

  Dir[File.join(IMAGE_DIR, "#{basename}.*")].each do |existing|
    File.delete(existing) unless existing == destination
  end

  File.binwrite(destination, image_response.body)

  posted = Time.parse(post.fetch("timestamp")).strftime("%Y-%m-%d")
  caption = compact_caption(post["caption"])
  alt = if caption.empty?
          "Instagram post by #{photography.fetch("handle")} from #{posted}."
        else
          "Instagram post by #{photography.fetch("handle")}: #{caption}"
        end

  {
    "src" => "/assets/img/photography/#{File.basename(destination)}",
    "href" => post["permalink"] || photography.fetch("url"),
    "posted" => posted,
    "alt" => alt
  }
end

photography["photos"] = photos
write_photography_data(DATA_PATH, photography)

puts "Updated #{photos.length} Instagram posts."
