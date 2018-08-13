module Products
  class BaseForm < Reform::Form
    include Concerns::Contracts::Status
    include Forms::ValidationHelper

    def product_id
      model.id
    end

    def upload_for(key)
      self.model.public_send(key)
    end
  end
end