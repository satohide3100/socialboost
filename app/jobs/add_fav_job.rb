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
        options = Selenium::WebDriver::Chrome::Options.new
        options.headless!
        options.add_option(:binary, "/usr/bin/google-chrome")
        options.add_argument("--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36")
        options.add_argument('--start-maximized')
        options.add_argument("--disable-dev-shm-usage")
        options.add_argument("--no-sandbox")
        options.add_argument("--disable-setuid-sandbox")
        driver = Selenium::WebDriver.for :chrome, options: options
        wait = Selenium::WebDriver::Wait.new(:timeout => 3)
        case option
        when "1" #特定のキーワードを投稿
          driver.get("https://twitter.com/search?f=tweets&vertical=news&q=#{word}&src=typd")
          gridCount = 0
          scrollCount = 0
          unscrollCount = 0
          while gridCount < count
            wait.until {driver.find_elements(class: 'js-stream-item').last.displayed?}
            if gridCount == driver.find_elements(class: 'js-stream-item').count
              unscrollCount += 1
            end
            gridCount = driver.find_elements(class: 'js-stream-item').count
            driver.find_element(class: "stream-footer").location_once_scrolled_into_view
            scrollCount += 1
            if unscrollCount == 20
              break
            end
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
          saveCount = 0
          target_usernameList.first(count).count.times.each do |i|
            @fav = Fav.new(
              target_postLink:target_postLinkList[i],target_postImage:target_imageList[i],
              target_username:target_usernameList[i],target_name:target_nameList[i],fav_flg:0,account_id:account_id
            )
            if @fav.save
              saveCount += 1
            end
          end
          Notification.create(
            notification_type:3,content:"「#{word}」の投稿をしている#{saveCount}投稿をいいねリストへ追加しました。",isRead:0, user_id:user_id
          )
          driver.quit
        when "2" #あるユーザーのフォロワー〇〇人の最新投稿を追加
          driver.get("https://twitter.com/login")
          wait.until {driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[1]/input').displayed?}
          driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[1]/input').send_keys(username)
          wait.until {driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[2]/input').displayed?}
          driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[2]/input').send_keys(pass)
          driver.find_element(:xpath, '//*[@id="page-container"]/div/div[1]/form/div[2]/button').click
          driver.navigate.to("https://twitter.com/#{user}/followers")
          gridCount = 0
          wait.until {driver.find_elements(class: "ProfileNav-value")[1].displayed?}
          follower = driver.find_elements(class: "ProfileNav-value")[1].text.gsub(/[^\d]/, "").to_i
          if follower < count
            while gridCount != follower
              wait.until {driver.find_elements(class: 'u-size1of2').last.displayed?}
              gridCount = driver.find_elements(class: 'u-size1of2').count
              driver.find_element(class: "GridTimeline-end").location_once_scrolled_into_view
            end
          else
            while gridCount < count
              wait.until {driver.find_elements(class: 'u-size1of2').last.displayed?}
              gridCount = driver.find_elements(class: 'u-size1of2').count
              driver.find_element(class: "GridTimeline-end").location_once_scrolled_into_view
            end
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
          target_usernameList.each do |e|
            driver.navigate.to("https://twitter.com/#{e}")
            begin
              wait.until {driver.find_element(class: 'js-stream-tweet').displayed?}
            rescue
              next
            end
            target_postLinkList << "https://twitter.com#{driver.find_element(class: 'js-stream-tweet').attribute('data-permalink-path')}"
          end
          driver.quit
          saveCount = 0
          target_usernameList.first(count).count.times.each do |i|
            @fav = Fav.new(
              target_postLink:target_postLinkList[i],target_postImage:target_imageList[i],
              target_username:target_usernameList[i],target_name:target_nameList[i],fav_flg:0,account_id:account_id
            )
            if @fav.save
              saveCount += 1
            end
          end
          Notification.create(
            notification_type:3,content:"@#{user}のフォロワー#{count}人の最新投稿を#{saveCount}件いいねリストへ追加しました。",isRead:0, user_id:user_id
          )
        when "3"
          driver.get("https://twitter.com/login")
          wait.until {driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[1]/input').displayed?}
          driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[1]/input').send_keys(username)
          wait.until {driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[2]/input').displayed?}
          driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[2]/input').send_keys(pass)
          driver.find_element(:xpath, '//*[@id="page-container"]/div/div[1]/form/div[2]/button').click
          driver.navigate.to("https://twitter.com/#{user}/following")
          gridCount = 0
          wait.until {driver.find_elements(class: "ProfileNav-value")[0].displayed?}
          follow = driver.find_elements(class: "ProfileNav-value")[0].text.gsub(/[^\d]/, "").to_i
          if follow < count
            while gridCount != follow
              wait.until {driver.find_elements(class: 'u-size1of2').last.displayed?}
              gridCount = driver.find_elements(class: 'u-size1of2').count
              driver.find_element(class: "GridTimeline-end").location_once_scrolled_into_view
            end
          else
            while gridCount < count
              wait.until {driver.find_elements(class: 'u-size1of2').last.displayed?}
              gridCount = driver.find_elements(class: 'u-size1of2').count
              driver.find_element(class: "GridTimeline-end").location_once_scrolled_into_view
            end
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
          target_usernameList.each do |e|
            driver.navigate.to("https://twitter.com/#{e}")
            begin
              wait.until {driver.find_element(class: 'js-stream-tweet').displayed?}
            rescue
              next
            end
            target_postLinkList << "https://twitter.com#{driver.find_element(class: 'js-stream-tweet').attribute('data-permalink-path')}"
          end
          driver.quit
          saveCount = 0
          target_usernameList.first(count).count.times.each do |i|
            @fav = Fav.new(
              target_postLink:target_postLinkList[i],target_postImage:target_imageList[i],
              target_username:target_usernameList[i],target_name:target_nameList[i],fav_flg:0,account_id:account_id
            )
            if @fav.save
              saveCount += 1
            end
          end
          Notification.create(
            notification_type:3,content:"@#{user}のフォロー#{count}人の最新投稿を#{saveCount}件いいねリストへ追加しました。",isRead:0, user_id:user_id
          )
        end
      elsif sns_type == "2"
        require 'selenium-webdriver'
        @account = Account.find_by(user_id:user_id,sns_type:2,active_flg:1)
        account_id = @account.id
        username = @account.username
        pass = @account.pass
        case option
        when "1"
          options = Selenium::WebDriver::Chrome::Options.new
          options.headless!
          options.add_option(:binary, "/usr/bin/google-chrome")
          options.add_argument("--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36")
          options.add_argument('--start-maximized')
          options.add_argument("--disable-dev-shm-usage")
          options.add_argument("--no-sandbox")
          options.add_argument("--disable-setuid-sandbox")
          driver = Selenium::WebDriver.for :chrome, options: options
          wait = Selenium::WebDriver::Wait.new(:timeout => 5)
          driver.get("https://www.instagram.com/explore/tags/#{word}/")
          i = 0
          wait.until {driver.find_element(xpath: '//*[@id="react-root"]/section/main/article/div[1]/div/div/div[1]/div[1]/a').displayed?}
          driver.find_element(xpath: '//*[@id="react-root"]/section/main/article/div[1]/div/div/div[1]/div[1]/a').click
          current_url = ""
          while count > i
            wait.until {driver.find_element(class: 'nJAzx').displayed?}
            target_usernameList << driver.find_element(class: 'nJAzx').text
            wait.until {driver.find_element(class: '_6q-tv').displayed?}
            target_imageList << driver.find_element(class: '_6q-tv').attribute(:src)
            begin
              wait.until {driver.find_element(class: 'HBoOv').displayed?}
            rescue
              break
            end
            i += 1
            puts i
            driver.find_element(class: "HBoOv").click
          end
          driver.quit
          saveCount = 0
          target_usernameList.first(count).count.times.each do |i|
            @fav = Fav.new(
              target_postLink:target_postLinkList[i],target_postImage:target_imageList[i],
              target_username:target_usernameList[i],target_name:target_nameList[i],fav_flg:0,account_id:account_id
            )
            if @fav.save
              saveCount += 1
            end
          end
          Notification.create(
            notification_type:3,content:"「##{word}」の投稿#{saveCount}件いいねリストへ追加しました。",isRead:0, user_id:user_id
          )
        when "2" #
          options = Selenium::WebDriver::Chrome::Options.new
          options.headless!
          options.add_option(:binary, "/usr/bin/google-chrome")
          options.add_argument("--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36")
          options.add_emulation(device_name: 'iPhone 8')
          options.add_argument("--disable-dev-shm-usage")
          options.add_argument("--no-sandbox")
          options.add_argument("--disable-setuid-sandbox")
          options.add_argument("--disable-dev-shm-usage")
          options.add_argument("--no-sandbox")
          options.add_argument("--disable-setuid-sandbox")
          driver = Selenium::WebDriver.for :chrome, options: options
          wait = Selenium::WebDriver::Wait.new(:timeout => 5)
          driver.get("https://www.instagram.com/accounts/login/?hl=ja")
          wait.until {driver.find_element(name: 'username').displayed?}
          driver.find_element(name: 'username').send_keys(username)
          wait.until {driver.find_element(name: 'password').displayed?}
          driver.find_element(name: 'password').send_keys(pass)
          driver.find_elements(tag_name: "button")[2].click
          #ßdriver.find_elements(class: 'sqdOP')[1].click
          wait.until {
            driver.current_url == "https://www.instagram.com/accounts/onetap/?next=%2F&hl=ja"
          }
          driver.navigate.to("https://www.instagram.com/#{user}/")
          begin
            wait.until {driver.find_element(xpath: '//*[@id="react-root"]/section/main/div/ul/li[2]/a/span').displayed?}
          rescue => e
            Notification.create(
              notification_type:0,content:"いいねリストへの追加に失敗しました。#{e.message}",isRead:0, user_id:user_id
            )
            driver.quit
          end
          follower = driver.find_element(xpath: '//*[@id="react-root"]/section/main/div/ul/li[2]/a/span').attribute(:title).gsub(/[^\d]/, "").to_i
          if follower == 0
            follower = driver.find_element(xpath: '//*[@id="react-root"]/section/main/div/ul/li[3]/a/span').text
            if follower.include?("百")
              follower = follower.split('百')[0] * 100
            elsif follower.include?("千")
              follower = follower.split('千')[0] * 1000
            end
          end
          wait.until {driver.find_element(xpath: '//*[@id="react-root"]/section/main/div/ul/li[2]/a').displayed?}
          driver.find_element(xpath: '//*[@id="react-root"]/section/main/div/ul/li[2]/a').click
          gridCount = 0
          if follower < count
            while gridCount != follower
              sleep(1)
              gridCount = driver.find_elements(tag_name: "li").count
            end
          else
            while gridCount < count
              sleep(1)
              gridCount = driver.find_elements(tag_name: "li").count
            end
          end
          target_usernames = driver.find_elements(class: 'FPmhX')
          target_usernames.each do |e|
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
          target_usernameList.each do |e|
            driver.navigate.to("https://www.instagram.com/#{e}/")
            begin
              wait.until {driver.find_element(xpath: '//*[@id="react-root"]/section/main/div/div[3]/article/div[1]/div/div[1]/div[1]/a').displayed?}
            rescue
              next
            end
            target_postLinkList << driver.find_element(xpath: '//*[@id="react-root"]/section/main/div/div[3]/article/div[1]/div/div[1]/div[1]/a').attribute(:href)
          end
          driver.quit
          saveCount = 0
          target_usernameList.first(count).count.times.each do |i|
            @fav = Fav.new(
              target_postLink:target_postLinkList[i],target_postImage:target_imageList[i],
              target_username:target_usernameList[i],target_name:target_nameList[i],fav_flg:0,account_id:account_id
            )
            if @fav.save
              saveCount += 1
            end
          end
          Notification.create(
            notification_type:3,content:"@#{user}のフォロワー#{count}人の最新投稿を#{saveCount}件いいねリストへ追加しました。",isRead:0, user_id:user_id
          )
        when "3"
          options = Selenium::WebDriver::Chrome::Options.new
          options.headless!
          options.add_option(:binary, "/usr/bin/google-chrome")
          options.add_argument("--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36")
          options.add_emulation(device_name: 'iPhone 8')
          options.add_argument("--disable-dev-shm-usage")
          options.add_argument("--no-sandbox")
          options.add_argument("--disable-setuid-sandbox")
          options.add_argument("--disable-dev-shm-usage")
          options.add_argument("--no-sandbox")
          options.add_argument("--disable-setuid-sandbox")
          driver = Selenium::WebDriver.for :chrome, options: options
          wait = Selenium::WebDriver::Wait.new(:timeout => 5)
          driver.get("https://www.instagram.com/accounts/login/?hl=ja")
          wait.until {driver.find_element(name: 'username').displayed?}
          driver.find_element(name: 'username').send_keys(username)
          wait.until {driver.find_element(name: 'password').displayed?}
          driver.find_element(name: 'password').send_keys(pass)
          driver.find_elements(tag_name: "button")[2].click
          wait.until {
            driver.current_url == "https://www.instagram.com/accounts/onetap/?next=%2F&hl=ja"
          }
          driver.get("https://www.instagram.com/#{user}/")
          wait.until {driver.find_element(xpath: '//*[@id="react-root"]/section/main/div/ul/li[3]/a/span').displayed?}
          follow = driver.find_element(xpath: '//*[@id="react-root"]/section/main/div/ul/li[3]/a/span').text.gsub(/[^\d]/, "").to_i
          if follow == 0
            follow = driver.find_element(xpath: '//*[@id="react-root"]/section/main/div/ul/li[3]/a/span').text
            if follow.include?("百")
              follow = follow.split('百')[0] * 100
            elsif follow.include?("千")
              follow = follow.split('千')[0] * 1000
            end
          end
          wait.until {driver.find_element(xpath: '//*[@id="react-root"]/section/main/div/ul/li[3]/a').displayed?}
          driver.find_element(xpath: '//*[@id="react-root"]/section/main/div/ul/li[3]/a').click
          gridCount = 0
          if follow < count
            while gridCount != follow
              sleep(1)
              gridCount = driver.find_elements(tag_name: "li").count
            end
          else
            while gridCount < count
              sleep(1)
              gridCount = driver.find_elements(tag_name: "li").count
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
          target_usernameList.each do |e|
            driver.navigate.to("https://www.instagram.com/#{e}/")
            begin
              wait.until {driver.find_element(xpath: '//*[@class="FyNDV"]/div[1]/div/div[1]/div[1]/a').displayed?}
            rescue
              next
            end
            target_postLinkList << driver.find_element(xpath: '//*[@class="FyNDV"]/div[1]/div/div[1]/div[1]/a').attribute(:href)
          end
          driver.quit
          saveCount = 0
          target_usernameList.first(count).count.times.each do |i|
            @fav = Fav.new(
              target_postLink:target_postLinkList[i],target_postImage:target_imageList[i],
              target_username:target_usernameList[i],target_name:target_nameList[i],fav_flg:0,account_id:account_id
            )
            if @fav.save
              saveCount += 1
            end
          end
          Notification.create(
            notification_type:3,content:"@#{user}のフォロー#{count}人の最新投稿を#{saveCount}件いいねリストへ追加しました。",isRead:0, user_id:user_id
          )
        end
      end
    rescue => e
      Notification.create(
        notification_type:0,content:"いいねリストへの追加に失敗しました。#{e.message}",isRead:0, user_id:user_id
      )
      driver.quit
    end
  end
end
