# Todo

Stand: 2026-11-04. Reihenfolge ≈ empfohlene Priorität. Erledigtes wird entfernt (Historie: git log).

## 1. Kleinkram
- [ ] Beim nächsten `bundle update` anheben (waren beim Update zu neu, keine Sicherheitsupdates):
      haml (7.5.1), solid_queue (1.7.0), net-ssh (8.0.4), net-scp (4.2.0), nokogiri (1.19.5), addressable (2.9.1)
- [ ] Brakeman-Warnungen sichten (19, v. a. SQL-Interpolation interner Werte, `permit!`), dann `config/brakeman.ignore` + CI
- [ ] Offene Punkte unten in [Bugs.md](Bugs.md) entscheiden
- [ ] Bug in capistrano3_featureset 1.2.0 (eigenes Gem): `Capistrano::Error` existiert nicht (version_manager.rake) →
      NameError statt sauberer Meldung
- [ ] TODO in `app/controllers/backend/backend_controller.rb:44` (leerer `begin`-Block) klären
- [ ] Optional: `parallel_tests` (DB-Name nutzt schon `TEST_ENV_NUMBER`)

## 2. Frontend-Modernisierung (größter Brocken)
- [ ] Asset-Pipeline: Sprockets → Propshaft + `importmap-rails` (oder jsbundling/cssbundling)
- [ ] `coffee-rails` / CoffeeScript (39 Dateien) → modernes JavaScript
- [ ] `sassc` / `sassc-rails` (libsass ist EOL) → `dartsass-rails` oder `dartsass-sprockets`
- [ ] `bootstrap-sass` 3.4.1 (EOL) → Bootstrap 5 (Grid, Glyphicons, Modals, Panels …; Pagination-Renderer anpassen)
- [ ] `jquery-rails`: `jquery2` + `jquery_ujs` → mindestens jQuery 3
- [ ] DataTables 1.10.9 (2015, vendort) → DataTables 2.x; Highcharts 10.3.3 (vendort) → aktuell (Lizenz beachten)
- [ ] JS-Global `M3` und Sass-Ordner `m3/` (Reste der früheren m3-Engine) umbenennen/auflösen
- [ ] Fontawesome-Version prüfen/aktualisieren
- [ ] FSS-Window/Modal-Klassen (`app/assets/javascripts/classes/`) ggf. auf Stimulus
- [ ] Content Security Policy aktivieren, sobald Inline-JS (u. a. Chart-Skripte) weg ist

## 3. Optional
- [ ] Solid Cache / Solid Cable, Kamal statt Capistrano prüfen
