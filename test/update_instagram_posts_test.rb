# frozen_string_literal: true

require "minitest/autorun"
require "fileutils"
require "json"
require "open3"
require "tmpdir"
require "uri"
require "yaml"

class UpdateInstagramPostsTest < Minitest::Test
  SCRIPT = File.expand_path("../scripts/update_instagram_posts.rb", __dir__)
  TOKEN = "test-token+with/special=characters"

  def setup
    @root = Dir.mktmpdir("instagram-updater-test-")
    FileUtils.mkdir_p(File.join(@root, "scripts"))
    FileUtils.mkdir_p(File.join(@root, "_data"))
    FileUtils.mkdir_p(File.join(@root, "assets/img/photography"))
    FileUtils.cp(SCRIPT, File.join(@root, "scripts/update_instagram_posts.rb"))
    @data_path = File.join(@root, "_data/photography.yml")
    @image_path = File.join(@root, "assets/img/photography/instagram-post-01.jpg")
    @original_data = {
      "handle" => "@example", "url" => "https://www.instagram.com/example/",
      "summary" => "Cached posts", "photos" => []
    }.to_yaml
    File.write(@data_path, @original_data)
    File.binwrite(@image_path, "existing-image")

    # Run the actual command with HTTP replaced before the script is loaded.
    # Every request must consume a fixture, so no live API or credentials are used.
    File.write(File.join(@root, "fake_http.rb"), <<~'RUBY')
      require "json"
      require "net/http"
      module Net
        class HTTP
          def self.start(*)
            yield new("offline.test")
          end

          def request(_request)
            fixtures = (@@fixtures ||= JSON.parse(File.read(ENV.fetch("HTTP_FIXTURES"))))
            fixture = fixtures.shift or raise "Unexpected HTTP request"
            response = Net::HTTPResponse::CODE_TO_OBJ.fetch(fixture.fetch("code"))
                        .new("1.1", fixture.fetch("code"), fixture.fetch("message", "Test response"))
            fixture.fetch("headers", {}).each { |name, value| response[name] = value }
            response.instance_variable_set(:@read, true)
            response.body = fixture.fetch("body", "")
            response
          end
        end
      end
    RUBY
  end

  def teardown
    FileUtils.remove_entry(@root)
  end

  def run_updater(responses, token: TOKEN)
    fixtures = File.join(@root, "responses.json")
    File.write(fixtures, JSON.generate(responses))
    Open3.capture2e(
      { "INSTAGRAM_ACCESS_TOKEN" => token, "INSTAGRAM_POST_LIMIT" => "9", "HTTP_FIXTURES" => fixtures },
      RbConfig.ruby, "-r", File.join(@root, "fake_http.rb"),
      File.join(@root, "scripts/update_instagram_posts.rb")
    )
  end

  def assert_failed_safely(output, status)
    refute status.success?, output
    refute_includes output, TOKEN
    refute_includes output, URI.encode_www_form_component(TOKEN)
    assert_equal @original_data, File.read(@data_path)
    assert_equal "existing-image", File.binread(@image_path)
  end

  def test_expired_token_reports_recovery_without_changing_cached_posts
    body = JSON.generate("error" => {
      "message" => "Session has expired on Friday, 21-Aug-26 01:07:57 PDT. #{TOKEN}",
      "type" => "OAuthException", "code" => 190, "error_subcode" => 0
    })
    output, status = run_updater([{ "code" => "400", "body" => body }])

    assert_failed_safely(output, status)
    assert_includes output, "OAuth error 190"
    assert_includes output, "INSTAGRAM_ACCESS_TOKEN"
    assert_includes output, "Secrets and variables > Actions"
    assert_includes output, "21-Aug-26"
    assert_includes output, "An expired token cannot be refreshed"
    refute_includes output, "RuntimeError"
  end

  def test_invalid_token_without_an_expiry_message_still_reports_reauthorization
    body = JSON.generate("error" => { "code" => 190, "message" => "Invalid OAuth access token." })
    output, status = run_updater([{ "code" => "400", "body" => body }])

    assert_failed_safely(output, status)
    assert_includes output, "Reauthorize the Instagram account"
  end

  def test_other_api_errors_are_not_reported_as_expired_tokens
    body = JSON.generate("error" => { "code" => 10, "message" => "Missing permission. #{TOKEN}" })
    output, status = run_updater([{ "code" => "400", "body" => body }])

    assert_failed_safely(output, status)
    assert_includes output, "Missing permission."
    assert_includes output, "Request failed for https://graph.instagram.com/me/media: 400"
    refute_includes output, "Reauthorize"
    refute_includes output, "access_token="
  end

  def test_non_json_errors_redact_both_plain_and_url_encoded_tokens
    body = "<html>Unavailable: #{TOKEN} #{URI.encode_www_form_component(TOKEN)}</html>"
    output, status = run_updater([{ "code" => "503", "body" => body }])

    assert_failed_safely(output, status)
    assert_includes output, "503"
    assert_includes output, "Unavailable: [REDACTED] [REDACTED]"
    refute_includes output, "JSON::ParserError"
  end

  def test_redirect_limit_errors_do_not_print_the_token
    response = { "code" => "302", "headers" => {
      "location" => "https://graph.instagram.com/me/media?access_token=#{URI.encode_www_form_component(TOKEN)}"
    } }
    output, status = run_updater(Array.new(5, response))

    assert_failed_safely(output, status)
    assert_includes output, "Too many redirects"
    refute_includes output, "access_token="
  end

  def test_missing_token_fails_before_any_request
    output, status = run_updater([], token: "")

    assert_failed_safely(output, status)
    assert_includes output, "Set INSTAGRAM_ACCESS_TOKEN"
    refute_includes output, "Unexpected HTTP request"
  end

  def test_valid_token_updates_posts_and_images
    body = JSON.generate("data" => [{
      "id" => "123", "media_type" => "IMAGE", "media_url" => "https://images.example/photo.jpg",
      "permalink" => "https://www.instagram.com/p/example/", "timestamp" => "2026-09-15T12:00:00+0000",
      "caption" => "A new photo #photography"
    }])
    output, status = run_updater([
      { "code" => "200", "body" => body },
      { "code" => "200", "body" => "new-image", "headers" => { "content-type" => "image/jpeg" } }
    ])

    assert status.success?, output
    assert_includes output, "Updated 1 Instagram posts."
    assert_equal "new-image", File.binread(@image_path)
    photo = YAML.load_file(@data_path).fetch("photos").first
    assert_equal "2026-09-15", photo.fetch("posted")
    assert_equal "https://www.instagram.com/p/example/", photo.fetch("href")
    assert_equal "Instagram post by @example: A new photo", photo.fetch("alt")
  end
end
