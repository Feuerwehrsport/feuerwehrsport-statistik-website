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
end
