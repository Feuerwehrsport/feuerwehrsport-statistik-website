require 'fileutils'
require 'rmagick'

class Image::Positions < Struct.new(:person)
  def create_image
    position_counts = person.group_score_participations.la.group(:position).count
    sum = position_counts.values.sum
    drawings = Magick::Draw.new

    circle_centers.each_with_index do |center, position|
      position_count = position_counts[position + 1]
      if position_count.present?
        relation = position_count/sum.to_f
        size = 30 * relation + 8
        opacity = (2 * relation + 7)/10.0
        
        drawings.fill '#68F53F'
        drawings.opacity(opacity)
        drawings.circle(center.first, center.last, center.first + size, center.last + size)
      end
    end
    drawings.draw(canvas)
    canvas.write(file_path)
    canvas
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

  def canvas
    @canvas ||= begin
      canvas = Magick::Image.new(700, 155) { self.background_color = 'transparent' }
      template = Magick::Image.read("#{template_path}la_positions.png")[0]
      canvas.composite!(template, Magick::CenterGravity, Magick::OverCompositeOp)
      canvas
    end
  end

  def file_name
    "#{person.id}.png"
  end

  def file_path
    "#{store_path}#{file_name}"
  end

  def template_path
    "#{Rails.root}/app/assets/images/templates/"
  end

  def store_path
    path = "#{Rails.root}/public/generated/la_positions/"
    FileUtils.mkdir_p(path)
    path
  end
end