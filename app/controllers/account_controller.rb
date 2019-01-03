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
    sns_type = params[:sns_type]
    username = params[:username]
    pass = params[:pass]
    user_id = current_user.id
    AddAccountJob.perform_later(sns_type,username,pass,user_id)
    flash[:notice] = "アカウントリストの追加処理を開始しました。"
    redirect_to("/account/list")
  end
end
