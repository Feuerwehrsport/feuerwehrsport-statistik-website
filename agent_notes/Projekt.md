# Projektnotizen: feuerwehrsport-statistik

Stand der Analyse: 2026-11-04 (aktualisiert nach Rails-8.1-/Ruby-4-Update)

## Was ist das?
Rails-Webseite für https://feuerwehrsport-statistik.de – Ergebnisse, Personen, Teams,
Wettkämpfe und Serien (Cups) im Feuerwehrsport. Seit 2015 in Entwicklung (anfangs PHP,
seit Januar 2016 Rails). Liefert außerdem eine API für den Wettkampf-Manager.
Repo: `git@github.com:Feuerwehrsport/feuerwehrsport-statistik-website.git`

## Technischer Stack
- Ruby 4.0.9 + Bundler 4, Versionsverwaltung ausschließlich über mise (`mise.toml`)
- Rails 8.1.4.1 (`config.load_defaults 8.1`), Gemfile: `rails ~> 8.1.4`; Health-Check unter `/up`
- PostgreSQL (`pg`), Puma 8
- Hintergrundjobs: Solid Queue (DB-basiert) + Mission Control (`/admin-jobs`, Basis `AdminController`)
  - Recurring (`config/recurring.yml`): Aufräumen fertiger Jobs, `DebugJob`, nächtlicher `DumpDatabaseJob`
- Views: HAML (`haml-rails`), Formulare: `simple_form`, Decorators: `draper`
- Rechte: `cancancan` (`app/models/ability.rb`; Rollen user < sub_admin < sub_admin_with_series < admin; `UncheckedTeam` erst ab sub_admin, Import-Requests für user nur eigene)
- Uploads: `carrierwave` + `mini_magick`; `image_optim`
- Exporte: `prawn` + `prawn-table` (PDF, `PrawnSupport`), `caxlsx_rails` (XLSX), JSON-API über eigene `ApplicationSerializer`-Basisklasse
  (`app/serializers/`, Lookup `ApplicationSerializer.for(klass)`, nur `attributes` + Methoden)
- DB-Views im Code: `activerecord_views` (`*.sql` neben Models, z. B. `team_member.sql`, `year.sql`)
- Validierung aus Schema: `generated_schema_validations` (hat auch Capistrano-Task)
- Frontend (Sprockets!): CoffeeScript, Sass (`sassc`), `bootstrap-sass` 3.4.1, jQuery (`jquery2` + `jquery_ujs` in `app/assets/javascripts/m3/application.js.coffee`),
  DataTables 1.10.9 (vendort in `app/assets/javascripts/dataTables`), Highcharts 10.3.3 (vendort in
  `vendor/assets/javascripts/highcharts`; Optionen über eigene Klasse `Chart::HighChart`, Ausgabe in `Chart::Base#high_chart`)
- Pagination: `will_paginate` mit eigenem `BootstrapPaginationRenderer` (`app/renderers/`)
- Deployment: Capistrano über `capistrano3_featureset` 1.2.0 (mise, systemd, Puma, Solid Queue), Server `hanse-ff`, `/srv/feuerwehrsport-statistik`
  - `config/deploy.rb` liest `:ruby_version` aus `mise.toml`
  - Server erwartet: `/usr/bin/mise`, Ruby via mise, `/home/feuerwehrsport-statistik/feuerwehrsport-statistik.mise.toml`,
    Env-Datei `/home/feuerwehrsport-statistik/feuerwehrsport-statistik_env_vars` (ohne `export`)
  - Seit 2026-11-04 läuft `hanse-ff` mit mise und Ruby 4.0.9
- Mails: SMTP `mail.lichtbit.com`; `ApplicationMailer::DeliveryJob` mit Retry
- Sicherheit: `bin/bundler-audit` (in CI), `bin/brakeman` (19 Warnungen, noch nicht gesichtet)

## Ehemalige m3-Engine (am 2026-11-04 aufgelöst)
Früher lokales Engine-Gem `m3/` (Lichtbit/mgvmedia). Jetzt vollständig Teil der App:
- **CRUD-Framework** (in `ApplicationController` eingebunden): `controllers/concerns/default_actions*`, `default_resources`,
  `default_parent_resources`, `action_manager`, `index_structures`/`form_structures`/`filter_structures`,
  `controller_translation` (`t3`), Strukturen unter `Ui::Index`, `Ui::Filter`, `Ui::Form` (+ Decorators unter `app/decorators/ui/`),
  View-Helfer `ResourceHelper` (`resource_form`, `ca_title` …), generische Views in `app/views/application/`
- **Login** mit Rails-Bordmitteln: Model `Login` (Tabelle `logins`), Concern `Authentication` (`current_login`,
  `start_session` mit `reset_session`, Session-Key `:login_id`), Controller `Sessions`, `Verifications`, `PasswordResets`,
  `ExpiredLogins`, `ChangedEmailAddresses`. Tokens per `generates_token_for`/`has_secure_password reset_token: { expires_in: 1.day }`,
  `rate_limit` auf Anmeldung (10/3 min) und Passwort-Reset (5/10 min). `AdminUser belongs_to :login`.
- Sonstiges: `FormObject`/`FormObjectAssociations` (Concerns), `ApplicationUploader`, Inputs in `app/inputs/`, `BootstrapPaginationRenderer`
- Asset-Verwaltung für CKEditor-Bilder (`m3_assets`) am 2026-11-04 entfernt (letzter Upload 2018, keine Verweise in Inhalten)
- Noch übrig (Frontend): JS-Global `M3` (`M3.ready`, `app/assets/javascripts/m3/`), Sass unter `app/assets/stylesheets/m3/`

## Code-Struktur (app/)
- `models/`: Kernmodelle (Person, Team, Competition, Score, GroupScore, Event, Place, …), `series/` (Cups, Rounds,
  Assessments, Participations), `import/` (Score-Import), `caching/`, `calculation/`, `bla/` (Badges), `repairs/`, `ui/`
- `controllers/`: öffentliche Seiten, `backend/` (Admin), `api/` (AJAX/JSON, auch Wettkampf-Manager), `series/`, `years/`, `bla/`
- `helpers/chart/`, `helpers/calc/`: Diagramme & Berechnungen
- `jobs/`: `DebugJob`, `DumpDatabaseJob` (+ `etc/store_dump.sh`)
- Kein `lib/`-Verzeichnis

## Tests & Qualität
- RSpec (request specs, features mit Cuprite/Capybara, WebMock, FactoryBot), SimpleCov 1.x (`.simplecov` nur Konfiguration), Guard
- Transaktionale Fixtures (kein DatabaseCleaner), Zeitreisen mit `travel_to` (globales `travel_back` in `rails_helper`)
- Lokaler Lauf (2026-11-04, vor neuen Tests): 384 Beispiele, 0 Fehlschläge (4 Mail-Job-Specs auf `ApplicationMailer::DeliveryJob` korrigiert), Coverage 78,8 %
- Nach Testoffensive, Bugfixes und Rails-8.1-Update (2026-11-04): **1057 Beispiele, 0 Fehlschläge, 1 skip**, Coverage 96,9 % (vorher 78,8 %),
  Laufzeit ~4 min; auch mit `CI=1` (eager_load) grün. Bugs: siehe [Bugs.md](Bugs.md)
  - Neue Spec-Ordner: `spec/decorators`, `spec/serializers` (JSON-Snapshots, Absicherung für AMS-Ablösung), `spec/renderers`, `spec/helpers/{calc,chart,backend}`, `spec/validators`, `spec/uploaders`
  - Feature-Specs (Cuprite) nicht parallel in zwei Prozessen laufen lassen (Port/Browser-Konflikt)
- Test-DB-Name: `feuerwehrsport-statistik-test<TEST_ENV_NUMBER>` → parallele Läufe mit eigener DB möglich
- RuboCop (`.rubocop.yml`): 609 Dateien, keine Offenses
- CI: GitHub Actions `.github/workflows/ci.yml` (mise-action, Postgres-Service, rubocop + bundler-audit + rspec) und täglich
  `.github/workflows/security.yml` (bundler-audit + ruby_audit); beide laufen grün

## Sonstiges
- `.byebug_history` liegt im Repo-Verzeichnis, Gem `byebug` wird aber nicht mehr genutzt (`debug` statt dessen)
- `coverage/`, `tmp/.capistrano-rsync-deploy` liegen lokal herum
- Lokale DB: Postgres auf localhost, User/PW `feuerwehrsport-statistik`
- Auskommentiert im Gemfile: `firesport`, `firesport-series` (wurden offenbar in die App integriert, vgl. `app/models/firesport.rb`)
- Siehe [Todo.md](Todo.md) für Modernisierungsaufgaben
