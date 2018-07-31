module Concerns::SellerAliases
  extend ActiveSupport::Concern

  FIELDS = [
    :addresses,
  ]

  included do
    FIELDS.each do |field|
      define_method(field) do |*args, &block|
        seller.public_send(field, *args, &block)
      end
    end
  end

end