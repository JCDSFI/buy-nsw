module BuyerApplications
  class EmploymentStatusForm < BaseForm
    property :employment_status

    validation :default, inherit: true do
      required(:employment_status, in_list?: BuyerApplication.employment_status.options).filled
    end
  end
end
