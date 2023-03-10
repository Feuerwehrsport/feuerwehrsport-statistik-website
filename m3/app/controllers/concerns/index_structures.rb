# frozen_string_literal: true

module IndexStructures
  extend ActiveSupport::Concern

  included do
    helper_method :m3_index_structure
    helper_method :m3_show_structure
    helper_method :m3_index_export_structure
    helper_method :m3_index_export_formats
    helper_method :m3_index_table_max_actions
    class_attribute :m3_index_export_formats
    self.m3_index_export_formats = []
  end

  class_methods do
    def default_index(&)
      define_method(:m3_index_structure) do
        @m3_index_structure ||= M3::Index::Structure.build(self, &).decorate
      end
    end

    def export_index(*formats, basename: nil, &block)
      self.m3_index_export_formats += formats

      define_method(:m3_index_export_structure) do
        unless m3_index_export_formats.map(&:to_sym).include?(request.format.to_sym)
          return M3::Index::Structure.new.decorate
        end

        if basename.present? && request.format == Mime[:xlsx]
          current_basename = basename.respond_to?(:call) ? instance_exec(&basename) : basename.dup
          if request.format.xlsx?
            response.headers['Content-Disposition'] = "attachment; filename=\"#{current_basename}.xlsx\""
          end
        end

        M3::Index::Structure.build(self, &block).decorate
      end
    end
  end

  protected

  def m3_index_structure
    M3::Index::Structure.new.decorate
  end

  def m3_index_table_max_actions
    2
  end

  def m3_show_structure
    m3_index_structure
  end
end
