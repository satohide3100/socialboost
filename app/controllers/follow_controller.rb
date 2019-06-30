class FollowController < ApplicationController
  before_action :authenticate_user!
  USER_AGENT = 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1 (compatible; AdsBot-Google-Mobile; +http://www.google.com/mobile/adsbot.html)'
  def list
    @twitterActive = Account.find_by(user_id:current_user.id,sns_type:1,active_flg:1)
    @intervalHour = []
    25.times.each do |i|
      if 24 % (i + 1) == 0
        @intervalHour << i + 1
      end
    end
    if @twitterActive
      @twitterActiveImage = Analyze.find_by(account_id:@twitterActive.id)
      @follows1 = Follow.where(account_id:@twitterActive.id).order("id desc")
      @twitterSetting = FollowSetting.find_by(account_id:@twitterActive.id)
    else
      @follows1 = []
      @twitterSetting = FollowSetting.new
    end

    @instagramActive = Account.find_by(user_id:current_user.id,sns_type:2,active_flg:1)
    if @instagramActive
      @instagramActiveImage = Analyze.find_by(account_id:@instagramActive.id)
      @follows2 = Follow.where(account_id:@instagramActive.id).order("id desc")
      @instagramSetting = FollowSetting.find_by(account_id:@instagramActive.id)
    else
      @follows2 = []
      @instagramSetting = FollowSetting.new
    end
  end

  def setting_create
    sns_type = params[:sns_type]
    dayLimit = params[:dayLimit]
    interval = params[:interval]
    count_by_interval = params[:count_by_interval]
    intervalsec = params[:intervalsec]
    if sns_type == "1"
      @account = Account.find_by(user_id:current_user.id,sns_type:1,active_flg:1)
      account_id = @account.id
    elsif sns_type == "2"
      @account = Account.find_by(user_id:current_user.id,sns_type:2,active_flg:1)
      account_id = @account.id
    end
    followSetting = FollowSetting.find_by(account_id:account_id)
    if followSetting == nil
      FollowSetting.create(
        dayLimit:dayLimit,interval:interval,count_by_interval:count_by_interval,intervalsec:intervalsec,account_id:account_id
      )
      flash[:notice] = "フォロー設定を新規追加しました。"
    else
      FollowSetting.where(account_id:account_id).update(
        dayLimit:dayLimit,interval:interval,count_by_interval:count_by_interval,intervalsec:intervalsec
      )
      flash[:notice] = "フォロー設定を更新しました。"
    end
    redirect_to("/follow/list")
  end

  def create
    sns_type = params[:sns_type]
    option = params[:option]
    user = params[:user]
    post = params[:post]
    word = params[:word]
    count = params[:count].to_i
    isAll = false
    user_id = current_user.id
    if (option == "1" || option == "2") && user == ""
      flash[:alert] = "ユーザー名を入力してください。"
      redirect_to("/follow/list")
      return
    end
    if option == "3" && word == ""
      flash[:alert] = "キーワードを入力してください。"
      redirect_to("/follow/list")
      return
    end
    if option == "4" && post == ""
      flash[:alert] = "投稿URLを入力してください。"
      redirect_to("/follow/list")
      return
    end
    if params[:check]
      isAll = true
    end
    AddFollowJob.perform_later(sns_type,option,user,post,word,count,user_id,isAll)
    flash[:notice] = "フォローリストの追加処理を開始しました。"
    redirect_to("/follow/list")
  end

  def destroy
    @follow = Follow.find(params[:id])
    @follow.destroy
    flash[:notice] = "#{@follow.target_name}のデータを削除しました。"
    redirect_to("/follow/list")
  end

end
