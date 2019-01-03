class AddFavJob < ApplicationJob
  queue_as :default

  def perform(sns_type,option,user,post,word,count,user_id)
    begin
      target_usernameList = []
      target_nameList = []
      target_imageList = []
      target_postLinkList = []
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
        when "1" #特定のキーワードを投稿
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
          target_postLinks = driver.find_elements(class: 'js-stream-tweet')
          target_postLinks.each do |e|
            target_postLinkList << "https://twitter.com#{e.attribute('data-permalink-path')}"
          end
          driver.close
        when "2" #

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
            args: ["--window-size=1920,1080","--start-maximized","--headless",'--no-sandbox','--disable-dev-shm-usage'
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
            begin
              wait.until {driver.find_element(class: 'nJAzx').displayed?}
            rescue
              next
            end
            target_usernameList << driver.find_element(class: 'nJAzx').text
            wait.until {driver.find_element(class: '_6q-tv').displayed?}
            target_imageList << driver.find_element(class: '_6q-tv').attribute(:src)
            target_postLinkList << driver.current_url
            wait.until {driver.find_element(class: 'HBoOv').displayed?}
            i += 1
            puts "----------------------"
            puts i
            driver.find_element(class: "HBoOv").click
          end
          puts target_usernameList.count
          puts target_imageList.count
          driver.close
        when "2" #
        end
      end

      target_usernameList.first(count).count.times.each do |i|
        Fav.create(
          target_postLink:target_postLinkList[i],target_postImage:target_imageList[i],
          target_username:target_usernameList[i],target_name:target_nameList[i],fav_flg:0,account_id:account_id
        )
      end
      Notification.create(
        notification_type:3,content:"いいねリストへの追加が完了しました。",isRead:0, user_id:user_id
      )
    rescue => e
      puts e
    end
  end
end
