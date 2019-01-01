namespace :main do

  task :seleniumfix => :environment do
    require 'selenium-webdriver'
    caps = Selenium::WebDriver::Remote::Capabilities.chrome(
      "chromeOptions" => {
      binary: "/app/.apt/usr/bin/google-chrome",
      args: [
        "--window-size=1920,1080","--start-maximized","--headless",'--no-sandbox'
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
      driver.close
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
      driver.close
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
