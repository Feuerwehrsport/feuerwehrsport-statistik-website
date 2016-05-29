module Import
  class Line
    attr_reader :cols, :check

    def initialize(check, cols)
      @check = check
      @cols = cols

      if cols.count < check.headline_columns.count
        out.valid = false
      else
        check.headline_columns.each_with_index do |headline, index|
          col = cols[index].strip
          case headline
          when 'last_name'
            out.last_name = normalize_name(col)
          when 'first_name'
            out.first_name = normalize_name(col)
          when 'time'
            time = normalize_time(col)
            out.times.push(time) if time
          when 'run'
            run = col.upcase
            out.run = run if run.in?(["A", "B", "C", "D"])
          when 'team'
            team_name = normalize_name(col)
            out.original_team = team_name
            run = normalize_team_run(team_name)
            out.run = run if run
            out.team_number = normalize_team_number(team_name)

            team = Team.find_by_id(team_name)
            if team
              out.team_ids = [team.id]
              out.team_names = [team.shortcut]
            else
              teams = find_teams(team_name)
              if teams.count > 0
                out.team_ids = teams.map(&:id)
                out.team_names = teams.map(&:shortcut)
              else
                check.add_missing_team(team_name)
                out.correct = false
              end
            end
          end
        end
        out.people = find_people unless Discipline.group?(check)
      end
    end

    def out
      @out ||= OpenStruct.new(
        valid: true,
        last_name: "",
        first_name: "",
        times: [],
        team_names: [],
        original_team: "",
        run: "",
        team_number: 1,
      )
    end

    private

    def normalize_name(name)
      name.gsub(/,$/, "").gsub(/^,/, "")
    end

    def normalize_team_number(team_name, default=1)
      team_name = team_name.gsub(/\s[ABCD]$/, '').strip
      return 1 if team_name =~ /\s[1I]$/
      return 2 if team_name =~ /\s(2|(II))$/
      return 3 if team_name =~ /\s(3|(III))$/
      return 4 if team_name =~ /\s(4|(IV))$/
      return 0 if team_name =~ /\sE$/
      return default
    end

    def normalize_team_run(team_name, default='A')
      return 'A' if team_name =~ /\sA$/
      return 'B' if team_name =~ /\sB$/
      return 'C' if team_name =~ /\sC$/
      return 'D' if team_name =~ /\sD$/
      return default
    end

    def find_teams(team_name)
      team_name = team_name.gsub(/^FF /i, '')
      team_name = team_name.gsub(/^Feuerwehr /i, '')
      team_name = team_name.gsub(/^Team /i, '')
      team_name = team_name.gsub(/ I$/, '')
      team_name = team_name.gsub(/ II$/, '')
      team_name = team_name.gsub(/ III$/, '')
      team_name = team_name.gsub(/ IV$/, '')
      2.times do
        team_name = team_name.gsub(/ E$/, '')
        team_name = team_name.gsub(/ A$/, '')
        team_name = team_name.gsub(/ B$/, '')
        team_name = team_name.gsub(/ C$/, '')
        team_name = team_name.gsub(/ 1$/, '')
        team_name = team_name.gsub(/ 2$/, '')
        team_name = team_name.gsub(/ 3$/, '')
        team_name = team_name.gsub(/ 4$/, '')
      end
      team_ids = Team.search(team_name).pluck(:id)
      team_ids += TeamSpelling.search(team_name).pluck(:team_id)
      Team.where(id: team_ids)
    end

    def normalize_time(time)
      time = time.downcase
      return false if time == 'n'
      return TimeInvalid::INVALID if time.in?(['d', 'o.w.', 'o. w.'])
      
      time = time.gsub(/^(.+)\s*s\s*\.?$/, "\\1").strip
      time = time.gsub(/^(.+)\s*sekunden$/, "\\1").strip

      return false unless time =~ /^[\d,:;.]+$/

      if match = time.match(/^(\d+):(\d{2})[:,](\d{2})$/)
        seconds = match[1].to_i * 60 + match[2].to_i
        time = "#{seconds}:#{match[3]}"
      end

      seconds = 0
      millis = "0"
      if time.include?(',') || time.include?('.')
        time = time.gsub(',', '.')
        time = time.gsub(':', '')
        time = time.gsub(';', '')
        seconds, millis = time.split(".")
      elsif time.include?(';') || time.include?(':')
        time = time.gsub(':', '.')
        time = time.gsub(';', '.')
        seconds, millis = time.split(".")
      elsif time.to_i.to_s == time.to_s
        seconds = time
      end
      seconds = seconds.to_i
      millis = millis.first(2)
      if millis.match(/\A\d\z/)
        millis = millis.to_i * 10
      else
        millis = millis.to_i
      end
      time = seconds * 100 + millis if seconds > 0

      if time.to_i.to_s == time.to_s
        return TimeInvalid::INVALID if time.to_i < 500 || time.to_i > 99800
        return time.to_i
      end
      return false
    end

    def find_people
      person_ids = Person.gender(check.gender).search_exactly(out.last_name, out.first_name).pluck(:id)
      person_ids += PersonSpelling.gender(check.gender).search_exactly(out.last_name, out.first_name).pluck(:person_id)
      Person.where(id: person_ids).pluck(:id, :last_name, :first_name)
    end
  end
end