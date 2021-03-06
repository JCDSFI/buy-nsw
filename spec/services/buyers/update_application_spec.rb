require 'rails_helper'

RSpec.describe Buyers::UpdateApplication do

  let(:buyer_user) { create(:inactive_buyer_user) }
  let(:form) { BuyerApplications::BasicDetailsForm }
  let(:attributes) {
    attributes_for(:completed_buyer_application).slice(:name, :organisation)
  }

  describe '.call' do
    context 'given valid attributes' do
      subject {
        described_class.call(
          user: buyer_user,
          form_class: form,
          attributes: attributes,
        )
      }

      it 'is successful' do
        expect(subject).to be_success
      end

      it 'persists the changes' do
        expect(subject.application.reload.name).to eq(attributes[:name])
      end
    end

    context 'given invalid attributes' do
      subject {
        described_class.call(
          user: buyer_user,
          form_class: form,
          attributes: { name: '' },
        )
      }

      it 'fails' do
        expect(subject).to be_failure
      end
    end

    context 'when Buyers::BuildUpdateApplication fails' do
      before(:each) do
        expect(Buyers::BuildUpdateApplication).to receive(:call).
          with(user: buyer_user, form_class: form).
          and_return(
            double(success?: false, failure?: true)
          )
      end

      subject {
        described_class.call(
          user: buyer_user,
          form_class: form,
          attributes: attributes,
        )
      }

      it 'fails' do
        expect(subject).to be_failure
      end
    end
  end

end
