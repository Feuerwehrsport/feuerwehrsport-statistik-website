# frozen_string_literal: true

class M3::LoginsController < ApplicationController
  default_actions :index, :edit, :update, for_class: M3::Login::Base

  default_index do |t|
    t.col :name
    t.col :email_address
    t.col :verified_at
    t.col :expired_at
  end

  default_form do |f|
    f.value :name
    f.input :email_address
    f.value :verified_at, label: resource_class.human_attribute_name(:verified_since) if form_resource.verified?
    f.input :verified, as: :boolean
    f.input :expired_at
  end
end
