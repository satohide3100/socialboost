class AddAccountJob < ApplicationJob
  require 'selenium-webdriver'
  queue_as :default

  def perform(sns_type,username,pass,user_id)
    begin
      options = Selenium::WebDriver::Chrome::Options.new
      options.headless!
      options.add_option(:binary, "/usr/bin/google-chrome")
      options.add_argument("--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36")
      options.add_argument('--start-maximized')
      driver = Selenium::WebDriver.for :chrome, options: options
      wait = Selenium::WebDriver::Wait.new(:timeout => 5)
      if sns_type == "1"
        driver.navigate.to "https://twitter.com/login?lang=ja"
        wait.until {driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[1]/input').displayed?}
        driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[1]/input').send_keys(username)
        wait.until {driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[2]/input').displayed?}
        driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[2]/input').send_keys(pass)
        driver.find_element(:xpath, '//*[@id="page-container"]/div/div[1]/form/div[2]/button').click
        begin
          wait.until {driver.find_element(xpath: '//*[@id="page-container"]/div[1]/div[1]/div/div[1]/div/a').displayed?}
        rescue
          driver.quit
          Notification.create(
            notification_type:0,content:"アカウントの追加に失敗しました。ユーザー名・パスワードを再確認して下さい。",isRead:0, user_id:user_id
          )
        end
        profile_name = driver.find_element(xpath: '//*[@id="page-container"]/div[1]/div[1]/div/div[1]/div/a').text
        wait.until {driver.find_element(xpath: '//*[@id="page-container"]/div[1]/div[1]/div/div[2]/ul/li[2]/a/span[2]').displayed?}
        follow_count = driver.find_element(xpath: '//*[@id="page-container"]/div[1]/div[1]/div/div[2]/ul/li[2]/a/span[2]').text.gsub(/[^\d]/, "").to_i
        follower_count = driver.find_element(xpath: '//*[@id="page-container"]/div[1]/div[1]/div/div[2]/ul/li[3]/a/span[2]').text.gsub(/[^\d]/, "").to_i
        post_count = driver.find_element(xpath: '//*[@id="page-container"]/div[1]/div[1]/div/div[2]/ul/li[1]/a/span[2]').text.gsub(/[^\d]/, "").to_i
        wait.until {driver.find_element(xpath: '//*[@id="page-container"]/div[1]/div[1]/div/a/img').displayed?}
        profile_image = driver.find_element(xpath: '//*[@id="page-container"]/div[1]/div[1]/div/a/img').attribute(:src)
        driver.quit
        @account = Account.new(sns_type:sns_type,username:username,pass:pass,profile_name:profile_name,active_flg:0,user_id:user_id)
        if @account.save
          account_id = @account.id
          Analyze.create(
            follow_count:follow_count,follower_count:follower_count,
            post_count:post_count,profile_image:profile_image,account_id:account_id
          )
          Notification.create(
            notification_type:1,content:"Twitterアカウント「#{profile_name}」を追加しました。",isRead:0, user_id:user_id
          )
        else
          Notification.create(
            notification_type:0,content:"そのアカウントは既に追加されています。",isRead:0, user_id:user_id
          )
        end
      elsif sns_type == "2"
        driver.navigate.to "https://www.instagram.com/accounts/login/?hl=ja"
        wait.until {driver.find_element(name: 'username').displayed?}
        driver.find_element(name: 'username').send_keys(username)
        wait.until {driver.find_element(name: 'password').displayed?}
        driver.find_element(name: 'password').send_keys(pass)
        driver.find_elements(class: 'sqdOP')[1].click
        driver.navigate.to "https://www.instagram.com/#{username}/?hl=ja"
        begin
          wait.until {driver.find_element(class: "_7UhW9").displayed?}
        rescue
          driver.quit
          Notification.create(
            notification_type:0,content:"アカウントの追加に失敗しました。ユーザー名・パスワードを再確認して下さい。",isRead:0, user_id:user_id
          )
        end
        profile_name = driver.find_element(class: "_7UhW9").text
        wait.until {driver.find_element(class: "g47SY ").displayed?}
        puts follow_count = driver.find_elements(class: "g47SY ")[2].text.gsub(/[^\d]/, "").to_i
        puts follower_count = driver.find_elements(class: "g47SY ")[1].text.gsub(/[^\d]/, "").to_i
        puts post_count = driver.find_elements(class: "g47SY ")[0].text.gsub(/[^\d]/, "").to_i
        wait.until {driver.find_element(tag_name: 'img').displayed?}
        puts profile_image = driver.find_element(tag_name: 'img').attribute(:src)
        driver.quit
        @account = Account.new(sns_type:sns_type,username:username,pass:pass,profile_name:profile_name,active_flg:0,user_id:user_id)
        if @account.save
          account_id = @account.id
          Analyze.create(
            follow_count:follow_count,follower_count:follower_count,
            post_count:post_count,profile_image:profile_image,account_id:account_id
          )
          Notification.create(
            notification_type:1,content:"Instagramアカウント「#{profile_name}」を追加しました。",isRead:0, user_id:user_id
          )
        end
        if @account.errors.full_messages[0] == "Username has already been taken"
          Notification.create(
            notification_type:0,content:"そのアカウントは既に追加されています。",isRead:0, user_id:user_id
          )
        end
      elsif sns_type == "3"
        #Account.create(sns_type:sns_type,username:username,pass:pass,profile_name:profile_name,active_flg:0,user_id:user_id)
      end
    rescue => e
      puts e
      driver.quit
    end
  end

end
