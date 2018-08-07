module Sellers::SellerVersion::Contract
  class FinancialStatement < Base
    feature Reform::Form::ActiveModel::FormBuilderMethods
    feature Reform::Form::MultiParameterAttributes

    property :financial_statement_file
    property :financial_statement_expiry, multi_params: true
    property :remove_financial_statement

    validation :default, inherit: true do
      required(:seller_version).schema do
        required(:financial_statement_file).filled(:file?)
        required(:financial_statement_expiry).filled(:date?)
      end
    end

    def started?
      super do |key, value|
        next if key == 'remove_financial_statement'
        value.present?
      end
    end
  end
end
