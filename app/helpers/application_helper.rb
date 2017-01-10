module ApplicationHelper
  def admin_signed_in?
    user_signed_in? && current_user.role == "Admin"
  end

  def avatar_profile avatar_url
    avatar_url || "profile.jpg"
  end

  def sidebar_active controller_name
    "menu-active" if params[:controller] == controller_name
  end

  def sort_table *args
    @q = args[0]
    @q ||= Hash.new
    @q[:attribute] = args[1]
    resource_controller = params[:controller].split('/').last
    form_tag send("shop_#{resource_controller}_path", q: @q.to_h), method: :get, remote: true do
      hidden_field_tag("q[sortable]", "ASC", id: @q[:attribute]) +
        submit_tag(args[2], class: "nht-btn-sortable") +
        "<span class='caret #{@q[:attribute]}'></span>".html_safe
    end
  end
end
