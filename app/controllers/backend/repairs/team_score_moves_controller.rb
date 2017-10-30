class Backend::Repairs::TeamScoreMovesController < Backend::BackendController
  backend_actions :new, :create

  default_form do |f|
    f.association :source_team, as: :association_select
    f.association :destination_team, as: :association_select
  end

  protected

  def after_create
    render :create
  end
end
