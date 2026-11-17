# frozen_string_literal: true

class NationDecorator < AppDecorator
  delegate :to_s, to: :name

  def nation_flag(options = {})
    h.image_tag("flags-iso/#{iso}.png", { title: name, width: 16 }.merge(options))
  end

  def nation_flag_with_iso
    h.content_tag(:span, h.safe_join([nation_flag, nation.iso.upcase], ' '), class: 'nation-iso', title: name)
  end
end
