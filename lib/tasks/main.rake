namespace :main do
USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36"
  task :test => :environment do
    caps = Selenium::WebDriver::Chrome::Options.new(args: ["--headless", "--user-data-dir=./profile44"])
    driver = Selenium::WebDriver.for :chrome, options: caps
    wait = Selenium::WebDriver::Wait.new(:timeout => 3)
    fav = Fav.find_by('account_id = ? and fav_flg = ? and target_postLink != ?',44,0,"")
    unless fav
      driver.quit
      next
    end
    begin
      puts fav.target_postLink
      driver.get(fav.target_postLink)
      wait.until {driver.find_element(class: "glyphsSpriteHeart__outline__24__grey_9").displayed?}
      puts fav_text = driver.find_element(class: "glyphsSpriteHeart__outline__24__grey_9").attribute("aria-label")
      if fav_text.include?("取り消す")
        fav.destroy
        driver.quit
        next
      end
      puts driver.find_element(tag_name:"body").text
      driver.execute_script('document.getElementsByClassName("glyphsSpriteHeart__outline__24__grey_9")[0].click();')
    rescue
      fav.destroy
      driver.quit
      next
    end
    fav.update(fav_flg:1)
    line_notify = LineNotify.new("Sq7cScOUtjJ0Cqbl3C1QX7Z6aLlFDoX20qRJUBI12tS")
    options = {message: "\n#{fav.target_postLink}\nをいいねしました。"}
    line_notify.send(options)
    driver.quit
  end

  task :follow => :environment do
    require 'line_notify'
    require 'selenium-webdriver'
    require 'benchmark'

    account_ids = Follow.select(:account_id).distinct
    500.times.each do |i|
      result = Benchmark.realtime do
        Account.where(user_id:3).where(id:account_ids).each do |account|
          options = Selenium::WebDriver::Chrome::Options.new
          options.headless!
          #options.add_option(:binary, "/usr/bin/google-chrome")
          options.add_argument("--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36")
          options.add_argument('--start-maximized')
          options.add_argument("--disable-dev-shm-usage")
          options.add_argument("--no-sandbox")
          options.add_argument("--disable-setuid-sandbox")
          options.add_argument("--user-data-dir=./profile#{account.id}")
          driver = Selenium::WebDriver.for :chrome, options: options
          wait = Selenium::WebDriver::Wait.new(:timeout => 3)
          follow = Follow.find_by('account_id = ? and follow_flg = ?',account.id,0)
          unless follow
            driver.quit
            next
          end
          case account.sns_type
          when 1
            driver.get("https://twitter.com/#{follow.target_username}")
            wait.until {driver.find_element(class: 'user-actions-follow-button').displayed?}
            follow_text = driver.find_element(class: 'user-actions-follow-button').text
            puts follow_text
            if follow_text.include?("フォロー中")
              follow.destroy
              driver.quit
              next
            end
            wait.until {driver.find_element(class: "follow-text").displayed?}
            driver.find_element(class: "follow-text").click
          when 2
            driver.get("https://www.instagram.com/#{follow.target_username}")
            wait.until {driver.find_element(tag_name: "button").displayed?}
            puts follow_text = driver.find_element(tag_name: "button").text
            if follow_text.include?("フォロー中")
              follow.destroy
              driver.quit
              next
            end
            driver.find_element(tag_name: "button").click
          end
          line_notify = LineNotify.new("Sq7cScOUtjJ0Cqbl3C1QX7Z6aLlFDoX20qRJUBI12tS")
          options = {message: "\n#{account.profile_name}\n@#{follow.target_username}をフォローしました。"}
          line_notify.send(options)
          follow.update(follow_flg:1)
          driver.quit
        end
      end
      if result < 173
        sleep(173 - result)
      end
    end
  end

  task :fav => :environment do
    require 'line_notify'
    require 'selenium-webdriver'
    require 'benchmark'

    account_ids = Fav.select(:account_id).distinct
    500.times.each do |i|
      result = Benchmark.realtime do
        Account.where(user_id:3).where(id:account_ids).each do |account|
          options = Selenium::WebDriver::Chrome::Options.new
          #options.add_option(:binary, "/usr/bin/google-chrome")
          #options.add_argument("--headless")
          options.add_argument("--disable-gpu")
          options.add_argument("--windo-size=1929,2160")
          options.add_argument("--user-agent=#{USER_AGENT}")
          options.add_argument('--start-maximized')
          options.add_argument("--disable-dev-shm-usage")
          options.add_argument("--no-sandbox")
          options.add_argument("--disable-setuid-sandbox")
          options.add_argument("--lang=ja")
          options.add_argument("--user-data-dir=./profile#{account.id}")
          driver = Selenium::WebDriver.for :chrome, options: options
          wait = Selenium::WebDriver::Wait.new(:timeout => 5)
          fav = Fav.find_by('account_id = ? and fav_flg = ? and target_postLink != ?',account.id,0,"")
          unless fav
            driver.quit
            next
          end
          begin
            case account.sns_type
            when 1
              driver.get(fav.target_postLink)
              begin
                wait.until {driver.find_element(class: 'js-actionFavorite').displayed?}
              rescue
                fav.destroy
                driver.quit
                next
              end
              fav_text = driver.find_element(class: 'js-actionFavorite').text
              puts fav_text
              if fav_text.include?("取り消す")
                fav.destroy
                driver.quit
                next
              end
              driver.find_element(class: 'js-actionFavorite').location_once_scrolled_into_view
              driver.find_element(class: 'js-actionFavorite').click
            when 2
              puts fav.target_postLink
              driver.get(fav.target_postLink)
              wait.until {driver.find_element(class: "glyphsSpriteHeart__outline__24__grey_9").displayed?}
              puts fav_text = driver.find_element(class: "glyphsSpriteHeart__outline__24__grey_9").attribute("aria-label")
              if fav_text.include?("取り消す")
                fav.destroy
                driver.quit
                next
              end
              puts driver.find_element(tag_name:"body").text
              driver.execute_script('document.getElementsByClassName("glyphsSpriteHeart__outline__24__grey_9")[0].click();')
            end
          rescue
            fav.destroy
            driver.quit
            next
          end
          line_notify = LineNotify.new("Sq7cScOUtjJ0Cqbl3C1QX7Z6aLlFDoX20qRJUBI12tS")
          options = {message: "\n#{account.profile_name}(ID:#{account.id})\n#{fav.target_postLink}\nをいいねしました。"}
          line_notify.send(options)
          fav.update(fav_flg:1)
          driver.quit
        end
      end
      if result < 173
        sleep(173 - result)
      end
    end
  end

  task :analyze => :environment do
    require "mechanize"
    Account.all.each do |account|
      follower_count = 0
      follow_count = 0
      post_count = 0
      profile_image = ""
      case account.sns_type
      when 1
        agent = Mechanize.new
        page = agent.get("https://twitter.com/#{account.username}")
        puts profile_image = page.at(".ProfileAvatar-image").get_attribute(:src)
        puts follower_count = page.search(".ProfileNav-value")[2].get_attribute("data-count")
        puts follow_count = page.search(".ProfileNav-value")[1].get_attribute("data-count")
        puts post_count = page.search(".ProfileNav-value")[0].get_attribute("data-count")
      when 2
        agent = Mechanize.new
        page = agent.get("https://www.instagram.com/#{account.username}/")
        page.search("meta").each do |e|
          if e.get_attribute(:property) == "og:image"
            puts profile_image = e.get_attribute(:content)
          end
          if e.get_attribute(:property) == "og:description"
            data = e.get_attribute(:content).split(" ")
            puts follower_count = data[0].gsub(/[^\d]/, "").to_i
            puts follow_count = data[2].gsub(/[^\d]/, "").to_i
            puts post_count = data[4].gsub(/[^\d]/, "").to_i
          end
        end
      end
      Analyze.create(
        follow_count:follow_count,follower_count:follower_count,post_count:post_count,
        profile_image:profile_image,account_id:account.id
      )
    end
  end

  task :profile => :environment do
    require 'selenium-webdriver'
    Account.where(sns_type:2).each do |account|
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument("--user-data-dir=./profile#{account.id}")
      #options.add_argument("--headless")
      options.add_option(:binary, "/usr/bin/google-chrome")
      options.add_argument("--user-agent=#{USER_AGENT}")
      options.add_argument('--start-maximized')
      options.add_argument("--disable-dev-shm-usage")
      options.add_argument("--no-sandbox")
      options.add_argument("--disable-setuid-sandbox")
      options.add_argument("--lang=ja")
      driver = Selenium::WebDriver.for :chrome, options: options
      wait = Selenium::WebDriver::Wait.new(:timeout => 5)
      case account.sns_type
      when 1
        driver.get("https://twitter.com/login?lang=ja")
        current = driver.current_url
        puts current
        wait.until {driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[1]/input').displayed?}
        driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[1]/input').send_keys(account.username)
        wait.until {driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[2]/input').displayed?}
        driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[2]/input').send_keys(account.pass)
        driver.find_element(:xpath, '//*[@id="page-container"]/div/div[1]/form/div[2]/button').click
        wait.until {driver.current_url != current}
      when 2
        driver.get("https://www.instagram.com/accounts/login/?hl=ja")
        current = driver.current_url
        puts current
        begin
          wait.until {driver.find_element(name: 'username').displayed?}
          driver.find_element(name: 'username').send_keys(account.username)
          wait.until {driver.find_element(name: 'password').displayed?}
          driver.find_element(name: 'password').send_keys(account.pass)
          driver.find_element(name: 'password').send_keys(:return)
          wait.until {driver.current_url != current}
          current = driver.current_url
          puts current
        rescue
          driver.quit
          next
        end
      end
      driver.navigate.to("https://www.instagram.com/")
      driver.navigate.to("https://www.instagram.com/#{account.username}")
      driver.quit
    end
  end



  task :reply => :environment do
    require 'selenium-webdriver'
    options = Selenium::WebDriver::Chrome::Options.new
    #options.headless!
    #options.add_option(:binary, "/usr/bin/google-chrome")
    options.add_argument("--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36")
    options.add_argument('--start-maximized')
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-setuid-sandbox")
    driver = Selenium::WebDriver.for :chrome, options: options
    wait = Selenium::WebDriver::Wait.new(:timeout => 5)
    driver.get("https://www.instagram.com/accounts/login")
    wait.until {driver.find_element(name: 'username').displayed?}
    driver.find_element(name: 'username').send_keys("sato__hideki")
    wait.until {driver.find_element(name: 'password').displayed?}
    driver.find_element(name: 'password').send_keys("oneokrock")
    wait.until {driver.find_elements(tag_name: "button")[1].displayed?}
    driver.find_elements(tag_name: "button")[1].click
    sleep(2)
    driver.navigate.to("https://www.instagram.com/p/BqyP0yFnh_Th2O7MkknO6JxcxAc_ipRqz5qQOk0/")
    wait.until {driver.find_element(tag_name: "textarea").displayed?}
    driver.find_element(tag_name: "textarea").click
    driver.find_element(tag_name: "textarea").send_keys("自動コメントテスト")
    driver.find_element(tag_name: "textarea").send_keys(:enter)
    sleep(2)
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

  task :unfollow => :environment do

  end

  task :post => :environment do

  end





end
