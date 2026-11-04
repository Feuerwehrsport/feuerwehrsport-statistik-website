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
- Frontend (Sprockets!): CoffeeScript, Sass (`sassc`), `bootstrap-sass` 3.4.1, jQuery (über m3: `jquery2` + `jquery_ujs`),
  DataTables 1.10.9 (vendort in `app/assets/javascripts/dataTables`), Highcharts 10.3.3 (vendort in
  `vendor/assets/javascripts/highcharts`; Optionen über eigene Klasse `Chart::HighChart`, Ausgabe in `Chart::Base#high_chart`)
- Pagination: `will_paginate` mit eigenem `BootstrapPaginationRenderer` (`m3/app/renderers/`)
- Deployment: Capistrano über `capistrano3_featureset` 1.2.0 (mise, systemd, Puma, Solid Queue), Server `hanse-ff`, `/srv/feuerwehrsport-statistik`
  - `config/deploy.rb` liest `:ruby_version` aus `mise.toml`
  - Server erwartet: `/usr/bin/mise`, Ruby via mise, `/home/feuerwehrsport-statistik/feuerwehrsport-statistik.mise.toml`,
    Env-Datei `/home/feuerwehrsport-statistik/feuerwehrsport-statistik_env_vars` (ohne `export`)
  - Stand 2026-11-04: auf `hanse-ff` ist **noch kein Ruby via mise installiert** → `cap production version_manager:check` schlägt fehl
- Mails: SMTP `mail.lichtbit.com`; `ApplicationMailer::DeliveryJob` mit Retry
- Sicherheit: `bin/bundler-audit` (in CI), `bin/brakeman` (19 Warnungen, noch nicht gesichtet)
- Achtung Rails 8: `has_secure_password reset_token: false` in `M3::Login::Base`, weil m3 eine eigene Spalte `password_reset_token` hat

## m3 (lokales Engine-Gem unter `m3/`)
Altes Lichtbit/mgvmedia-Framework (Autor Sebastian Gaul), per `path:` eingebunden. Liefert:
Login/Sessions/Passwort-Reset (`M3::Login::*`), Default-CRUD-Actions (`controllers/concerns/default_actions`),
Filter-/ActionManager-Decorators, Inputs, Uploader, Layouts, Fontawesome + JS-Basis (jQuery 2, jquery_ujs, autosize).
→ Große, eigene Altlast; viele Teile der App hängen davon ab.

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
  - Neue Spec-Ordner: `spec/decorators`, `spec/serializers` (JSON-Snapshots, Absicherung für AMS-Ablösung), `spec/m3`, `spec/helpers/{calc,chart,backend}`, `spec/validators`, `spec/uploaders`
  - Feature-Specs (Cuprite) nicht parallel in zwei Prozessen laufen lassen (Port/Browser-Konflikt)
- Test-DB-Name: `feuerwehrsport-statistik-test<TEST_ENV_NUMBER>` → parallele Läufe mit eigener DB möglich
- RuboCop (`.rubocop.yml`): 609 Dateien, keine Offenses
- CI: GitHub Actions `.github/workflows/ci.yml` (mise-action, Postgres-Service, rubocop + rspec); alte `.gitlab-ci.yml` entfernt

## Sonstiges
- `.byebug_history` liegt im Repo-Verzeichnis, Gem `byebug` wird aber nicht mehr genutzt (`debug` statt dessen)
- `coverage/`, `tmp/.capistrano-rsync-deploy` liegen lokal herum
- Lokale DB: Postgres auf localhost, User/PW `feuerwehrsport-statistik`
- Auskommentiert im Gemfile: `firesport`, `firesport-series` (wurden offenbar in die App integriert, vgl. `app/models/firesport.rb`)
- Siehe [Todo.md](Todo.md) für Modernisierungsaufgaben
