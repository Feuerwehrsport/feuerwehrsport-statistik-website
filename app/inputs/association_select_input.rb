# frozen_string_literal: true

class AssociationSelectInput < SimpleForm::Inputs::CollectionSelectInput
  def input(wrapper_options = nil)
    super
    filter = options.delete(:filter) || {}
    show_input_description = options.delete(:show_input_description) == true
    remove_all = !options.delete(:remove_all).nil?
    @builder.template.render(
      partial: 'inputs/association_select',
      locals: {
        association:,
        filter:,
        id_prefix: "as-#{attribute_name}",
        input: super,
        show_input_description:,
        multi_select: multi_select?,
        remove_all:,
      },
    )
  end

  def input_type
    :select
  end

  def input_html_options
    super.merge(multiple: multi_select?)
  end

  def additional_classes
    super + ['association-select']
  end

  def collection
    @collection ||= begin
      options.delete(:collection)
      if multi_select?
        ids = options.delete(:ids)
        ids ||= begin
          collection = object.send(reflection.name)
          collection.is_a?(Array) ? collection.map(&:id) : collection.pluck(:id)
        end
      else
        ids = [object.send(reflection.name).try(:id)].compact
      end
      ids = options.delete(:selected) || ids
      ids = [ids] unless ids.is_a?(Array)
      association_select.send(association, nil, ids, limit: ids.size).map do |d|
        [d[1], d[0], { 'data-info' => d[2], 'data-desc' => d[3] }]
      end
    end
  end

  def association_select
    AssociationSelect.new(@builder.template.current_ability)
  end

  def association
    @association ||= options.delete(:association) || association_fallback_name ||
                     raise("Missing association name for #{attribute_name}")
  end

  def association_fallback_name
    if multi_select?
      reflection.class_name.underscore.parameterize.underscore.pluralize
    else
      reflection.class_name.underscore.parameterize.underscore
    end
  end

  def multi_select?
    reflection.collection?
  end
end
