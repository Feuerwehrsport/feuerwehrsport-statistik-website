# frozen_string_literal: true

class M3::AssetsController < ApplicationController
  layout 'iframe_widget'
  default_actions :index, :new, :create, :edit, :update, :destroy
  member_actions :select, :edit, :destroy

  default_index do |t|
    t.col :name
    t.col :file_name, sortable: :file
    t.col :created_at
  end

  default_form do |f|
    f.input :name
    if form_resource.file.image?
      f.input :file, as: :image_preview
    else
      f.input :file
    end
  end

  protected

  def build_resource
    resource_class.new(website: m3_website)
  end
end
