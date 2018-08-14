class Buyers::SubmitApplication < ApplicationService
  def initialize(user:)
    @user = user
  end

  def call
    begin
      ActiveRecord::Base.transaction do
        validate_state
        validate_completion
        update_state
        send_manager_approval_email
        log_event
        send_slack_notification
      end

      self.state = :success
    rescue Failure
      self.state = :failure
    end
  end

  def application
    @application ||= user.buyer
  end

private
  attr_reader :user

  def flow
    BuyerApplicationFlow.new(application)
  end

  def validate_state
    raise Failure unless user.present? && application.present? && application.may_submit?
  end

  def validate_completion
    raise Failure unless flow.valid?
  end

  def update_state
    application.submit!
  end

  def send_manager_approval_email
    application.set_manager_approval_token!

    mailer = BuyerApplicationMailer.with(application: application)
    mailer.manager_approval_email.deliver_later
  end

  def send_slack_notification
    SlackPostJob.perform_later(
      application.id,
      :buyer_application_submitted.to_s,
    )
  end

  def log_event
    Event::SubmittedApplication.create(
      user: user,
      eventable: application,
    )
  end
end
