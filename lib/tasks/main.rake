namespace :main do
  USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36'

  task :test2 => :environment do
    sleep(10)
  end

  task :test => :environment do
    require 'selenium-webdriver'
    options = Selenium::WebDriver::Chrome::Options.new
    options.headless!
    options.add_option(:binary, "/usr/bin/google-chrome")
    options.add_argument("--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36")
    options.add_emulation(device_name: 'iPhone 8')
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-setuid-sandbox")
    options.add_argument("--lang=ja")
    driver = Selenium::WebDriver.for :chrome, options: options
    wait = Selenium::WebDriver::Wait.new(:timeout => 5)
    driver.get("https://www.instagram.com/accounts/login")
    puts body = driver.find_element(tag_name: "body").text
    wait.until {driver.find_element(name: 'username').displayed?}
    driver.find_element(name: 'username').send_keys("sato__hideki")
    wait.until {driver.find_element(name: 'password').displayed?}
    driver.find_element(name: 'password').send_keys("oneokrock")
    wait.until {driver.find_elements(tag_name: "button")[2].displayed?}
    puts driver.find_elements(tag_name: "button")[0].text
    puts driver.find_elements(tag_name: "button")[1].text
    puts driver.find_elements(tag_name: "button")[2].text
    driver.find_elements(tag_name: "button")[2].click
    sleep(3)
    puts "------------"
    sleep(30)
    puts driver.find_elements(tag_name: "button")[0]
    puts driver.find_elements(tag_name: "button")[1]
    driver.find_elements(tag_name: "button")[0].click
    sleep(2)
    puts body = driver.find_element(tag_name: "body").text

  end

  task :seleniumfix => :environment do
    require 'selenium-webdriver'
    caps = Selenium::WebDriver::Remote::Capabilities.chrome(
      "chromeOptions" => {
      binary: "/usr/bin/google-chrome",
      args: ["--window-size=1920,1080","--start-maximized","--headless",'--no-sandbox','--disable-dev-shm-usage'
      ]
      }
    )
    driver = Selenium::WebDriver.for :chrome, desired_capabilities: caps
    driver.quit
  end

  task :follow => :environment do
    require 'selenium-webdriver'
    todayHour = Time.new.hour
    @twitterAccounts = Account.where(sns_type:1)
    @instagramAccounts = Account.where(sns_type:2)
    @twitterAccounts.each do |account|
      @followSetting = FollowSetting.find_by(account_id:account.id)
      if @followSetting == nil
        next
      end
      if todayHour % @followSetting.interval != 0
        next
      end
      caps = Selenium::WebDriver::Remote::Capabilities.chrome(
        "chromeOptions" => {
        #binary: "/app/.apt/usr/bin/google-chrome",
        args: [
          #"--window-size=1920,1080","--start-maximized","--headless",'--no-sandbox',
          "--user-data-dir=./profile#{account.id}"
        ]
        }
      )
      driver = Selenium::WebDriver.for :chrome, desired_capabilities: caps
      wait = Selenium::WebDriver::Wait.new(:timeout => 5)
      @follows = Follow.where(account_id:account.id)
      @follows.each do |follow|
        driver.navigate.to("https://twitter.com/#{follow.target_username}")
        puts follow.target_username
        #follow.update(follow_flg:1)
      end
      driver.quit
    end

    @instagramAccounts.each do |account|
      @followSetting = FollowSetting.find_by(account_id:account.id)
      if @followSetting == nil
        next
      end
      if todayHour % @followSetting.interval != 0
        next
      end
      caps = Selenium::WebDriver::Remote::Capabilities.chrome(
        "chromeOptions" => {
        #binary: "/app/.apt/usr/bin/google-chrome",
        args: [
          #"--window-size=1920,1080","--start-maximized","--headless",'--no-sandbox',
          "--user-data-dir=./profile#{account.id}"
        ]
        }
      )
      driver = Selenium::WebDriver.for :chrome, desired_capabilities: caps
      wait = Selenium::WebDriver::Wait.new(:timeout => 5)
      @follows = Follow.where(account_id:account.id)
      driver.get("https://www.instagram.com/")
      @follows.each do |follow|
        driver.navigate.to("https://www.instagram.com/#{follow.target_username}")
        puts follow.target_username
        #follow.update(follow_flg:1)
      end
      driver.quit
    end
  end

  task :unfollow => :environment do

  end

  task :post => :environment do

  end

  task :fav => :environment do

  end

  task :analyze => :environment do

  end

end
