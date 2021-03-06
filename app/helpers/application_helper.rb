module ApplicationHelper
  def avatar_profile
    @user.avatar_url || "profile.jpg"
  end

  def admin_signed_in?
    user_signed_in? && current_user.role == "Admin"
  end

  def avatar_profile user
    user.avatar_url || "profile.jpg"
  end

  def notification_content notification
    "<strong>#{notification.owner.name}</strong> #{notification.status} <strong>#{notification.invoice.name}</strong>".html_safe
  end
end
