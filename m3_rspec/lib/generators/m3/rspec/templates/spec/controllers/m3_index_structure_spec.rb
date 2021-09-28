# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'm3_index_structure' do
  let(:parent_resources) do
    {
      # Billing::CoursesController => create(:teacher),
    }
  end
  # let(:exclude_controllers) { [Billing::CoursesController] }
  # let(:m3_index_structure_debug) { true }

  include_examples 'orders all index fields'

  # Exampe to change params before test:
  # include_examples "orders all index fields" do
  #   let(:params_handler) do
  #     ->(params, controller_instance) do
  #       params[:faq_id] = params[:parent_id] if controller_instance.is_a?(Web::ChildFaqsController)
  #       params
  #     end
  #   end
  # end
end
