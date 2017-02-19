class Shop::InvoicesController < Shop::ShopBaseController
  load_and_authorize_resource

  def index
    if params[:status]
      @invoices = @invoices.send params[:status]
      @status = params[:status]
    end
    @load_more = true if params[:load_more] == "1"
    @invoices = search_advanced @invoices, params["search"] if params["search"]
    @invoices = @invoices.order_by_update_time
    @invoices = @invoices.page(params[:page]).includes(:user, user_invoices: [:user]).
      per Settings.per_list_invoice
  end

  def show
    @support = Supports::Invoice.new invoice: @invoice, current_user: current_user
    render layout: false
  end

  def new
  end

  def create
    @invoice = current_user.invoices.new invoice_params
    error = CheckInvoiceMapMarker.new(@invoice).perform
    if error.present?
      @invoice.errors.add :distance_invoice, error
    else
      if @invoice.save
        create_invoice_history = HistoryServices::CreateInvoiceHistoryService.new invoice: @invoice,
          creater_id: current_user.id
        create_invoice_history.perform
        passive_favorites = current_user.passive_favorites.includes :user_tokens,
          :user_setting
        shipper_settings = ShipperSetting.near [@invoice.latitude_start, @invoice.longitude_start],
          Settings.max_distance, order: false
        near_shippers = Shipper.users_by_user_setting(shipper_settings).users_online.
          includes :user_tokens, :user_setting
        invoice_simple = Simples::InvoicesSimple.new object: @invoice,
          scope: {current_user: current_user}
        @invoice_simple = invoice_simple.simple
        if passive_favorites.any?
          # send_all_notification = NotificationServices::SendAllNotificationService.new owner: current_user,
          #   recipients: passive_favorites, status: "favorite", invoice: @invoice,
          #   click_action: Settings.invoice_detail, invoice_simple: @invoice_simple
          # send_all_notification.perform
          send_all_notification = NotificationServicesNodejs::SendAllNotificationServiceNodejs.new owner: current_user,
            recipients: passive_favorites, status: "favorite", invoice: @invoice,
            click_action: Settings.invoice_detail, invoice_simple: @invoice_simple
          send_all_notification.perform
        end


        if near_shippers.any?
          realtime_visibility_shipper = InvoiceServices::RealtimeVisibilityInvoiceService.
            new recipients: near_shippers, invoice: @invoice_simple, action: Settings.realtime.new_invoice
          realtime_visibility_shipper.perform
        end
        flash[:success] = t "invoices.create.success"
        redirect_to shop_root_path
      end
    end
  end

  def edit
  end

  def update
    check_update = if params[:status]
      @user_invoice = @invoice.user_invoices.find_by status: @invoice.status
      shop_update_invoice = InvoiceServices::ShopUpdateInvoiceService.new invoice: @invoice,
        user_invoice: @user_invoice, update_status: params[:status], current_user: current_user
      shop_update_invoice.perform?
      @invoice.type_update = Settings.type_update.status
    else
      @invoice.update_attributes invoice_update_params
      @invoice.type_update = Settings.type_update.invoice
    end
    if check_update
      flash[:success] = t "invoices.messages.update_success"
    else
      flash[:danger] = t "invoices.messages.cant_update"
    end
    @support = Supports::Invoice.new invoice: @invoice, current_user: current_user
  end

  private
  def invoice_params
    params.require(:invoice).permit Invoice::ATTRIBUTES_PARAMS
  end

  def invoice_update_params
    params.require(:invoice).permit Invoice::UPDATE_ATTRIBUTES_PARAMS
  end

  def search_advanced list_invoice, data
    if data["column"]
      list_invoice.where("#{data["type"]} like ?", "%#{data["query"]}%").order data["column"]
    else
      list_invoice.where("#{data["type"]} like ?", "%#{data["query"]}%")
    end
  end
end
