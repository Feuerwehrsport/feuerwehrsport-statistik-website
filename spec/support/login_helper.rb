shared_context "as api user", login: :api do
  before do
    user = APIUser.first || APIUser.create!(name: "hans")
    session[:user_id] = user.id if respond_to?(:session) and session.present?
    controller.session[:user_id] = user.id if respond_to?(:controller) and controller.present?
  end
end
