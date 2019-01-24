class FavController < ApplicationController
  before_action :authenticate_user!
  def list
    @intervalHour = []
    25.times.each do |i|
      if 24 % (i + 1) == 0
        @intervalHour << i + 1
      end
    end
    @twitterActive = Account.find_by(user_id:current_user.id,sns_type:1,active_flg:1)
    if @twitterActive
      @twitterActiveImage = Analyze.find_by(account_id:@twitterActive.id)
      @twitterSetting = FavSetting.find_by(account_id:@twitterActive.id)
      @fav1 = Fav.where(account_id:@twitterActive.id).where(fav_flg:0).order("id desc")
    else
      @fav1 = []
    end

    @instagramActive = Account.find_by(user_id:current_user.id,sns_type:2,active_flg:1)
    if @instagramActive
      @instagramActiveImage = Analyze.find_by(account_id:@instagramActive.id)
      @instagramSetting = FavSetting.find_by(account_id:@instagramActive.id)
      @fav2 = Fav.where(account_id:@instagramActive.id).where(fav_flg:0).order("id desc")
    else
      @fav2 = []
    end

  end

  def create
    sns_type = params[:sns_type]
    option = params[:option]
    user = params[:user]
    post = params[:post]
    word = params[:word]
    count = params[:count].to_i
    user_id = current_user.id
    if option == "1" && word == ""
      flash[:alert] = "キーワードを入力してください。"
      redirect_to("/fav/list")
      return
    end
    if (option == "2" || option == "3") && user == ""
      flash[:alert] = "ユーザー名を入力してください。"
      redirect_to("/fav/list")
      return
    end
    flash[:notice] = "いいねリストの追加処理を開始しました。"
    AddFavJob.perform_later(sns_type,option,user,post,word,count,user_id)
    redirect_to("/fav/list")
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
    favSetting = FavSetting.find_by(account_id:account_id)
    if favSetting == nil
      FavSetting.create(
        dayLimit:dayLimit,interval:interval,count_by_interval:count_by_interval,intervalsec:intervalsec,account_id:account_id
      )
      flash[:notice] = "いいね設定を新規追加しました。"
    else
      FavSetting.where(account_id:account_id).update(
        dayLimit:dayLimit,interval:interval,count_by_interval:count_by_interval,intervalsec:intervalsec
      )
      flash[:notice] = "いいね設定を更新しました。"
    end

    redirect_to("/fav/list")
  end

  def destroy
    @fav = Fav.find(params[:id])
    @fav.destroy
    flash[:notice] = "#{@fav.target_name}のデータを削除しました。"
    redirect_to("/fav/list")
  end

end
