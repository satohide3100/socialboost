class NotificationController < ApplicationController
  require "date"
  def destroy
    id = params[:id]
    Notification.find(id).update(isRead:1)
    redirect_back(fallback_location: root_path)
  end

  def index
    if params[:id]
      @notifications = Notification.order("created_at desc").where(user_id:current_user.id).where(account_id:params[:id]).where("notification_type = 10 or notification_type = 11")
      @target_account = Account.find(@notifications.first.account_id).username
    else
      @notifications = Notification.order("created_at desc").where(user_id:current_user.id).where("notification_type = 10 or notification_type = 11").where.not(account_id:nil)
      @target_account = "全ユーザー"
    end
  end
end
