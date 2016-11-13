require 'test_helper'

class CreateUserTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
  end

  after do
    Capybara.use_default_driver
  end

  describe 'admin user' do
    before do
      @user = create :user, role: :admin
      log_in_as @user
    end

    it 'should be able to create user' do
      assert_difference('User.count', 1) do
        assert_difference 'Devise.mailer.deliveries.count', 1 do
          assert_text 'Create User'
          click_link 'Create User'

          assert has_field? 'Email'
          fill_in 'Email', with: 'test@test.com'

          assert has_field? 'Name'
          fill_in 'Name', with: 'Test User'

          click_button 'Add'
        end
      end

      user = User.find_by(email: 'test@test.com')
      assert_not_nil user
      assert_equal user.name, 'Test User'
    end

    it 'should validate form correctly' do
      visit new_user_path
      click_button 'Add'

      assert_text "can't be blank"

      fill_in 'Email', with: 'test@test'

      assert_no_difference 'Devise.mailer.deliveries.count' do
        click_button 'Add'
      end

      assert_text 'is invalid'
    end
  end

  describe 'non admin user' do
    before do
      @user = create :user, role: :cm
      log_in_as @user
    end

    it 'should not show add user button' do
      assert_no_text 'Create User'
    end

    it 'should redirect to root path if navigate to form' do
      assert_not @user.admin?
      visit new_user_path
      assert_equal current_path, root_path
    end
  end

  describe 'not logged in' do
    it 'should show nothing if not logged in' do
      visit new_user_path
      assert_equal current_path, new_user_session_path
    end
  end
end