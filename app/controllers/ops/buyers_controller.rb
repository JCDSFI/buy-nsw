class Ops::BuyersController < Ops::BaseController

  after_action :set_content_disposition, if: :csv_request?, only: :index

  layout ->{
    action_name == 'index' ? 'ops' : '../ops/buyers/_layout'
  }

  def index
    respond_to do |format|
      format.html
      format.csv
    end
  end

  def deactivate
    run Ops::Buyer::Deactivate do |result|
      flash.notice = I18n.t('ops.buyers.messages.deactivate_success')
      return redirect_to ops_buyer_path(buyer)
    end

    render :show
  end

private
  def search
    @search ||= Search::Buyer.new(
      selected_filters: params,
      default_values: {
        state: 'active',
      },
      page: params.fetch(:page, 1),
      per_page: 25,
    )
  end
  helper_method :search

  def buyer
    @buyer ||= Buyer.find(params[:id])
  end
  helper_method :buyer

  def csv_filename
    "buyers-#{search.selected_filters_string}-#{Time.now.to_i}.csv"
  end

  def set_content_disposition
    response.headers['Content-Disposition'] = "attachment; filename=#{csv_filename}"
  end
end
