class NotificationController < ApplicationController
  def destroy
    id = params[:id]
    Notification.find(id).update(isRead:1)
    redirect_back(fallback_location: root_path)
  end
end
