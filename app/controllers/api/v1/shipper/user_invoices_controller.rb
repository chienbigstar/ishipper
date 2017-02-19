class Api::V1::Shipper::UserInvoicesController < Api::ShipperBaseController
  before_action :ensure_params_exist, :check_received_invoice,
    :check_invoice_status, :check_black_list, only: :create
  before_action :check_delete_user_invoice, only: :destroy
  before_action :find_user_invoice, only: :update

  def create
    @user_invoice = current_user.user_invoices.build user_invoice_params
    new_shipper_limit = ShipperReceiveLimitServices::NewShipperLimitService.new user_id: current_user.id
    @recipient = @invoice.user
    can_create = if new_shipper_limit.perform?
      if @user_invoice.save
        invoice_simple = Simples::Invoice::ShipperInvoicesSimple.new object: @invoice,
          scope: {current_user: current_user}
        @invoice_simple = invoice_simple.simple
        render json: {message: I18n.t("user_invoices.receive_invoice.success"),
          data: {invoice: @invoice_simple}, code: 1}, status: 200
        true
      else
        render json: {message: I18n.t("user_invoices.receive_invoice.fail"), data: {},
          code: 0}, status: 200
        false
      end
    else
      old_shipper_limit = ShipperReceiveLimitServices::OldShipperLimitService.new user_id: current_user.id
      if old_shipper_limit.perform?
        if @user_invoice.save
          invoice_simple = Simples::Invoice::ShipperInvoicesSimple.new object: @invoice,
            scope: {current_user: current_user}
          @invoice_simple = invoice_simple.simple
          render json: {message: I18n.t("user_invoices.receive_invoice.success"),
            data: {invoice: @invoice_simple}, code: 1}, status: 200
          true
        else
          render json: {message: I18n.t("user_invoices.receive_invoice.fail"), data: {},
            code: 0}, status: 200
          false
        end
      else
        render json: {message: I18n.t("user_invoices.receive_invoice.limit"), data: {},
          code: 0}, status: 200
        false
      end
    end

    if can_create
      create_user_invoice_history = HistoryServices::CreateUserInvoiceHistoryService.
        new user_invoice: @user_invoice, creater_id: current_user.id, status: "init"
      create_user_invoice_history.perform
      create_notification = NotificationServicesNodejs::CreateNotificationServiceNodejs.new owner: current_user,
        recipient: @recipient, status: "receive", invoice: @invoice,
        click_action: Settings.list_shipper_register, invoice_simple: @invoice
      create_notification.perform
    end
  end

  def update
    if @user_invoice.update_attributes status: "rejected"
      render json: {message: I18n.t("user_invoices.cancel_request.success"), data: {},
        code: 1}, status: 200
      shipper_simple = Simples::Shipper::ListShippersSimple.new object: current_user,
        scope: {invoice: @user_invoice.invoice, current_user: current_user}
      @shipper = shipper_simple.simple
      realtime_channel = "#{@user_invoice.invoice.user.phone_number}_realtime_channel"
        data = Hash.new
        data[:user] = current_user
        invoices_simple = Simples::Invoice::ShopInvoicesSimple.new object: @user_invoice.invoice,
          scope: {current_user: current_user}
        @invoice = invoices_simple.simple

        data[:invoice] = @invoice
        RealtimeBroadcastJob.perform_now channel: realtime_channel,
          action: Settings.realtime.cancel_invoice, data: data
    else
      render json: {message: I18n.t("user_invoices.cancel_request.fail"), data: {},
        code: 0}, status: 200
    end
  end

  def destroy
    if @user_invoice_delete.destroy
      render json: {message: I18n.t("user_invoices.delete.success"), data: {},
        code:1}, status: 200
    else
      render json: {message: I18n.t("user_invoices.delete.fails"), data: {},
        code:0},status: 200
    end
  end

  private
  def user_invoice_params
    params.require(:user_invoice).permit :invoice_id
  end

  def check_received_invoice
    @invoice = Invoice.includes(user: [:user_tokens]).find_by id: user_invoice_params[:invoice_id]
    if @invoice.nil?
      render json: {message: I18n.t("invoices.messages.invoice_not_found"),
        data: {}, code: 0}, status: 200
    end
    @user_invoice = current_user.user_invoices.find_by invoice: @invoice, status: "init"
    if @user_invoice
      render json: {message: I18n.t("user_invoices.receive_invoice.received"),
        data: {}, code: 0}, status: 200
    end
  end

  def check_invoice_status
    unless @invoice.init?
      render json: {message: I18n.t("user_invoices.receive_invoice.fail"),
        data: {}, code: 0}, status: 200
    end
  end

  def check_delete_user_invoice
    @user_invoices = Invoice.find_by(id: params[:id]).user_invoices
    @user_invoice_delete = @user_invoices.find_by user: current_user
    if @user_invoice_delete.nil?
      render json: {message: I18n.t("user_invoices.delete.nil"), data: {},
        code:0},status: 200
    end
  end

  def check_black_list
    @black_list = BlackList.find_by owner_id: @invoice.user_id,
      black_list_user_id: current_user.id
    if @black_list
      render json: {message: I18n.t("black_list.permission_denied"), data: {},
        code: 1}, status: 200
    end
  end

  def find_user_invoice
    @user_invoice = current_user.user_invoices.find_by_id params[:id]
    if @user_invoice.nil? || !@user_invoice.init?
      render json: {message: I18n.t("user_invoices.cancel_request.cant_cancel"),
        data: {}, code: 0}, status: 200
    end
  end
end
