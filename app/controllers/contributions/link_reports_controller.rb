# frozen_string_literal: true

# "Link melden": report a broken link as change request
class Contributions::LinkReportsController < Contributions::BaseController
  before_action :assign_link

  def new; end

  def create
    create_change_request('report-link', { link_id: @link.id.to_s })
    render :created
  end

  private

  def assign_link
    @link = Link.find(params[:link_id])
    authorize!(:create, ChangeRequest)
  end
end
