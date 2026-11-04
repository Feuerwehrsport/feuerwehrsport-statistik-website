# Bugs

Stand: 2026-11-04. Die Testoffensive hat 32 Bugs als `pending`-Specs dokumentiert; **alle sind behoben**
(Commits `7ed4959`..`7eae0f6`). Vorgehen für neue Funde: Spec mit erwartetem korrekten Verhalten + `pending 'Bug: …'`.

## Behoben (Kurzüberblick)
- Rechte: normale Nutzer sehen nur eigene Import-Requests; Teams als geprüft markieren (`UncheckedTeam`) nur ab sub_admin
- Mails: Login-Mail-Betreffs (Locale-Pfad), ImportRequestMailer ohne Empfänger (NullMail), `AdminUser.admins` inkl. `sub_admin_with_series`
- Serien: Rang 0 bekam Punkte des letzten Platzes, fehlende Round-Keys, `class_name` an RoundImport, Controller ignorierte `save`,
  Einträge ohne Rang ans Ende sortiert (stabil), `honor_rank` wird jetzt genutzt, lesbarer Fehler bei falscher Disziplinzahl
- Import: `Team.normalize_name` (römische Nummer + Lauf, Lauf D), Gruppendisziplin sucht Personen nur bei Namensspalten,
  `ImportRequest#import_data_series_rounds` extrahiert Round-IDs korrekt
- m3: Zugriffsverweigerung in Engines (`/admin-jobs`) nutzt `main_app`; Passwort-Reset-Fehlerübernahme (Rails ≥ 6.1)
- Alte PHP-Pfade best-performance/best-scores waren vertauscht
- Charts: Monats-/Wochentagsnamen (tote `day_names`/`month_names` aus `de.yml` entfernt), Gender-Farben bei String-Keys
- ChangeLog-Decorator: I18n-Default, Merge-Links mit ID, kein NameError bei unbekannten Klassen
- CompetitionDecorator `hl_male`, UserSerializer-Typ bei Decorators, `/bla/badges.xlsx` war leer
- `Score#hb_bla_badges` Fremdschlüssel, Uploader `extension_allowlist` (CarrierWave 3), MergeAction-Fehlermeldung,
  `Caching::Cache.disable` mit `ensure`, Memoisierung in `Years::Inprovement`, Hostname ohne Zeilenumbruch im DebugJob
- Factory `single_discipline :hb_female` setzt `default_for_female`
- Toter Code entfernt: `PdfSupport`, `Series::AssessmentSerializer`, `_aggregate_type_*`/`_endless_table`-Partials,
  `EntitySupport#storage_support_get`; `Series::TeamAssessmentDecorator` repariert (wird über die API genutzt)

## Noch offen / zu entscheiden
- Backend-Indexe öffentlich lesbarer Ressourcen (z. B. `/backend/places`) sind ohne Login erreichbar – gewollt?
- `sub_admin_with_series` darf `Series::Kind` nur lesen – gewollt?
- `Score.best_of*` filtern weder ungültige Zeiten noch Finals/außer Wertung (Ist-Verhalten im Spec festgehalten)
- `app/models/import/scores.rb:61`: neue Personen bekommen fest `nation_id: 1`
- Kleinkram toter Code: `Bla::BadgeDecorator#second_time`, else-Zweig in `Api::SuggestionsController#people`,
  `Backend::ResourcesHelper#breadcrum` (nur im Spec genutzt)
- capistrano3_featureset 1.2.0: `Capistrano::Error` existiert nicht (version_manager.rake) → NameError statt sauberer Meldung
