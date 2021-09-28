# frozen_string_literal: true

class CollectionDecorator < Draper::CollectionDecorator
  delegate :current_page, :per_page, :offset, :total_entries, :total_pages, :klass

  def show_index_actions?
    !moving_on_index?
  end

  def show_index_move?
    h.resource_class.new.respond_to?(:acts_as_list_top) && count > 1
  end

  def show_index_abort?
    moving_on_index?
  end

  def moving_on_index?
    show_index_move? && h.action_name == 'index' && h.params[:move] && h.params[:position]
  end

  def order(*args)
    object.order(*args).decorate
  end
end
