# frozen_string_literal: true

class Series::TeamParticipationDecorator < AppDecorator
  def second_time_with_points(html: true)
    inner = "#{second_time} (#{points_with_correction})"
    if object.points_correction_hint.nil? || !html
      inner
    else
      h.content_tag(:abbr, inner, title: object.points_correction_hint)
    end
  end

  def second_time
    Firesport::Time.second_time(time)
  end

  def points_with_correction
    if object.points_correction.nil?
      object.points
    else
      "#{object.points}#{'+' unless object.points_correction < 0}#{object.points_correction}"
    end
  end
end
