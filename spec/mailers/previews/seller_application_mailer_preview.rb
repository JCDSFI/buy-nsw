class SellerApplicationMailerPreview < ActionMailer::Preview
  def application_approved_email
    # TODO: Really should have some seed data that has an approved application already there
    application = SellerVersion.approved.first
    SellerApplicationMailer.with(application: application).application_approved_email
  end

  def application_rejected_email
    # TODO: Really should have some seed data that has a rejected application already there
    application = SellerVersion.rejected.first
    SellerApplicationMailer.with(application: application).application_rejected_email
  end

  def application_return_to_applicant_email
    application = SellerVersion.created.where('response IS NOT NULL').first
    SellerApplicationMailer.with(application: application).application_return_to_applicant_email
  end
end
