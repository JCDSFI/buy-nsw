module Event
  class Event < ApplicationRecord
    # The thing that was changed
    belongs_to :eventable, polymorphic: true
    # Who made the change
    belongs_to :user, optional: true

    def locale_name
      "events.messages.#{type.demodulize.underscore}"
    end

    # Default implementation
    def message
      I18n.t(locale_name)
    end

    def self.submitted_application!(user, application)
      SubmittedApplication.create(
        user: user,
        eventable: application
      )
    end

    def self.manager_approved!(application)
      ManagerApproved.create(
        # The manager did something but they are not a user on the system
        user: nil,
        eventable: application,
        name: application.manager_name,
        email: application.manager_email
      )
    end

    def self.started_application!(user, application)
      StartedApplication.create(
        user: user,
        eventable: application
      )
    end

    def self.assigned_application!(user, application)
      AssignedApplication.create(
        user: user,
        eventable: application,
        email: application.assigned_to.email
      )
    end

    def self.approved_application!(user, application)
      ApprovedApplication.create(
        user: user,
        eventable: application
      )
    end

    def self.rejected_application!(user, application)
      RejectedApplication.create(
        user: user,
        eventable: application
      )
    end

    def self.returned_application!(user, application)
      ReturnedApplication.create(
        user: user,
        eventable: application
      )
    end
  end

  class SubmittedApplication < Event; end

  class StartedApplication < Event; end

  class ApprovedApplication < Event; end

  class RejectedApplication < Event; end

  class ReturnedApplication < Event; end

  class ManagerApproved < Event
    def message
      I18n.t(locale_name, name: name, email: email)
    end
  end

  class AssignedApplication < Event
    def message
      I18n.t(locale_name, email: email)
    end
  end
end
