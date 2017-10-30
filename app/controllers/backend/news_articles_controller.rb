class Backend::NewsArticlesController < Backend::BackendController
  backend_actions

  default_form do |f|
    f.input :title
    f.input :content # as: :wysiwyg # TODO
    f.association :admin_user
    f.input :published_at
  end

  filter_index do |by|
    by.scope :admin_user, collection: AdminUser.filter_collection, label_method: :name_with_role
  end

  default_index do |t|
    t.col :title
    t.col :admin_user, sortable: false
    t.col :published_at
  end

  default_show do |t|
    t.col :title
    t.col :content
    t.col :admin_user
    t.col :published_at
  end
end
