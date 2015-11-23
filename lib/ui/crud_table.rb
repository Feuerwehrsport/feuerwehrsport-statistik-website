module UI
  class CRUDTable < CountTable
    def after_initialize
      col("Aktionen", class: "col-md-3") do |row|
        ButtonDropdown.new(view, row, only: [:show, :edit], links: [:destroy], class: "btn-group-xs")
      end
    end
  end
end