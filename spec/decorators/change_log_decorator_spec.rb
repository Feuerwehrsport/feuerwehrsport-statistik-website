# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChangeLogDecorator do
  let(:admin_user) { create(:admin_user, :admin) }

  def change_log(model_class:, action:, before: nil, after: nil, user: admin_user)
    content = {}
    content['before_hash'] = before if before
    content['after_hash'] = after if after
    ChangeLog.new(model_class:, action:, content:, admin_user: user).decorate
  end

  describe '#diff_hash and #related_id' do
    it 'returns differences' do
      decorated = change_log(model_class: 'Person', action: 'update-person',
                             before: { id: 5, first_name: 'Alfred', last_name: 'Meier' },
                             after: { id: 5, first_name: 'Alfredo', last_name: 'Meier' })
      expect(decorated.diff_hash).to eq(first_name: %w[Alfred Alfredo])
      expect(decorated.related_id).to eq 5
    end

    it 'handles missing before hash' do
      decorated = change_log(model_class: 'Person', action: 'create-person', after: { id: 7, first_name: 'A' })
      expect(decorated.diff_hash).to eq(id: [nil, 7], first_name: [nil, 'A'])
      expect(decorated.related_id).to eq 7
    end
  end

  describe '#translated_action' do
    it 'translates known actions' do
      expect(change_log(model_class: 'Person', action: 'create-person').translated_action)
        .to eq 'Wettkämpfer hinzufügen'
      expect(change_log(model_class: 'Person', action: 'update-person:name').translated_action)
        .to eq 'Names des Wettkämpfer anpassen'
      expect(change_log(model_class: 'Import::Scores', action: 'scores-import-scores').translated_action)
        .to eq 'Zeiten importieren'
    end

    it 'falls back to model class and action' do
      pending 'Bug: I18n-Option heißt default_ab statt default (change_log_decorator.rb:45)'
      expect(change_log(model_class: 'Foo', action: 'bar').translated_action).to eq 'Foo bar'
    end
  end

  describe '#user_name' do
    it 'returns admin user or api user' do
      expect(change_log(model_class: 'Person', action: 'x').user_name.to_s).to eq 'admin'
      expect(change_log(model_class: 'Person', action: 'x', user: nil).user_name).to eq 'API-Benutzer'
    end
  end

  describe '#translated_diff_hash' do
    let(:decorated) do
      change_log(model_class: 'Person', action: 'update-person',
                 before: { id: 5, first_name: 'Alfred', last_name: 'Meier' },
                 after: { id: 5, first_name: 'Alfredo', last_name: 'Mayer' })
    end

    it 'returns readable sentence' do
      expect(decorated.translated_diff_hash).to eq(
        'Objekt-ID: 5 Vorname: von »Alfred« zu »Alfredo« und Nachname: von »Meier« zu »Mayer«',
      )
    end

    it 'can be restricted to keys' do
      expect(decorated.translated_diff_hash(:last_name)).to eq 'Objekt-ID: 5 Nachname: von »Meier« zu »Mayer«'
    end
  end

  describe '#readable_content' do
    it 'links created people' do
      decorated = change_log(model_class: 'Person', action: 'create-person',
                             after: { id: 2953, first_name: 'Roland', last_name: 'Sommer', gender: 'male' })
      expect(decorated.readable_content).to eq '<a href="http://test.host/people/2953">Roland Sommer</a>'
    end

    it 'links destroyed teams with before model' do
      decorated = change_log(model_class: 'Team', action: 'destroy-team',
                             before: { id: 12, name: 'FF Warin', shortcut: 'Warin' })
      expect(decorated.readable_content).to eq '<a href="http://test.host/teams/12">FF Warin</a>'
    end

    it 'links to backend for models without public show page' do
      decorated = change_log(model_class: 'ScoreType', action: 'create-scoretype',
                             after: { id: 3, people: 10, run: 8, score: 6 })
      expect(decorated.readable_content).to eq '<a href="http://test.host/backend/score_types/3">10/8/6</a>'
    end

    it 'returns diff for unknown actions of linkable classes' do
      decorated = change_log(model_class: 'Person', action: 'something',
                             before: { id: 1, first_name: 'A' }, after: { id: 1, first_name: 'B' })
      expect(decorated.readable_content).to eq 'Objekt-ID: 1 Vorname: von »A« zu »B«'
    end

    it 'returns diff for not linkable classes' do
      decorated = change_log(model_class: 'TeamSpelling', action: 'create-teamspelling',
                             after: { id: 1, name: 'FF Warino' })
      expect(decorated.readable_content).to eq 'Objekt-ID: 1 ID: von »« zu »1« und Name: von »« zu »FF Warino«'
    end

    it 'describes person merge' do
      pending 'Bug: before_model/after_model sind nicht persistiert -> Links zeigen auf /people statt /people/:id'
      decorated = change_log(model_class: 'Person', action: 'merge',
                             before: { id: 1, first_name: 'Alfred', last_name: 'Meier' },
                             after: { id: 2, first_name: 'Alfredo', last_name: 'Mayer' })
      expect(decorated.readable_content).to eq(
        'Integriere <a href="/people/1">Alfred Meier</a> in <a href="/people/2">Alfredo Mayer</a>',
      )
    end

    it 'describes team merge' do
      pending 'Bug: before_model/after_model sind nicht persistiert -> Links zeigen auf /teams statt /teams/:id'
      decorated = change_log(model_class: 'Team', action: 'merge',
                             before: { id: 1, name: 'FF A' }, after: { id: 2, name: 'FF B' })
      expect(decorated.readable_content).to eq(
        'Integriere <a href="/teams/1">FF A</a> in <a href="/teams/2">FF B</a>',
      )
    end

    it 'describes links' do
      competition = create(:competition)
      after = { id: 1, label: 'Bericht', url: 'http://example.com/', linkable_type: 'Competition',
                linkable_id: competition.id }
      decorated = change_log(model_class: 'Link', action: 'create-link', after:)
      expect(decorated.readable_content).to eq(
        "Link <a href=\"http://example.com/\">Bericht</a> bei <a href=\"/competitions/#{competition.id}\">" \
        '01.05.2017 - Charlottenthal, D-Cup (Erster Lauf)</a>',
      )

      decorated = change_log(model_class: 'Link', action: 'destroy-link', before: after)
      expect(decorated.readable_content).to start_with('Link <a href="http://example.com/">Bericht</a> bei')

      decorated = change_log(model_class: 'Link', action: 'other', before: after, after: after.merge(label: 'X'))
      expect(decorated.readable_content).to eq 'Objekt-ID: 1 Label: von »Bericht« zu »X«'
    end

    it 'describes competition file uploads' do
      decorated = change_log(model_class: 'CompetitionFile', action: 'create-competitionfile',
                             after: { id: 1, competition_id: 5, file: { url: '/uploads/file.pdf' } })
      expect(decorated.readable_content).to eq '<a href="http://test.host/competitions/5">/uploads/file.pdf</a>'
    end

    it 'describes score imports' do
      competition = create(:competition)
      decorated = change_log(model_class: 'Import::Scores', action: 'scores-import-scores',
                             after: { competition_id: competition.id })
      expect(decorated.readable_content).to eq(
        "Füge Zeiten zu Wettkampf <a href=\"/competitions/#{competition.id}\">" \
        '01.05.2017 - Charlottenthal, D-Cup (Erster Lauf)</a> hinzu',
      )
    end

    it 'describes score imports without competition' do
      decorated = change_log(model_class: 'Import::Scores', action: 'scores-import-scores',
                             after: { competition_id: 999_999 })
      expect(decorated.readable_content).to start_with('Objekt-ID:')
    end

    it 'shows only done_at for change requests' do
      decorated = change_log(model_class: 'ChangeRequest', action: 'update-changerequest',
                             before: { id: 3, done_at: nil, content: 'a' },
                             after: { id: 3, done_at: '2020-01-01', content: 'b' })
      expect(decorated.readable_content).to eq 'Objekt-ID: 3 Done at: von »« zu »2020-01-01«'
    end

    it 'returns error message for not routable models' do
      decorated = change_log(model_class: 'Series::TeamParticipation', action: 'create-series-teamparticipation',
                             after: { id: 1 })
      expect(decorated.readable_content).to start_with('NameError: ')
      expect(decorated.readable_content).to end_with('Objekt-ID: 1 ID: von »« zu »1«')
    end

    it 'returns error message for not existing model classes' do
      pending 'Bug: rescue-Zweig in readable_content ruft translated_diff_hash auf, das erneut NameError wirft ' \
              '(LINKABLE_CLASSES enthält nicht existierendes Series::Participation)'
      decorated = change_log(model_class: 'Series::Participation', action: 'create-series-participation',
                             after: { id: 1 })
      expect(decorated.readable_content).to start_with('NameError: ')
    end
  end
end
