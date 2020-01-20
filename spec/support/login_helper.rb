shared_context 'when api user', login: :api do
  let(:login_user) { APIUser.first || APIUser.create!(name: 'hans', ip_address_hash: 'a', user_agent_hash: 'a') }
  before do
    session[:api_user_id] = login_user.id if respond_to?(:session) && session.present?
    controller.session[:api_user_id] = login_user.id if respond_to?(:controller) && controller.present?
  end
end

%i[user sub_admin admin].each do |user_type|
  shared_context "when #{user_type} user", login: user_type do
    let(:login_user) { AdminUser.where(role: user_type).first || create(:admin_user, user_type) }
    before { mock_m3_login(login_user.login) }
  end
end
