module UI
  class RankTable < CountTable
    def before_initialize
      rank_options = options[:rank_options] || {}
      i = 0
      col("Rang", rank_options) { |row| i += 1 }
    end
  end
end