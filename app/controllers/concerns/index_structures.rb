# frozen_string_literal: true

module IndexStructures
  extend ActiveSupport::Concern

  included do
    helper_method :index_structure
    helper_method :show_structure
    helper_method :index_export_structure
    helper_method :index_export_formats
    helper_method :index_table_max_actions
    class_attribute :index_export_formats
    self.index_export_formats = []
  end

  class_methods do
    def default_index(&)
      define_method(:index_structure) do
        @index_structure ||= Ui::Index::Structure.build(self, &).decorate
      end
    end

    def export_index(*formats, &)
      self.index_export_formats += formats

      define_method(:index_export_structure) do
        unless index_export_formats.map(&:to_sym).include?(request.format.to_sym)
          return Ui::Index::Structure.new.decorate
        end

        Ui::Index::Structure.build(self, &).decorate
      end
    end
  end

  protected

  def send_index_xlsx
    raise ActiveRecord::RecordNotFound unless index_export_formats.map(&:to_sym).include?(:xlsx)

    send_xlsx(Ui::ExcelWorkbook.new(view_context.ca_title, index_export_structure, view_context.collection,
                                    controller_name))
  end

  def index_export_structure
    raise ActiveRecord::RecordNotFound
  end

  def index_structure
    Ui::Index::Structure.new.decorate
  end

  def index_table_max_actions
    2
  end

  def show_structure
    index_structure
  end
end
