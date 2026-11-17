# frozen_string_literal: true

# SimpleForm wrappers for Bootstrap 5 (horizontal forms: label 3, input 9 columns)
SimpleForm.setup do |config|
  config.error_notification_class = 'alert alert-danger'
  config.button_class = 'btn'
  config.boolean_label_class = 'form-check-label'
  config.input_field_error_class = 'is-invalid'
  config.input_field_valid_class = nil
  config.item_wrapper_tag = :div
  config.item_wrapper_class = 'form-check'
  config.include_default_input_wrapper_class = false

  feedback = ->(b) do
    b.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
    b.use :hint, wrap_with: { tag: 'div', class: 'form-text' }
  end

  config.wrappers :vertical_form, tag: 'div', class: 'mb-3' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: 'form-label'
    b.use :input, class: 'form-control'
    feedback.(b)
  end

  config.wrappers :horizontal_form, tag: 'div', class: 'row mb-3' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: 'col-sm-3 col-form-label'
    b.wrapper tag: 'div', class: 'col-sm-9' do |ba|
      ba.use :input, class: 'form-control'
      feedback.(ba)
    end
  end

  config.wrappers :horizontal_select, tag: 'div', class: 'row mb-3' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: 'col-sm-3 col-form-label'
    b.wrapper tag: 'div', class: 'col-sm-9' do |ba|
      ba.use :input, class: 'form-select'
      feedback.(ba)
    end
  end

  config.wrappers :horizontal_file_input, tag: 'div', class: 'row mb-3' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: 'col-sm-3 col-form-label'
    b.wrapper tag: 'div', class: 'col-sm-9' do |ba|
      ba.use :input, class: 'form-control'
      feedback.(ba)
    end
  end

  config.wrappers :horizontal_boolean, tag: 'div', class: 'row mb-3' do |b|
    b.use :html5
    b.optional :readonly
    # label on the left like the other inputs, an optional inline label (t3 inline_labels) next to the box
    b.use :label, class: 'col-sm-3 col-form-label pt-0'
    b.wrapper tag: 'div', class: 'col-sm-9' do |wr|
      wr.wrapper tag: 'div', class: 'form-check' do |bb|
        bb.use :input, class: 'form-check-input'
      end
      feedback.(wr)
    end
  end

  config.wrappers :horizontal_collection, item_wrapper_class: 'form-check', item_label_class: 'form-check-label',
                                          tag: 'div', class: 'row mb-3' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: 'col-sm-3 col-form-label pt-0'
    b.wrapper tag: 'div', class: 'col-sm-9' do |ba|
      ba.use :input, class: 'form-check-input'
      feedback.(ba)
    end
  end

  config.wrappers :horizontal_multi_select, tag: 'div', class: 'row mb-3' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: 'col-sm-3 col-form-label'
    b.wrapper tag: 'div', class: 'col-sm-9 d-flex flex-wrap gap-2' do |ba|
      ba.use :input, class: 'form-select w-auto'
      feedback.(ba)
    end
  end

  config.wrappers :inline_form, tag: 'div', class: 'col-12' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: 'visually-hidden'
    b.use :input, class: 'form-control'
    feedback.(b)
  end

  config.default_wrapper = :horizontal_form
  config.wrapper_mappings = {
    boolean: :horizontal_boolean,
    check_boxes: :horizontal_collection,
    radio_buttons: :horizontal_collection,
    file: :horizontal_file_input,
    select: :horizontal_select,
    datetime: :horizontal_multi_select,
    date: :horizontal_multi_select,
    time: :horizontal_multi_select,
  }
end
