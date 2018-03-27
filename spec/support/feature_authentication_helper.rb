module FeatureAuthenticationHelper
  def sign_in(user)
    visit new_user_session_path

    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password

    click_button 'Sign in'
  end
end

RSpec.configure do |config|
  config.include FeatureAuthenticationHelper, type: :feature

  config.before(:each, type: :feature) do |example|
    unless example.metadata[:skip_login]
      @user = create(:seller_user)
      sign_in @user
    end
  end
end
