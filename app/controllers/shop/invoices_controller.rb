class Shop::InvoicesController < Shop::ShopBaseController
  load_and_authorize_resource

  def new
  end

  def create
    if @invoice.save
      InvoiceHistoryCreator.new(@invoice, current_user.id).create_history invoice_params
      flash[:danger] = t "invoices.create.success"
      redirect_to root_path
    else
      render :new
    end
  end

  private
  def invoice_params
    params.require(:invoice).permit Invoice::ATTRIBUTES_PARAMS
  end
end
