class Sellers::Applications::RootController < Sellers::Applications::BaseController
  def new
    run Sellers::SellerApplication::Create do |result|
      return redirect_to sellers_application_path(result[:application_model].id)
    end

    redirect_to sellers_dashboard_path
  end

  def show
    unless tailor_step_valid?
      return redirect_to(tailor_sellers_application_path(application))
    end

    render :show
  end

  def submit
    if ! can_submit_application?
      return redirect_to sellers_application_path(application)
    end

    run Sellers::SellerApplication::Submit do |result|
      return redirect_to sellers_dashboard_path
    end

    return redirect_to sellers_application_path(application)
  end

private
  def question_sets
    [
      Sellers::SellerApplication::Tailor::Update::Present,
      Sellers::SellerApplication::Contacts::Update::Present,
      Sellers::SellerApplication::Documents::Update::Present,
      Sellers::SellerApplication::Profile::Update::Present,
      Sellers::SellerApplication::Disclosures::Update::Present,
      Sellers::SellerApplication::Legals::Update::Present,
    ]
  end

  def progress_report
    @progress_report ||= SellerApplicationProgressReport.new(
      application: application,
      question_sets: question_sets,
      product_question_set: Sellers::SellerApplication::Products::Update::Present,
    )
  end
  helper_method :progress_report

  def tailor_step_valid?
    application.tailor_complete?
  end

  def can_submit_application?
    progress_report.all_question_sets_valid?
  end
  helper_method :can_submit_application?

  def submit_form
    @operation ||= run(Sellers::SellerApplication::Submit::Present)
  end
  helper_method :submit_form
end
