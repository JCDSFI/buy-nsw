require 'rails_helper'

RSpec.describe Sellers::SellerVersion::Contract::ProfessionalIndemnity do
  let(:version) { create(:seller_version) }
  subject { described_class.new(version) }

  let(:example_pdf) {
    Rack::Test::UploadedFile.new(
      Rails.root.join('spec', 'fixtures', 'files', 'example.pdf'),
      'application/pdf'
    )
  }
  let(:future_date) { Date.today + 1.year }
  let(:historical_date) { Date.today - 1.year }

  let(:atts) {
    {
      professional_indemnity_certificate_file: example_pdf,
      professional_indemnity_certificate_expiry: future_date,
    }
  }

  it 'validates with valid attributes' do
    expect(subject.validate(atts)).to eq(true)
  end

  context 'professional_indemnity_certificate_file' do
    it 'is invalid when blank' do
      subject.validate(atts.merge(professional_indemnity_certificate_file: nil))

      expect(subject).to_not be_valid
      expect(subject.errors[:professional_indemnity_certificate_file]).to be_present
    end

    it 'is invalid with an unsupported filetype' do
      invalid_file = Rack::Test::UploadedFile.new(
        Rails.root.join('spec', 'fixtures', 'files', 'invalid.html')
      )
      subject.validate(atts.merge(
        professional_indemnity_certificate_file: invalid_file
      ))

      expect(subject.save).to be_falsey
    end

    it 'is invalid with an unsupported content type' do
      invalid_file = Rack::Test::UploadedFile.new(
        Rails.root.join('spec', 'fixtures', 'files', 'example.pdf'),
        'text/html'
      )
      subject.validate(atts.merge(
        professional_indemnity_certificate_file: invalid_file
      ))

      expect(subject.save).to be_falsey
    end
  end

  context 'professional_indemnity_certificate_expiry' do
    it 'is invalid when blank' do
      subject.validate(atts.merge(professional_indemnity_certificate_expiry: nil))

      expect(subject).to_not be_valid
      expect(subject.errors[:professional_indemnity_certificate_expiry]).to be_present
    end

    it 'is invalid when in the past' do
      subject.validate(atts.merge(professional_indemnity_certificate_expiry: historical_date))

      expect(subject).to_not be_valid
      expect(subject.errors[:professional_indemnity_certificate_expiry]).to be_present
    end
  end
end
