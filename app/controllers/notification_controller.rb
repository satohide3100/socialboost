class NotificationController < ApplicationController
  def destroy
    id = params[:id]
    Notification.find(id).update(isRead:1)
    redirect_back(fallback_location: root_path)
  end

  def show
    @notifications = Notification.where(user_id:current_user.id).where(notification_type:10).where(notification_type:11)
  end
end
