class Sellers::Applications::MethodsForm < Sellers::Applications::BaseForm
  property :tools,         on: :seller
  property :methodologies, on: :seller
  property :technologies,  on: :seller

  validation :default do
    required(:seller).schema do
      required(:tools).filled(:str?)
      required(:methodologies).filled(:str?)
      required(:technologies).maybe(:str?)
    end
  end
end