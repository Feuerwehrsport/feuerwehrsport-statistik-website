# frozen_string_literal: true

class Registrations::CompetitionsController < Registrations::BaseController
  default_actions
  member_actions :show, :edit, :destroy

  filter_index do |by|
    by.scope :past_records
  end

  default_index do |t|
    t.col :date
    t.col :name
    t.col :place
  end

  form_for :new, :create do |f|
    f.input :from_template, as: :hidden, input_html: { value: params[:from_template], name: 'from_template' }
    f.inputs 'Allgemeine Daten' do
      f.input :name
      f.input :date, html5: true
      f.input :place
      f.input :description, as: :wysiwyg
    end

    f.inputs 'Wertungen' do
      f.input :group_score
    end

    f.inputs 'Öffentlichkeitseinstellungen' do
      f.input :published
    end
  end

  form_for :edit, :update do |f|
    f.input :name
    f.input :date, html5: true
    f.input :place
    f.input :description, as: :wysiwyg
    f.input :hint_to_hint
    f.association :admin_user if can?(:manage, AdminUser)
  end

  def show
    super

    if request.format.pdf?
      authorize!(:export, resource)
      send_pdf(Registrations::Competitions::Pdf, resource, current_ability)
    elsif request.format.wettkampf_manager_import? || request.format.xlsx?
      authorize!(:export, resource)
      response.headers['Content-Disposition'] =
        "attachment; filename=\"#{resource.decorate.to_s.parameterize}.#{request.format.to_sym}\""
      if request.format.wettkampf_manager_import?
        render body: resource.to_serializer.to_json, content_type: Mime[:wettkampf_manager_import]
      end
    else
      flash[:warning] = "Die Online-Anmeldungen werden bald abgeschaltet. Bitte benutzt in Zukunft das neue Portal <b><a href='https://feusport.de'>feusport.de</a></b>"
    end
  end

  def new
    redirect_to action: :new_select_template
  end

  def create
    if params[:first].present?
      render :new
    else
      super
    end
  end

  def new_select_template; end

  def slug_handle
    competition = Registrations::Competition.find_by!(slug: params[:slug])
    redirect_to action: :show, id: competition.id
  end

  protected

  def page_size
    15
  end

  def build_resource
    super.tap do |resource|
      resource.assign_attributes(admin_user: current_admin_user, published: true)
      if params[:from_template].present?
        Registrations::Competition::TEMPLATES[params[:from_template].to_i].block.call(resource)
      end
    end
  end
end
