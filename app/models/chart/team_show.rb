module Chart
  class TeamShow < Base
    attr_accessor :team

    def gender_pie
      data = team.members.group(:gender).count.map do |key, count|
        {
          name: g(key),
          y: count,
          color: gender_color(key),
        }
      end
      basic_gender_pie(data)
    end
  end
end