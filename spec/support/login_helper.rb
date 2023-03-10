# frozen_string_literal: true

shared_context 'when api user', login: :api do
  let(:login_user) do
    ApiUser.first || ApiUser.create!(name: 'hans', ip_address_hash: 'a', user_agent_hash: 'a',
                                     email_address: 'hans@wurst.de')
  end
  before do |example|
    if example.metadata[:type] == :request

      patch_session = proc { |session, key|
        if key == :api_user_id
          login_user.id
        elsif session.key?(key)
          session.fetch(key)
        end
      }
      allow_any_instance_of(ActionDispatch::Request::Session).to receive(:[], &patch_session)
    end

    # session[:api_user_id] = login_user.id if respond_to?(:session) && session.present?
    # controller.session[:api_user_id] = login_user.id if respond_to?(:controller) && controller.present?
  end
end

%i[user sub_admin admin].each do |user_type|
  shared_context "when #{user_type} user", login: user_type do
    let(:login_user) { AdminUser.where(role: user_type).first || create(:admin_user, user_type) }
    before do
      login = login_user.login

      patch_session = proc { |session, key|
        if key == M3::Login::Session::ID_KEY
          login.id
        elsif session.key?(key)
          session.fetch(key)
        end
      }
      allow_any_instance_of(ActionController::TestSession).to receive(:[], &patch_session)
      allow_any_instance_of(ActionDispatch::Request::Session).to receive(:[], &patch_session)
    end
  end
end
