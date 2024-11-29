# frozen_string_literal: true

class Discipline
  PARTICIPATION_COUNT = {
    gs: 6,
    fs: 4,
    la: 7,
  }.freeze
  SINGLE               = %i[hb hl].freeze
  WITHOUT_DOUBLE_EVENT = %i[hb hl gs fs la].freeze
  ALL                  = %i[hb hl zk gs fs la].freeze
  GROUP                = %i[gs fs la].freeze
  def self.group?(discipline)
    discipline.try(:to_sym).in? GROUP
  end

  def self.participation_count(discipline)
    PARTICIPATION_COUNT[discipline.try(:to_sym)]
  end

  def self.single?(discipline)
    !group?(discipline)
  end
end
