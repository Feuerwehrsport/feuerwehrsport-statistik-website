# frozen_string_literal: true

class CollectionCheckBoxesInlineInput < SimpleForm::Inputs::CollectionCheckBoxesInput
  def input_type
    :check_boxes
  end

  def item_wrapper_class
    'checkbox-inline'
  end
end
