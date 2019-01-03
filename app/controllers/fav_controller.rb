class FavController < ApplicationController
  before_action :authenticate_user!
  def list
    @twitterActive = Account.find_by(user_id:current_user.id,sns_type:1,active_flg:1)
    if @twitterActive
      @twitterActiveImage = Analyze.find_by(account_id:@twitterActive.id)
      @twitterSetting = FavSetting.find_by(account_id:@twitterActive.id)
      @fav1 = Fav.where(account_id:@twitterActive.id)
    else
      @fav1 = []
    end

    @instagramActive = Account.find_by(user_id:current_user.id,sns_type:2,active_flg:1)
    if @instagramActive
      @instagramActiveImage = Analyze.find_by(account_id:@instagramActive.id)
      @instagramSetting = FavSetting.find_by(account_id:@instagramActive.id)
      @fav2 = Fav.where(account_id:@instagramActive.id)
    else
      @fav2 = []
    end

  end

  def create
    if($mycontrollerMutex==nil)
      $mycontrollerMutex = Mutex.new
    end
    Thread.start do
      $mycontrollerMutex.synchronize do
        sns_type = params[:sns_type]
        option = params[:option]
        user = params[:user]
        post = params[:post]
        word = params[:word]
        count = params[:count].to_i
        target_usernameList = []
        target_nameList = []
        target_imageList = []
        target_postLinkList = []
        if sns_type == "1"
          @account = Account.find_by(user_id:current_user.id,sns_type:1,active_flg:1)
          account_id = @account.id
          username = @account.username
          pass = @account.pass
          require 'selenium-webdriver'
          caps = Selenium::WebDriver::Remote::Capabilities.chrome(
            "chromeOptions" => {
            #binary: "/usr/bin/google-chrome",
            args: ["--window-size=1920,1080","--start-maximized","--headless",'--no-sandbox','--disable-dev-shm-usage'
            ]
            }
          )
          driver = Selenium::WebDriver.for :chrome, desired_capabilities: caps
          wait = Selenium::WebDriver::Wait.new(:timeout => 5)
          case option
          when "1" #特定のキーワードを投稿
            driver.get("https://twitter.com/search?f=tweets&vertical=default&q=#{word}&l=ja&src=typd")
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
            puts target_usernameList.count
            puts target_nameList.count
            puts target_imageList.count
            driver.close
          when "2" #

          end
        elsif sns_type == "2"
          require 'selenium-webdriver'
          @account = Account.find_by(user_id:current_user.id,sns_type:2,active_flg:1)
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
          notification_type:3,content:"いいねリストへの追加が完了しました。",isRead:0, account_id:account_id
        )
      end
    end
    flash[:notice] = "いいねリストの追加処理を開始しました。"
    redirect_to("/fav/list")
  end

  def setting_create
    sns_type = params[:sns_type]
    dayLimit = params[:dayLimit]
    interval = params[:interval]
    count_by_interval = params[:count_by_interval]
    if sns_type == "1"
      @account = Account.find_by(user_id:current_user.id,sns_type:1,active_flg:1)
      account_id = @account.id
    elsif sns_type == "2"
      @account = Account.find_by(user_id:current_user.id,sns_type:2,active_flg:1)
      account_id = @account.id
    end
    favSetting = FavSetting.find_by(account_id:account_id)
    if favSetting == nil
      FavSetting.create(
        dayLimit:dayLimit,interval:interval,count_by_interval:count_by_interval,account_id:account_id
      )
      flash[:notice] = "いいね設定を新規追加しました。"
    else
      FavSetting.where(account_id:account_id).update(
        dayLimit:dayLimit,interval:interval,count_by_interval:count_by_interval
      )
      flash[:notice] = "いいね設定を更新しました。"
    end

    redirect_to("/fav/list")
  end
end
