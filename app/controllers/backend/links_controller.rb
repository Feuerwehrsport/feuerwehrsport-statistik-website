class Backend::LinksController < Backend::BackendController
  backend_actions

  default_form do |f|
    f.input :label
    f.input :linkable_id
    f.input :linkable_type
    f.input :url
  end

  filter_index do |by|
    by.scope :linkable_type, collection: Link.pluck(:linkable_type).uniq
    by.scope :linkable_id, collection: Link.pluck(:linkable_id).uniq.map(&:to_s)
  end

  default_index do |t|
    t.col :label
    t.col :linkable, sortable: %i[linkable_type linkable_id]
    t.col :linkable_type
    t.col :url
  end
end
