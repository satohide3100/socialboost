class AccountController < ApplicationController
  before_action :authenticate_user!
  def list
    @accounts1 = Account.where(sns_type:1).where(user_id:current_user.id).order("active_flg desc")
    @accounts2 = Account.where(sns_type:2).where(user_id:current_user.id).order("active_flg desc")
    @accounts3 = Account.where(sns_type:3).where(user_id:current_user.id).order("active_flg desc")
    @analyzes = Analyze.all
  end

  def active
    account_id = params[:id]
    sns_type = Account.find(account_id).sns_type
    Account.where(sns_type:sns_type).where(user_id:current_user.id).update(active_flg:0)
    Account.where(id:account_id).update(active_flg:1)
    flash[:notice] = "アクティブアカウントを変更しました。"
    redirect_to("/account/list")
  end

  def create
    if($mycontrollerMutex==nil)
       $mycontrollerMutex = Mutex.new
     end
    Thread.start do
      $mycontrollerMutex.synchronize do
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
        sns_type = params[:sns_type]
        username = params[:username]
        pass = params[:pass]
        user_id = current_user.id
        begin
          if sns_type == "1"
            driver.navigate.to "https://twitter.com/login?lang=ja"
            wait.until {driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[1]/input').displayed?}
            driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[1]/input').send_keys(username)
            wait.until {driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[2]/input').displayed?}
            driver.find_element(xpath: '//*[@id="page-container"]/div/div[1]/form/fieldset/div[2]/input').send_keys(pass)
            driver.find_element(:xpath, '//*[@id="page-container"]/div/div[1]/form/div[2]/button').click
            wait.until {driver.find_element(xpath: '//*[@id="page-container"]/div[1]/div[1]/div/div[1]/div/a').displayed?}
            profile_name = driver.find_element(xpath: '//*[@id="page-container"]/div[1]/div[1]/div/div[1]/div/a').text
            wait.until {driver.find_element(xpath: '//*[@id="page-container"]/div[1]/div[1]/div/div[2]/ul/li[2]/a/span[2]').displayed?}
            puts follow_count = driver.find_element(xpath: '//*[@id="page-container"]/div[1]/div[1]/div/div[2]/ul/li[2]/a/span[2]').text.gsub(/[^\d]/, "").to_i
            puts follower_count = driver.find_element(xpath: '//*[@id="page-container"]/div[1]/div[1]/div/div[2]/ul/li[3]/a/span[2]').text.gsub(/[^\d]/, "").to_i
            puts post_count = driver.find_element(xpath: '//*[@id="page-container"]/div[1]/div[1]/div/div[2]/ul/li[1]/a/span[2]').text.gsub(/[^\d]/, "").to_i
            wait.until {driver.find_element(xpath: '//*[@id="page-container"]/div[1]/div[1]/div/a/img').displayed?}
            puts profile_image = driver.find_element(xpath: '//*[@id="page-container"]/div[1]/div[1]/div/a/img').attribute(:src)
            driver.close
            @account = Account.new(sns_type:sns_type,username:username,pass:pass,profile_name:profile_name,active_flg:0,user_id:user_id)
            if @account.save
              account_id = @account.id
              Analyze.create(
                follow_count:follow_count,follower_count:follower_count,
                post_count:post_count,profile_image:profile_image,account_id:account_id
              )
              Notification.create(
                notification_type:1,content:"Twitterアカウント「#{profile_name}」を追加しました。",isRead:0, account_id:account_id
              )
            else
              Notification.create(
                notification_type:0,content:"そのアカウントは既に追加されています。",isRead:0, account_id:account_id
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
            wait.until {driver.find_element(class: "_7UhW9").displayed?}
            profile_name = driver.find_element(class: "_7UhW9").text
            wait.until {driver.find_element(class: "g47SY ").displayed?}
            puts follow_count = driver.find_elements(class: "g47SY ")[2].text.gsub(/[^\d]/, "").to_i
            puts follower_count = driver.find_elements(class: "g47SY ")[1].text.gsub(/[^\d]/, "").to_i
            puts post_count = driver.find_elements(class: "g47SY ")[0].text.gsub(/[^\d]/, "").to_i
            wait.until {driver.find_element(tag_name: 'img').displayed?}
            puts profile_image = driver.find_element(tag_name: 'img').attribute(:src)
            driver.close
            @account = Account.new(sns_type:sns_type,username:username,pass:pass,profile_name:profile_name,active_flg:0,user_id:user_id)
            if @account.save
              account_id = @account.id
              Analyze.create(
                follow_count:follow_count,follower_count:follower_count,
                post_count:post_count,profile_image:profile_image,account_id:account_id
              )
              Notification.create(
                notification_type:1,content:"Instagramアカウント「#{profile_name}」を追加しました。",isRead:0, account_id:account_id
              )
            end
            if @account.errors.full_messages[0] == "Username has already been taken"
              @notification.new(
                notification_type:0,content:"そのアカウントは既に追加されています。",isRead:0, account_id:account_id
              )
              @notification.save
              logger.debug @notification.errors.inspect
            end
          elsif sns_type == "3"
            #Account.create(sns_type:sns_type,username:username,pass:pass,profile_name:profile_name,active_flg:0,user_id:user_id)
          end
        rescue => e
          puts e
          driver.close
          Notification.create(
            notification_type:0,content:"アカウントの追加に失敗しました。ユーザー名・パスワードを再確認して下さい。",isRead:0, account_id:account_id
          )
        end
      end
    end
    flash[:notice] = "アカウントリストの追加処理を開始しました。"
    redirect_to("/account/list")
  end
end
