# Todo: Projekt auf aktuellen Stand bringen

Stand: 2026-11-04. Reihenfolge ≈ empfohlene Priorität.

## 1. Vor dem nächsten Deploy
- [ ] **Server `hanse-ff` auf mise vorbereiten**: mise unter /usr/bin, `mise install ruby@4.0.9`,
      `/home/feuerwehrsport-statistik/feuerwehrsport-statistik.mise.toml`, `…_env_vars` ohne `export`,
      danach `cap production version_manager:check`
- [ ] Commits pushen und ersten GitHub-Actions-Lauf prüfen (rubocop, bundler-audit, rspec)
- [ ] Nach Deploy kontrollieren: Login/Passwort-Reset (has_secure_password `reset_token: false`), `/admin-jobs`, PDF-/XLSX-Exporte,
      Diagramme (eigene `Chart::HighChart`-Klasse), Pagination im Backend (eigener Renderer), `/up`
- [ ] Bug in capistrano3_featureset 1.2.0: `Capistrano::Error` existiert nicht (version_manager.rake) → NameError statt sauberer Meldung

## 2. Erledigt am 2026-11-04
- [x] mise statt RVM, GitHub Actions statt GitLab CI
- [x] Testoffensive (Coverage 78,8 % → 96,9 %), 32 Bugs behoben, Rechte für Import-Requests/Team-Prüfung
- [x] Rails 7.2 → **8.1.4.1** (Sicherheitsrelease), `load_defaults 8.1`, veraltete Initializer und `cache_classes` entfernt, Health-Check `/up`
- [x] Ruby 3.4.8 → **4.0.9**, Bundler 4.0.20, simplecov 1.x
- [x] Gems ersetzt: active_model_serializers → `ApplicationSerializer`; lazy_high_charts → `Chart::HighChart`;
      will_paginate-bootstrap → `BootstrapPaginationRenderer` (m3); prawn-rails → prawn + prawn-table;
      timecop → `ActiveSupport::Testing::TimeHelpers`; database_cleaner → transaktionale Fixtures; vcr → webmock direkt
- [x] Gems entfernt (ungenutzt): matrix, responders, cocoon, spring, rqrcode, redcarpet, acts_as_list, turbo-rails
- [x] brakeman + bundler-audit ergänzt (bundler-audit in CI)
- [x] Regel für Updates: nur Versionen, die ein paar Tage alt sind, oder Sicherheitsupdates.
      Stand: nokogiri 1.19.5, addressable 2.9.1, haml 7.5.1, solid_queue 1.7.0, net-ssh 8.0.4, net-scp 4.2.0 bewusst
      nicht auf der allerneuesten Version – beim nächsten `bundle update` anheben

## 3. Kleinkram
- [ ] Brakeman-Warnungen sichten (19, v. a. SQL-Interpolation interner Werte, `permit!`), dann `config/brakeman.ignore` + CI
- [ ] Offene Punkte unten in [Bugs.md](Bugs.md) entscheiden
- [ ] `.byebug_history` löschen; `README.md` um Setup-Anleitung (mise, DB, Solid Queue) ergänzen
- [ ] TODO in `app/controllers/backend/backend_controller.rb:44` (leerer `begin`-Block) klären
- [ ] Prüfen, ob `rails_log_parser` und `DebugJob` (alle 20 min) noch gebraucht werden
- [ ] `guard`/`guard-rspec` – noch genutzt? sonst entfernen
- [ ] Optional: `parallel_tests` (DB-Name nutzt schon `TEST_ENV_NUMBER`)

## 4. Frontend-Modernisierung (größter Brocken)
- [ ] Asset-Pipeline: Sprockets → Propshaft + `importmap-rails` (oder jsbundling/cssbundling)
- [ ] `coffee-rails` / CoffeeScript (39 Dateien) → modernes JavaScript
- [ ] `sassc` / `sassc-rails` (libsass ist EOL) → `dartsass-rails` oder `dartsass-sprockets`
- [ ] `bootstrap-sass` 3.4.1 (EOL) → Bootstrap 5 (Grid, Glyphicons, Modals, Panels …; Pagination-Renderer anpassen)
- [ ] `jquery-rails`: m3 lädt `jquery2` + `jquery_ujs` → mindestens jQuery 3
- [ ] DataTables 1.10.9 (2015, vendort) → DataTables 2.x; Highcharts 10.3.3 (vendort) → aktuell (Lizenz beachten)
- [ ] FSS-Window/Modal-Klassen (`app/assets/javascripts/classes/`) ggf. auf Stimulus
- [ ] Content Security Policy aktivieren, sobald Inline-JS (u. a. Chart-Skripte) weg ist

## 5. m3-Engine abbauen
- [ ] Inventur, welche m3-Teile wirklich genutzt werden (Login, Default-Actions, Filter, ActionManager, Inputs, Layouts)
- [ ] Login evtl. auf Rails-8-Authentication-Generator umstellen
- [ ] Default-Actions/Filter schrittweise in die App übernehmen, m3 am Ende entfernen
- [ ] Fontawesome-Version in m3 prüfen/aktualisieren

## 6. Optional
- [ ] Solid Cache / Solid Cable, Kamal statt Capistrano prüfen
