class AddSlugToSeriesRound < ActiveRecord::Migration
  def change
    add_column :series_rounds, :slug, :string
    Series::Round.all.each do |round|
      round.update!(slug: round.name.parameterize)
    end
    change_column_null :series_rounds, :slug, false
  end
end
