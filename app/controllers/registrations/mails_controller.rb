class Registrations::MailsController < Registrations::BaseController
  default_actions :new, :create
  belongs_to Registrations::Competition, url: -> { collection_redirect_url }

  default_form do |f|
    f.inputs 'Inhalt' do
      f.input :subject
      f.input :text, as: :text
      f.input :add_registration_file
    end
    f.inputs 'Empfänger' do
      f.value :team_receivers_count
      f.value :person_receivers_count
    end
  end

  protected

  def build_resource
    super.tap { |r| r.assign_attributes(admin_user: current_admin_user) }
  end

  def collection_redirect_url
    registrations_competition_path(parent_resource)
  end

  def after_create
    flash[:success] = 'E-Mail wird im Hintergrund versendet'

    %i[teams people].each do |type|
      form_resource.send(type).each do |res|
        add_file = type == :teams ? form_resource.add_registration_file : false
        deliver_later(Registrations::CompetitionMailer, :news, res, parent_resource, form_resource.subject,
                      form_resource.text, add_file, form_resource.admin_user)
      end
    end

    super
  end
end
