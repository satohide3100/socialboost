Account.all.each do |account|
 options = Selenium::WebDriver::Chrome::Options.new
 options.add_argument("--user-data-dir=./profile#{account.id}")
 options.add_argument("--headless")
 #options.add_option(:binary, "/usr/bin/google-chrome")
 options.add_argument("--user-agent=#{USER_AGENT}")
 options.add_argument('--start-maximized')
 options.add_argument("--disable-dev-shm-usage")
 options.add_argument("--no-sandbox")
 options.add_argument("--disable-setuid-sandbox")
 options.add_argument("--lang=ja")
 driver = Selenium::WebDriver.for :chrome, options: options
 wait = Selenium::WebDriver::Wait.new(:timeout => 5)
 driver.get("https://www.instagram.com/")
 driver.quit
end
