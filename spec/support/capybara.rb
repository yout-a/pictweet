# spec/support/capybara.rb
require "capybara/rspec"

def detect_browser_binary
  # 優先: 環境変数で明示
  return ENV["CHROME_BIN"] if ENV["CHROME_BIN"].present?

  # 選択: ENV["BROWSER"] に応じて探す
  case (ENV["BROWSER"] || "chromium").downcase
  when "chrome", "google-chrome"
    %w[/usr/bin/google-chrome /usr/bin/google-chrome-stable /opt/google/chrome/google-chrome].find { |p| File.exist?(p) }
  else # "chromium"
    %w[/usr/bin/chromium-browser /snap/bin/chromium].find { |p| File.exist?(p) }
  end
end

Capybara.register_driver :selenium_chrome_headless do |app|
  opts = Selenium::WebDriver::Chrome::Options.new
  # opts.add_argument("--headless=new")
  opts.add_argument("--no-sandbox")
  opts.add_argument("--disable-dev-shm-usage")
  opts.add_argument("--disable-gpu")
  opts.add_argument("--window-size=1280,800")

  bin = detect_browser_binary
  raise "Chrome/Chromium binary not found. Set CHROME_BIN or install chromium-browser / google-chrome." unless bin
  warn "[Capybara] Using Chrome binary: #{bin.inspect}"
  opts.binary = bin

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: opts)
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium_chrome_headless
  end
end
