class ConditionRateServices::ShopConditionService
  attr_reader :args

  def initialize args
    @invoice = args[:invoice]
    @user_invoice = args[:user_invoice]
    @current_user = args[:current_user]
  end

  def perform?
    check_params? && check_shop_invoice_status? && check_correct_shop?
  end

  private
  def check_params?
    @invoice.present? && @user_invoice.present? && @current_user.present?
  end

  def check_shop_invoice_status?
    @invoice.finished?
  end

  def check_correct_shop?
    @invoice.user == @current_user
  end
end
