# frozen_string_literal: true

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
      parent_resource.bands.each do |band|
        band.send(type).each do |res|
          add_file = type == :teams ? form_resource.add_registration_file : false
          Registrations::CompetitionMailer.with(
            resource: res, competition: parent_resource, subject: form_resource.subject,
            text: form_resource.text, file: add_file, sender: form_resource.admin_user
          ).news.deliver_later
        end
      end
    end

    super
  end
end
