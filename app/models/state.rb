# frozen_string_literal: true

class State
  ALL = {
    'BW' => 'Baden-Württemberg',
    # 'BY' => 'Bayern',
    'BE' => 'Berlin',
    'BB' => 'Brandenburg',
    'HB' => 'Bremen',
    'HH' => 'Hamburg',
    'HE' => 'Hessen',
    'MV' => 'Mecklenburg-Vorpommern',
    'NI' => 'Niedersachsen',
    'NW' => 'Nordrhein-Westfalen',
    'RP' => 'Rheinland-Pfalz',
    'SL' => 'Saarland',
    'SN' => 'Sachsen',
    'ST' => 'Sachsen-Anhalt',
    'SH' => 'Schleswig-Holstein',
    'TH' => 'Thüringen',

    'CZ' => 'Tschechien',
    'DE' => 'Deutschland',
    'AT' => 'Österreich',
    'PL' => 'Polen',
    'BY' => 'Weißrussland',
    'HU' => 'Ungarn',
  }.freeze

  FEDERAL = [
    'BW',
    # 'BY',
    'BE',
    'BB',
    'HB',
    'HH',
    'HE',
    'MV',
    'NI',
    'NW',
    'RP',
    'SL',
    'SN',
    'ST',
    'SH',
    'TH',
  ].freeze

  INTERNATIONAL = %w[
    CZ
    DE
    AT
    PL
    BY
    HU
  ].freeze

  # state key of a place found by nominatim (address.country_code, address.state); nil when unknown
  def self.from_place(country_code, state_name)
    country = country_code.to_s.upcase
    return country if INTERNATIONAL.include?(country) && country != 'DE'
    return if country != 'DE'

    FEDERAL.find { |key| ALL[key] == state_name } || 'DE'
  end
end
