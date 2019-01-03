class AddFollowJob < ApplicationJob
  queue_as :default

  def perform(sns_type,option,user,post,word,count,user_id)
    begin
      target_usernameList = []
      target_nameList = []
      target_imageList = []
      if sns_type == "1"
        @account = Account.find_by(user_id:user_id,sns_type:1,active_flg:1)
        account_id = @account.id
        username = @account.username
        pass = @account.pass
        require 'selenium-webdriver'
        caps = Selenium::WebDriver::Remote::Capabilities.chrome(
          "chromeOptions" => {
          binary: "/usr/bin/google-chrome",
          args: ["--window-size=1920,1080","--start-maximized","--headless",'--no-sandbox','--disable-dev-shm-usage'
          ]
          }
        )
        driver = Selenium::WebDriver.for :chrome, desired_capabilities: caps
        wait = Selenium::WebDriver::Wait.new(:timeout => 5)
        case option
        when "1" #指定したユーザーのフォロワーを追加
          driver.get("https://twitter.com/login")
          wait.until {driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[1]/input').displayed?}
          driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[1]/input').send_keys(username)
          wait.until {driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[2]/input').displayed?}
          driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[2]/input').send_keys(pass)
          driver.find_element(:xpath, '//*[@id="page-container"]/div/div[1]/form/div[2]/button').click
          driver.navigate.to("https://twitter.com/#{user}/followers")
          gridCount = 0
          while gridCount < count
            wait.until {driver.find_elements(class: 'u-size1of2').last.displayed?}
            gridCount = driver.find_elements(class: 'u-size1of2').count
            driver.find_element(class: "GridTimeline-end").location_once_scrolled_into_view
          end
          target_usernames = driver.find_elements(xpath: '//*[@class="ProfileCard-screenname"]/a/span/b')
          target_usernames.each do |e|
            target_usernameList << e.text
          end
          target_names = driver.find_elements(class: 'ProfileNameTruncated-link')
          target_names.delete_at(0)
          target_names.each do |e|
            target_nameList << e.text
          end
          target_images = driver.find_elements(class: "ProfileCard-avatarImage")
          target_images.each do |e|
            target_imageList << e.attribute(:src)
          end
          driver.close
        when "2" #指定したユーザーのフォローを追加
          driver.get("https://twitter.com/login")
          wait.until {driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[1]/input').displayed?}
          driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[1]/input').send_keys(username)
          wait.until {driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[2]/input').displayed?}
          driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[2]/input').send_keys(pass)
          driver.find_element(:xpath, '//*[@id="page-container"]/div/div[1]/form/div[2]/button').click
          driver.navigate.to("https://twitter.com/#{user}/following")
          gridCount = 0
          while gridCount < count
            wait.until {driver.find_elements(class: 'u-size1of2').last.displayed?}
            gridCount = driver.find_elements(class: 'u-size1of2').count
            driver.find_element(class: "GridTimeline-end").location_once_scrolled_into_view
          end
          target_usernames = driver.find_elements(xpath: '//*[@class="ProfileCard-screenname"]/a/span/b')
          target_usernames.each do |e|
            target_usernameList << e.text
          end
          target_names = driver.find_elements(class: 'ProfileNameTruncated-link')
          target_names.delete_at(0)
          target_names.each do |e|
            target_nameList << e.text
          end
          target_images = driver.find_elements(class: "ProfileCard-avatarImage")
          target_images.each do |e|
            target_imageList << e.attribute(:src)
          end
          driver.close
        when "3" #特定のキーワードを投稿しているユーザーを追加
          driver.get("https://twitter.com/search?f=tweets&vertical=news&q=#{word}&src=typd")
          gridCount = 0
          while gridCount < count
            wait.until {driver.find_elements(class: 'js-stream-item').last.displayed?}
            gridCount = driver.find_elements(class: 'js-stream-item').count
            driver.find_element(class: "stream-footer").location_once_scrolled_into_view
          end
          target_usernames = driver.find_elements(xpath: '//*[@class="stream-item-header"]/a/span[2]/b')
          target_usernames.each do |e|
            puts e.text
            target_usernameList << e.text
          end
          target_names = driver.find_elements(xpath: '//*[@class="stream-item-header"]/a/span[1]/strong')
          target_names.each do |e|
            target_nameList << e.text
          end
          target_images = driver.find_elements(xpath: '//*[@class="stream-item-header"]/a/img')
          target_images.each do |e|
            target_imageList << e.attribute(:src)
          end
          puts target_usernameList.count
          puts target_nameList.count
          puts target_imageList.count
          driver.close
        end
      elsif sns_type == "2"
        require 'selenium-webdriver'
        @account = Account.find_by(user_id:user_id,sns_type:2,active_flg:1)
        account_id = @account.id
        username = @account.username
        pass = @account.pass
        case option
        when "1"
          caps = Selenium::WebDriver::Remote::Capabilities.chrome(
            "chromeOptions" => {
            binary: "/usr/bin/google-chrome",
            args: ["--window-size=375,667","--user-agent=#{USER_AGENT}","--start-maximized","--headless",'--no-sandbox','--disable-dev-shm-usage']
            }
          )
          driver = Selenium::WebDriver.for :chrome, desired_capabilities: caps
          wait = Selenium::WebDriver::Wait.new(:timeout => 5)
          driver.get("https://www.instagram.com/accounts/login/?hl=ja")
          wait.until {driver.find_element(name: 'username').displayed?}
          driver.find_element(name: 'username').send_keys(username)
          wait.until {driver.find_element(name: 'password').displayed?}
          driver.find_element(name: 'password').send_keys(pass)
          driver.find_elements(tag_name: "button")[2].click
          #ßdriver.find_elements(class: 'sqdOP')[1].click
          sleep(2)
          driver.navigate.to("https://www.instagram.com/#{user}/")
          wait.until {driver.find_element(tag_name: 'a').displayed?}
          driver.find_element(tag_name: 'a').click
          gridCount = 0
          c = 0
          while gridCount < count
            sleep(2)
            puts gridCount = driver.find_elements(tag_name: "li").count
            c += 1
            if c > 10
              break
            end
          end
          target_usernames = driver.find_elements(class: 'FPmhX')
          target_usernames.each do |e|
            puts e.text
            target_usernameList << e.text
          end
          target_names = driver.find_elements(class: 'wFPL8 ')
          target_names.each do |e|
            target_nameList << e.text
          end
          target_images = driver.find_elements(class: '_6q-tv')
          target_images.each do |e|
            target_imageList << e.attribute(:src)
          end
          driver.close
        when "2"
          caps = Selenium::WebDriver::Remote::Capabilities.chrome(
            "chromeOptions" => {
            binary: "/usr/bin/google-chrome",
            args: ["--window-size=375,667","--user-agent=#{USER_AGENT}","--start-maximized","--headless",'--no-sandbox','--disable-dev-shm-usage']
            }
          )
          driver = Selenium::WebDriver.for :chrome, desired_capabilities: caps
          wait = Selenium::WebDriver::Wait.new(:timeout => 5)
          driver.get("https://www.instagram.com/accounts/login/?hl=ja")
          wait.until {driver.find_element(name: 'username').displayed?}
          driver.find_element(name: 'username').send_keys(username)
          wait.until {driver.find_element(name: 'password').displayed?}
          driver.find_element(name: 'password').send_keys(pass)
          driver.find_elements(tag_name: "button")[2].click
          sleep(2)
          driver.get("https://www.instagram.com/#{user}/")
          wait.until {driver.find_elements(tag_name: 'a')[1].displayed?}
          driver.find_elements(tag_name: 'a')[1].click
          gridCount = 0
          c = 0
          while gridCount < count
            sleep(3)
            puts gridCount = driver.find_elements(tag_name: "li").count
            c += 1
            if c > 10
              break
            end
          end
          target_usernames = driver.find_elements(class: 'FPmhX')
          target_usernames.each do |e|
            puts e.text
            target_usernameList << e.text
          end
          target_names = driver.find_elements(class: 'wFPL8 ')
          target_names.each do |e|
            target_nameList << e.text
          end
          target_images = driver.find_elements(class: '_6q-tv')
          target_images.each do |e|
            target_imageList << e.attribute(:src)
          end
          driver.close
        when "3"
          caps = Selenium::WebDriver::Remote::Capabilities.chrome(
            "chromeOptions" => {
            binary: "/usr/bin/google-chrome",
            args: [
              "--start-maximized","--headless",'--no-sandbox','--disable-dev-shm-usage'
            ]
            }
          )
          driver = Selenium::WebDriver.for :chrome, desired_capabilities: caps
          wait = Selenium::WebDriver::Wait.new(:timeout => 5)
          driver.get("https://www.instagram.com/explore/tags/#{word}/")
          i = 0
          wait.until {driver.find_element(class: 'v1Nh3').displayed?}
          driver.find_element(class: 'v1Nh3').click
          current_url = ""
          while count > i
            wait.until {driver.find_element(class: 'nJAzx').displayed?}
            target_usernameList << driver.find_element(class: 'nJAzx').text
            wait.until {driver.find_element(class: '_6q-tv').displayed?}
            target_imageList << driver.find_element(class: '_6q-tv').attribute(:src)
            wait.until {driver.find_element(class: 'HBoOv').displayed?}
            i += 1
            puts "----------------------"
            puts i
            driver.find_element(class: "HBoOv").click
          end
          puts target_usernameList.count
          puts target_imageList.count
          driver.close
        when "4"
          caps = Selenium::WebDriver::Remote::Capabilities.chrome(
            "chromeOptions" => {
            binary: "/usr/bin/google-chrome",
            args: [
              "--start-maximized","--headless",'--no-sandbox','--disable-dev-shm-usage'
            ]
            }
          )
          driver = Selenium::WebDriver.for :chrome, desired_capabilities: caps
          wait = Selenium::WebDriver::Wait.new(:timeout => 5)
          driver.get(post)
          wait.until {driver.find_element(class: 'zV_Nj').displayed?}
          driver.find_elements(tag_name: "footer").last.location_once_scrolled_into_view
          driver.find_element(class: 'zV_Nj').click
          gridCount = 0
          while gridCount < count
            sleep(1)
            puts gridCount = driver.find_elements(class: "wo9IH").count
            driver.find_elements(class: "wo9IH").last.location_once_scrolled_into_view
          end
          target_usernames = driver.find_elements(xpath: '/html/body/div[3]/div/div[2]/div/div/div[2]/ul/div/li/div/div[1]/div[2]/div[1]/a')
          target_usernames.each do |e|
            puts e.text
            target_usernameList << e.text
          end
          target_names = driver.find_elements(xpath: '/html/body/div[3]/div/div[2]/div/div/div[2]/ul/div/li/div/div[1]/div[2]/div[2]')
          target_names.each do |e|
            target_nameList << e.text
          end
          target_images = driver.find_elements(xpath: '/html/body/div[3]/div/div[2]/div/div/div[2]/ul/div/li/div/div[1]/div[1]/a/img')
          target_images.each do |e|
            target_imageList << e.attribute(:src)
          end
          driver.close
        end
      end
      target_usernameList.first(count).count.times.each do |i|
        Follow.create(
          target_username:target_usernameList[i],target_name:target_nameList[i],target_image:target_imageList[i],follow_flg:0,account_id:account_id
        )
      end
      Notification.create(
        notification_type:2,content:"フォローリストへの追加が完了しました。",isRead:0, user_id:user_id
      )
    rescue => e
      puts e
    end
  end
end
