# frozen_string_literal: true

class ActionManager::ActionDecorator < ApplicationDecorator
  def link_to(options = {}, &block)
    if block_given?
      h.link_to url, options, &block
    else
      h.link_to link_label, url, options
    end
  end

  def link_label
    h.t3("actions.#{name}")
  end

  def link_to?
    object.link_to? && (h.action_name != name.to_s)
  end

  def url
    nil
  end

  protected

  def can?(*args)
    object.send(:can?, *args)
  end
end
