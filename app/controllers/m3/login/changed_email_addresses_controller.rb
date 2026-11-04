# frozen_string_literal: true

class M3::Login::ChangedEmailAddressesController < ApplicationController
  default_actions :edit, :update

  default_form do |f|
    f.value :old_email_address
    f.value :changed_email_address
    f.input :change_email_address, as: :hidden, input_html: { value: '1' }
  end
end
