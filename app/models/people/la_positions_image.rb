# frozen_string_literal: true

class People::LaPositionsImage
  include M3::FormObject
  belongs_to :person

  def create_image
    position_counts = person.group_score_participations.la.group(:position).count
    sum = position_counts.values.sum

    image = MiniMagick::Image.open("#{template_path}/la_positions.png")
    image.combine_options do |convert|
      circle_centers.each_with_index do |center, position|
        position_count = position_counts[position + 1]
        next if position_count.blank?

        relation = position_count / sum.to_f
        size = (30 * relation) + 8
        opacity = ((2 * relation) + 7) / 10.0

        convert.draw(
          'fill #68F53F ' \
          "fill-opacity #{opacity} " \
          "circle #{center.first},#{center.last} #{center.first + size},#{center.last + size}",
        )
      end
    end
    image.write(file_path)
    image
  end

  def circle_centers
    [
      [77, 68],
      [77, 45],
      [77, 25],
      [295, 82],
      [630, 35],
      [459, 77],
      [630, 119],
    ]
  end

  def file_name
    "#{person.id}.png"
  end

  def file_path
    "#{store_path}#{file_name}"
  end

  def template_path
    Rails.root.join('app/assets/images/templates')
  end

  def store_path
    path = Rails.public_path.join('generated/la_positions')
    FileUtils.mkdir_p(path)
    path
  end
end
