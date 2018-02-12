class Ipo::RegistrationsController < ApplicationController
  default_actions

  default_form do |f|
    f.inputs :contact do
      f.input :name
      f.input :locality
      f.input :phone_number
      f.input :email_address
    end
    f.inputs :team do
      f.input :team_name
      f.input :youth_team
      f.input :female_team
      f.input :male_team
    end
    f.inputs :terms_of_service do
      f.value ' ', value: t3('terms_of_service_html')
      f.input :terms_of_service
    end
  end

  filter_index do |by|
    by.string :team_name
    by.scope :youth_team
    by.scope :male_team
    by.scope :female_team
  end

  default_index do |t|
    t.col :team_name
    t.col :email_address
    t.col :youth_team_translated, sortable: :youth_team
    t.col :female_team_translated, sortable: :female_team
    t.col :male_team_translated, sortable: :male_team
    t.col :created_at
  end

  export_index :xlsx do |t|
    t.col :id
    t.col :name
    t.col :locality
    t.col :phone_number
    t.col :email_address
    t.col :team_name
    t.col :youth_team_translated
    t.col :female_team_translated
    t.col :male_team_translated
    t.col :created_at
  end

  def create
    if registration_open? || can?(:manage, resource_class)
      super
    else
      render 'not_open'
    end
  end

  def new
    if registration_open? || can?(:manage, resource_class)
      super
    else
      render 'not_open'
    end
  end

  def finish
    return if cookies[:ipo_registration].blank?
    @registration = base_collection.find(cookies[:ipo_registration])
    cookies.delete(:ipo_registration)
  end

  protected

  def registration_open?
    Rails.configuration.ipo.registration_open > Time.current &&
      Rails.configuration.ipo.registration_close < Time.current
  end

  def after_create
    if can?(:manage, resource_class)
      super
    else
      deliver_later(Ipo::RegistrationMailer, :confirm, resource)
      cookies[:ipo_registration] = form_resource.id
      redirect_to action: :finish
    end
  end
end
