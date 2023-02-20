# frozen_string_literal: true

shared_examples 'works like a sessions controller' do |options|
  options ||= {}
  only = options.delete(:only) || %i[new create show destroy]

  let(:login) { create(:m3_login) }
  let(:show_redirects_to_url) { nil }
  let(:login_redirect_url) { { action: :show } }
  let(:params) { {} }
  let(:param_name) { :m3_login_session }

  if only.include?(:new)
    describe 'GET new' do
      it 'returns http success' do
        get :new, params: params
        expect(response).to have_http_status(:success)
      end
    end
  end

  if only.include?(:create)
    describe 'POST create' do
      let(:password) { login.password }
      let(:email_address) { login.email_address }
      subject do
        -> {
          post :create, params: params.merge(param_name => { email_address: email_address,
                                                             password: password })
        }
      end

      context 'when credentials are not correct' do
        let(:password) { 'incorrect' }
        it 'signs in' do
          expect do
            subject.call
          end.to change { ActionMailer::Base.deliveries.count }.by(0)
          expect(assigns(:form_resource)).to have(1).errors_on(:password)
          expect(response).to have_http_status(:success)
          expect(response).to render_template(:new)
          expect(session['m3_login_id']).to eq nil
        end
      end
      context 'when login not exists' do
        let(:password) { '' }
        let(:email_address) { 'not-exists@example.com' }
        it 'signs in' do
          expect do
            subject.call
          end.to change { ActionMailer::Base.deliveries.count }.by(0)
          expect(assigns(:form_resource)).to have(1).errors_on(:password)
          expect(response).to have_http_status(:success)
          expect(response).to render_template(:new)
          expect(session['m3_login_id']).to eq nil
        end
      end
      context 'when credentials are correct' do
        it 'signs in' do
          expect do
            subject.call
          end.to change { ActionMailer::Base.deliveries.count }.by(0)
          expect(response).to redirect_to(login_redirect_url)
          expect(session['m3_login_id']).to eq login.id
        end

        context 'when login not verified' do
          let(:login) { create(:m3_login, :not_verified) }
          it 'resend mail' do
            expect do
              subject.call
            end.to change { ActionMailer::Base.deliveries.count }.by(1)
            expect(response).to have_http_status(:success)
            expect(response).to render_template(:new)
            expect(session['m3_login_id']).to eq nil
          end
        end

        context 'when login expired' do
          let(:login) { create(:m3_login, :expired) }
          it 'resend mail' do
            expect do
              subject.call
            end.to change { ActionMailer::Base.deliveries.count }.by(0)
            expect(response).to redirect_to(controller: 'm3/login/expired_logins',
                                            action: :new,
                                            email_address: login.email_address)
            expect(session['m3_login_id']).to eq nil
          end
        end
      end
    end
  end

  if only.include?(:show)
    describe 'GET show' do
      context 'when logged in' do
        it 'returns http success' do
          get :show, params: params, session: { m3_login_id: login.id }
          if show_redirects_to_url
            expect(response).to redirect_to show_redirects_to_url
          else
            expect(response).to have_http_status(:success)
          end
        end
      end

      context 'when not logged in' do
        it 'redirects to new' do
          get :show, params: params
          expect(response).to redirect_to(action: :new)
        end
      end
    end
  end

  if only.include?(:destroy)
    describe 'DELETE destroy' do
      it 'returns http success' do
        delete :destroy, params: params, session: { m3_login_id: login.id }
        expect(response).to redirect_to(root_path)
        expect(session['m3_login_id']).to eq nil
      end
    end
  end
end
