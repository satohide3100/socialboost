class AddFollowJob < ApplicationJob
  queue_as :default

  def perform(sns_type,option,user,post,word,count,user_id,isAll)
    begin
      target_usernameList = []
      target_nameList = []
      target_imageList = []
      if sns_type == "1"
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
          ##options.add_option(:binary, "/usr/bin/google-chrome")
          options.add_argument("--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36")
          options.add_emulation(device_name: 'iPhone 8')
          options.add_argument("--disable-dev-shm-usage")
          options.add_argument("--no-sandbox")
          options.add_argument("--disable-setuid-sandbox")
          options.add_argument("--lang=ja")
          driver = Selenium::WebDriver.for :chrome, options: options
          wait = Selenium::WebDriver::Wait.new(:timeout => 5)
          driver.get("https://www.instagram.com/accounts/login")
          wait.until {driver.find_element(name: 'username').displayed?}
          driver.find_element(name: 'username').send_keys("sato__hideki")
          wait.until {driver.find_element(name: 'password').displayed?}
          driver.find_element(name: 'password').send_keys("oneokrock")
          driver.find_element(name: 'password').send_keys(:return)
          sleep 3
          driver.navigate.to("https://www.instagram.com/#{user}/")
          wait.until {driver.find_element(xpath: '//*[@id="react-root"]/section/main/div/ul/li[2]/a/span').displayed?}
          follower = driver.find_element(xpath: '//*[@id="react-root"]/section/main/div/ul/li[2]/a/span').text.gsub(/[^\d]/, "").to_i
          wait.until {driver.find_element(xpath: '//*[@id="react-root"]/section/main/div/ul/li[2]/a').displayed?}
          driver.find_element(xpath: '//*[@id="react-root"]/section/main/div/ul/li[2]/a').click
          gridCount = 0
          if follower < count
            while gridCount != follower
              sleep 1
              wait.until {driver.find_element(tag_name: "li").displayed?}
              driver.find_elements(tag_name: "li")[gridCount - 1].location_once_scrolled_into_view
              wait.until {driver.find_element(tag_name: "li").displayed?}
              puts gridCount = driver.find_elements(tag_name: "li").count.to_i
            end
          else
            while gridCount < count
              sleep 1
              wait.until {driver.find_element(tag_name: "li").displayed?}
              driver.find_elements(tag_name: "li")[gridCount - 1].location_once_scrolled_into_view
              wait.until {driver.find_element(tag_name: "li").displayed?}
              puts gridCount = driver.find_elements(tag_name: "li").count.to_i
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
          driver.quit
          saveCount = 0
          if isAll
            Account.where(user_id:user_id).each do |account|
              saveCount = 0
              target_usernameList.count.times.each do |i|
                @follow = Follow.new(
                  target_username:target_usernameList[i],target_name:target_nameList[i],target_image:target_imageList[i],follow_flg:0,account_id:account.id
                )
                if @follow.save
                  saveCount += 1
                end
              end
            end
          else
            target_usernameList.count.times.each do |i|
              @follow = Follow.new(
                target_username:target_usernameList[i],target_name:target_nameList[i],target_image:target_imageList[i],follow_flg:0,account_id:account_id
              )
              if @follow.save
                saveCount += 1
              end
            end
          end
          Notification.create(
            notification_type:2,content:"@#{user}のフォロワーを#{saveCount}人フォローリストへ追加しました。",isRead:0, user_id:user_id
          )
        when "2"
          options = Selenium::WebDriver::Chrome::Options.new
          options.headless!
          ##options.add_option(:binary, "/usr/bin/google-chrome")
          options.add_argument("--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36")
          options.add_emulation(device_name: 'iPhone 8')
          options.add_argument("--disable-dev-shm-usage")
          options.add_argument("--no-sandbox")
          options.add_argument("--disable-setuid-sandbox")
          driver = Selenium::WebDriver.for :chrome, options: options
          wait = Selenium::WebDriver::Wait.new(:timeout => 5)
          driver.get("https://www.instagram.com/accounts/login/?hl=ja")
          wait.until {driver.find_element(name: 'username').displayed?}
          driver.find_element(name: 'username').send_keys("sato__hideki")
          wait.until {driver.find_element(name: 'password').displayed?}
          driver.find_element(name: 'password').send_keys("oneokrock")
          driver.find_element(name: 'password').send_keys(:return)
          sleep(3)
          driver.navigate.to("https://www.instagram.com/#{user}/")
          wait.until {driver.find_element(xpath: '//*[@id="react-root"]/section/main/div/ul/li[3]/a/span').displayed?}
          follow = driver.find_element(xpath: '//*[@id="react-root"]/section/main/div/ul/li[3]/a/span').text.gsub(/[^\d]/, "").to_i
          wait.until {driver.find_element(xpath: '//*[@id="react-root"]/section/main/div/ul/li[3]/a').displayed?}
          driver.find_element(xpath: '//*[@id="react-root"]/section/main/div/ul/li[3]/a').click
          gridCount = 0
          if follow < count
            while gridCount != follow
              sleep 1
              wait.until {driver.find_element(tag_name: "li").displayed?}
              driver.find_elements(tag_name: "li")[gridCount - 1].location_once_scrolled_into_view
              wait.until {driver.find_element(tag_name: "li").displayed?}
              puts gridCount = driver.find_elements(tag_name: "li").count.to_i
            end
          else
            while gridCount < count
              sleep 1
              wait.until {driver.find_element(tag_name: "li").displayed?}
              driver.find_elements(tag_name: "li")[gridCount - 1].location_once_scrolled_into_view
              wait.until {driver.find_element(tag_name: "li").displayed?}
              puts gridCount = driver.find_elements(tag_name: "li").count.to_i
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
          driver.quit
          saveCount = 0
          if isAll
            Account.where(user_id:user_id).each do |account|
              saveCount = 0
              target_usernameList.count.times.each do |i|
                @follow = Follow.new(
                  target_username:target_usernameList[i],target_name:target_nameList[i],target_image:target_imageList[i],follow_flg:0,account_id:account.id
                )
                if @follow.save
                  saveCount += 1
                end
              end
            end
          else
            target_usernameList.count.times.each do |i|
              @follow = Follow.new(
                target_username:target_usernameList[i],target_name:target_nameList[i],target_image:target_imageList[i],follow_flg:0,account_id:account_id
              )
              if @follow.save
                saveCount += 1
              end
            end
          end
          Notification.create(
            notification_type:2,content:"@#{user}のフォローを#{saveCount}人フォローリストへ追加しました。",isRead:0, user_id:user_id
          )
        when "3"
          options = Selenium::WebDriver::Chrome::Options.new
          options.headless!
          ##options.add_option(:binary, "/usr/bin/google-chrome")
          options.add_argument("--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36")
          options.add_argument('--start-maximized')
          options.add_argument("--disable-dev-shm-usage")
          options.add_argument("--no-sandbox")
          options.add_argument("--disable-setuid-sandbox")
          driver = Selenium::WebDriver.for :chrome, options: options
          wait = Selenium::WebDriver::Wait.new(:timeout => 5)
          driver.get("https://www.instagram.com/explore/tags/#{word}/")
          links = []
          wait.until {driver.find_element(css: '.v1Nh3 a').displayed?}
          while count > links.count
            driver.find_elements(css: '.v1Nh3 a').last.location_once_scrolled_into_view
            wait.until {driver.find_element(css: '.v1Nh3 a').displayed?}
            driver.find_elements(css: '.v1Nh3 a').each do |e|
              links << e.attribute(:href)
            end
            links.uniq!
            puts links.count
          end
          driver.quit
          saveCount = 0
          if isAll
            Account.where(user_id:user_id).each do |account|
              saveCount = 0
              links.each do |link|
                @follow = Follow.new(
                  target_image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQB8IuiPY9HdN5uOHJxs7km_KxNfivPT2biYs3zCRC9y_LlOBpMbw",target_postLink:link,follow_flg:0,account_id:account.id
                )
                if @follow.save
                  saveCount += 1
                end
              end
            end
          else
            links.each do |link|
              @follow = Follow.new(
                target_image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQB8IuiPY9HdN5uOHJxs7km_KxNfivPT2biYs3zCRC9y_LlOBpMbw",target_postLink:link,follow_flg:0,account_id:account_id
              )
              if @follow.save
                saveCount += 1
              end
            end
          end
          Notification.create(
            notification_type:2,content:"「##{word}」を投稿しているアカウント#{saveCount}人をフォローリストへ追加しました。",isRead:0, user_id:user_id
          )
        when "4"
          options = Selenium::WebDriver::Chrome::Options.new
          options.headless!
          ##options.add_option(:binary, "/usr/bin/google-chrome")
          options.add_argument("--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36")
          options.add_argument('--start-maximized')
          options.add_argument("--disable-dev-shm-usage")
          options.add_argument("--no-sandbox")
          options.add_argument("--disable-setuid-sandbox")
          driver = Selenium::WebDriver.for :chrome, options: options
          wait = Selenium::WebDriver::Wait.new(:timeout => 5)
          driver.get(post)
          wait.until {driver.find_element(class: 'zV_Nj').displayed?}
          driver.find_elements(tag_name: "footer").last.location_once_scrolled_into_view
          wait.until {driver.find_element(xpath: '//*[@class="zV_Nj"]/span').displayed?}
          favCount = driver.find_element(xpath: '//*[@class="zV_Nj"]/span').text.gsub(/[^\d]/, "").to_i
          driver.find_element(class: 'zV_Nj').click
          gridCount = 2
          if favCount < count
            while target_usernameList.count != favCount
              sleep(1)
              puts gridCount = driver.find_elements(xpath: '/html/body/div[4]/div/div[2]/div/div/div').count
              if gridCount == 0
                gridCount = 2
              end
              driver.find_element(:xpath, "/html/body/div[4]/div/div[2]/div/div/div[#{gridCount - 1}]/div[1]/div/a").send_keys :tab
              driver.find_elements(xpath: '/html/body/div[4]/div/div[2]/div/div/div/div[2]/div[1]/div/a/div/div/div').each do |e|
                puts target_usernameList << e.text
              end
            end
          else
            while target_usernameList.count < count
              sleep(1)
              puts gridCount = driver.find_elements(xpath: '/html/body/div[4]/div/div[2]/div/div/div').count
              if gridCount == 0
                gridCount = 2
              end
              driver.find_element(:xpath, "/html/body/div[4]/div/div[2]/div/div/div[#{gridCount - 1}]/div[1]/div/a").send_keys :tab
              driver.find_elements(xpath: '/html/body/div[4]/div/div[2]/div/div/div/div[2]/div[1]/div/a/div/div/div').each do |e|
                puts target_usernameList << e.text
              end
              puts target_usernameList.count
            end
          end
          driver.quit
          saveCount = 0
          if isAll
            Account.where(user_id:user_id).each do |account|
              saveCount = 0
              target_usernameList.count.times.each do |i|
                @follow = Follow.new(
                  target_username:target_usernameList[i],target_image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQB8IuiPY9HdN5uOHJxs7km_KxNfivPT2biYs3zCRC9y_LlOBpMbw",follow_flg:0,account_id:account.id
                )
                if @follow.save
                  saveCount += 1
                end
              end
            end
          else
            target_usernameList.count.times.each do |i|
              @follow = Follow.new(
                target_username:target_usernameList[i],target_image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQB8IuiPY9HdN5uOHJxs7km_KxNfivPT2biYs3zCRC9y_LlOBpMbw",follow_flg:0,account_id:account_id
              )
              if @follow.save
                saveCount += 1
              end
            end
          end
          Notification.create(
            notification_type:2,content:"「#{post}」にいいねしている#{saveCount}人をフォローリストへ追加しました。",isRead:0, user_id:user_id
          )
        end
      end
    rescue => e
      puts e
      Notification.create(
        notification_type:0,content:"フォローリストへの追加に失敗しました。#{e.message}",isRead:0, user_id:user_id
      )
      driver.quit
    end
  end
end
