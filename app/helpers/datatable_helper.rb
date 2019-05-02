module DatatableHelper
  def datatable(key)
    structure = datatables[action_name][key]

    data = {
      columnDefs: [],
      ajax: {
        url: url_for(format: :json, datatable: key),
      },
    }

    structure.each_with_index do |field, index|
      defs = { targets: index }
      defs[:className] = field.options[:class] if field.options[:class].present?
      if field.sortable?
        data[:aaSorting] ||= [[index, 'asc']]
      else
        defs[:orderable] = false
      end
      data[:aaSorting] = [[index, field.default_order]] if field.default_order.present?
      data[:columnDefs].push(defs)
    end

    render 'ui/datatable', structure: structure, data: data
  end
end
