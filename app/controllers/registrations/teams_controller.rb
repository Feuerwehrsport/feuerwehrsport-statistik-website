class Registrations::TeamsController < Registrations::BaseController
  default_actions :new, :create, :show, :edit, :update, :destroy
  belongs_to Registrations::Competition, url: -> { collection_redirect_url }

  default_form do |f|
    f.inputs :allgemein do
      f.input :name
      f.input :team_number
      f.input :shortcut
      f.input :gender, as: :hidden
      f.value :gender_translated
      f.association :federal_state
    end
    f.inputs :team_leader do
      f.input :team_leader
      f.input :street_with_house_number
      f.input :postal_code
      f.input :locality
      f.input :phone_number
      f.input :email_address
    end

    if parent_resource.team_tag_list.present?
      f.inputs :additional_data do
        f.input :tag_names, as: :check_boxes, collection: parent_resource.team_tag_list
      end
    end

    if requestable_assessments.present?
      f.inputs :assessments do
        f.association :assessments, as: :check_boxes, collection: requestable_assessments, label_method: :with_image
      end
    end
  end

  def new
    redirect_to action: :new_select_gender
  end

  def create
    if params[:from_gender_select].present?
      form_resource.assign_attributes(resource_params)
      render :new
    else
      super
    end
  end

  def new_select_gender
    @genders = [
      build_resource.tap { |r| r.gender = :female },
      build_resource.tap { |r| r.gender = :male },
    ]
  end

  def show
    super

    format = request.format.to_sym
    return unless format.in?(%i[xlsx pdf])
    authorize!(:export, resource)
    response.headers['Content-Disposition'] = "attachment; filename=\"#{resource.to_s.parameterize}.#{format}\""
  end

  protected

  def build_resource
    super.tap do |resource|
      resource.admin_user = current_admin_user
      resource.assessments = requestable_assessments(resource)
    end
  end

  def collection_redirect_url
    url_for(parent_resource)
  end

  def requestable_assessments(team = form_resource)
    Registrations::Assessment.requestable_for(team)
  end
end
