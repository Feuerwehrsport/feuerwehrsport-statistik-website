shared_context "as api user", login: :api do
  let(:login_user) { APIUser.first || APIUser.create!(name: "hans") }
  before do
    session[:api_user_id] = login_user.id if respond_to?(:session) and session.present?
    controller.session[:api_user_id] = login_user.id if respond_to?(:controller) and controller.present?
  end
end

shared_context "as sub_admin user", login: :sub_admin do
  let(:login_user) { AdminUser.where(role: :sub_admin).first || AdminUser.create!(name: "sub_admin", email: "sub_admin@a.de", password: "asdf1234", confirmed_at: Time.now, role: :sub_admin) }
  before do
    sign_in login_user
  end
end
