# Todo: Projekt auf aktuellen Stand bringen

Stand: 2026-11-04. Reihenfolge ≈ empfohlene Priorität.

## 1. Sofort / Kleinkram
- [x] 4 rote Specs repariert (`ApplicationMailer::DeliveryJob`)
- [x] Auf mise umgestellt (`.versions.conf` weg, Capistrano-featureset 1.2.0, `deploy.rb` liest mise.toml, spring beobachtet mise.toml)
- [ ] **Server `hanse-ff` auf mise vorbereiten** (mise unter /usr/bin, `mise install ruby@3.4.8`, `…mise.toml`, `…_env_vars` ohne `export`), danach `cap production version_manager:check`
- [ ] Bug in capistrano3_featureset 1.2.0: `Capistrano::Error` existiert nicht (version_manager.rake) → NameError statt sauberer Meldung
- [ ] Patch-/Minor-Updates einspielen (`bundle update --conservative`): puma, pg, solid_queue 1.7, mission_control-jobs 1.3,
      carrierwave, cancancan, bootsnap, rubocop-*, webmock, cuprite, haml-rails, generated_schema_validations 0.7 …
- [ ] `simplecov` 0.22 → 1.x (Major, Config prüfen)
- [x] `.gitlab-ci.yml` durch GitHub Actions ersetzt – [ ] erster Lauf auf GitHub noch zu prüfen
- [ ] `.byebug_history` löschen/ignorieren; `README.md` um Setup-Anleitung (mise, DB, Solid Queue starten) ergänzen
- [ ] `config/environments/production.rb`: veraltetes `config.cache_classes` entfernen (`enable_reloading = false` reicht),
      doppeltes `log_level` aufräumen
- [ ] TODO in `app/controllers/backend/backend_controller.rb:44` (leerer `begin`-Block) klären
- [ ] Commits pushen (lokal, Stand 2026-11-04 noch nicht gepusht)

- [x] Bugs aus [Bugs.md](Bugs.md) behoben (32 pending-Specs), Rechte für Import-Requests/Team-Prüfung umgesetzt
- [ ] Offene Punkte unten in [Bugs.md](Bugs.md) entscheiden
- [ ] Optional: `parallel_tests` einführen (DB-Name nutzt schon `TEST_ENV_NUMBER`)

## 2. Rails-Upgrade 7.2 → 8.x
- [ ] Gemfile: `rails ~> 8.1`; `bin/rails app:update` durchgehen, `load_defaults` schrittweise auf 8.0/8.1 heben
- [ ] Kompatibilität prüfen: `m3` (eigenes Engine-Gem!), `activerecord_views` 0.1.9, `draper`, `active_model_serializers`,
      `lazy_high_charts`, `will_paginate-bootstrap`, `cocoon`, `coffee-rails`, `sassc-rails`
- [ ] Sprockets bleibt in Rails 8 nutzbar, Standard ist aber Propshaft → siehe Abschnitt 4
- [ ] Optional: Solid Cache / Solid Cable, Kamal statt Capistrano prüfen (nur wenn gewünscht)

## 3. Veraltete / unmaintainte Gems ablösen
- [ ] `active_model_serializers` (quasi tot) → `jbuilder`, `alba` oder `blueprinter`; betrifft `app/serializers/` (26 Dateien) + API-Specs
- [ ] `lazy_high_charts` (unmaintained) → Highcharts direkt per JS ansteuern oder Chart.js; Highcharts 10.3.3 ist vendort (aktuell 12.x, Lizenz beachten)
- [ ] `coffee-rails` / CoffeeScript (39 Dateien) → modernes JavaScript (ES-Module)
- [ ] `sassc` / `sassc-rails` (libsass ist EOL) → `dartsass-rails` oder `dartsass-sprockets`
- [ ] `bootstrap-sass` 3.4.1 (EOL seit 2019) → Bootstrap 5 (große UI-Arbeit: Grid, Glyphicons, Modals, Panels …)
- [ ] `will_paginate-bootstrap` → `pagy` oder will_paginate mit eigenem Bootstrap-5-Renderer
- [ ] `cocoon` (unmaintained) → Stimulus-basierte Nested-Forms
- [ ] `jquery-rails`: m3 lädt `jquery2` + `jquery_ujs` → mindestens jQuery 3, `jquery_ujs` durch Turbo/`rails-ujs` ersetzen
- [ ] DataTables 1.10.9 (2015, vendort) → aktuelle DataTables 2.x oder eigene Lösung
- [x] `capistrano3_featureset` 1.0 → 1.2
- [ ] `spring` in Dev entfernen (in neuen Rails-Apps nicht mehr Standard, bootsnap reicht)
- [ ] `guard`/`guard-rspec` – noch genutzt? sonst entfernen

## 4. Frontend-Modernisierung (größter Brocken)
- [ ] Asset-Pipeline: Sprockets → Propshaft + `importmap-rails` (oder jsbundling/cssbundling)
- [ ] `turbo-rails` ist eingebunden – prüfen, ob Turbo tatsächlich aktiv genutzt wird; ggf. Stimulus ergänzen
- [ ] FSS-Window/Modal-Klassen (`app/assets/javascripts/classes/`) auf Stimulus-Controller migrieren
- [ ] Content Security Policy (`config/initializers/content_security_policy.rb` ist leer) aktivieren, sobald Inline-JS weg ist

## 5. m3-Engine abbauen
- [ ] Inventur, welche m3-Teile wirklich genutzt werden (Login, Default-Actions, Filter, ActionManager, Inputs, Layouts)
- [ ] Login evtl. auf Rails-8-Authentication-Generator (`has_secure_password`) umstellen
- [ ] Default-Actions/Filter schrittweise in die App (`app/controllers/concerns`) übernehmen, m3 am Ende entfernen
- [ ] Fontawesome-Version in m3 prüfen/aktualisieren

## 6. Qualität & Betrieb
- [ ] Ruby: 3.4.8 läuft; Umstieg auf Ruby 4.x prüfen (aktuelle Version vorher nachschlagen)
- [ ] `bundler-audit` / `brakeman` in CI aufnehmen
- [x] Coverage von 78,8 % auf 95,7 % erhöht (inkl. Specs für m3 und Serializer-Snapshots)
- [ ] Prüfen, ob `rails_log_parser` und `DebugJob` (alle 20 min) noch gebraucht werden
- [ ] Health-Check-Route (`/up`, Rails-Standard) ergänzen
