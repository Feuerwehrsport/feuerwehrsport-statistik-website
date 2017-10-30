module UI
  class RankTable < CountTable
    def before_initialize
      rank_options = options[:rank_options] || {}
      i = 0
      col('Rang', rank_options) { |_row| i += 1 }
    end
  end
end
