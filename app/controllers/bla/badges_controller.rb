class BLA::BadgesController < ResourceController
  resource_actions :index, cache: %i[index]

  export_index do |t|
    t.col(:person)
    t.col(:year)
    t.col(:status)
    t.col(:hl_time) { |b| b.second_hl_time if b.hl_time.present? }
    t.col(:hl_score) { |b| b.hl_score&.with_competition }
    t.col(:current_hl_time) { |b| b.second_current_hl_time if b.current_hl_time.present? }
    t.col(:hb_time) { |b| b.second_hb_time if b.hb_time.present? }
    t.col(:hb_score) { |b| b.hb_score&.with_competition }
    t.col(:current_hb_time) { |b| b.second_current_hb_time if b.current_hb_time.present? }
  end
end
