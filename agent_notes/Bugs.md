# Gefundene Bugs (Testoffensive 2026-11-04)

Alle Punkte unter „Mit pending-Test“ haben einen Spec, der das **korrekte** Verhalten erwartet und mit
`pending 'Bug: …'` markiert ist. Wird der Bug behoben, schlägt der Spec fehl („Expected pending … to fail“)
→ dann einfach das `pending` entfernen. Liste aller offenen: `grep -rn "pending 'Bug" spec`.

## Bereits behoben
- `app/models/federal_state.rb`: fehlendes `schema_validations` → App bootete mit `CI=1` (eager_load) gar nicht.
- `m3/app/controllers/m3/image_assets_controller.rb`: Spalte `image_preview` war sortierbar → Fehler in `m3_index_request_spec` unter `CI=1`.

## Mit pending-Test – kritisch / sichtbar
- `m3/app/controllers/m3/application_controller.rb:34,38`: bei Ablehnung in `/admin-jobs` werden `root_path`/`login_url`
  gegen die Engine-Routen aufgelöst → Gast: 500 (UrlGenerationError), user/sub_admin: Redirect-Schleife. (Zugriffsschutz selbst ok.)
- `m3/app/models/m3/login/password_reset.rb:12`: `errors.each { |attribute, message| }` (seit Rails 6.1 kaputt) → 500 bei falscher Passwortbestätigung.
- `app/models/score.rb:22`: `has_many :hb_bla_badges` mit `foreign_key: :hl_score_id` statt `:hb_score_id` → Badges nicht gefunden, Löschen eines HB-Scores mit Badge scheitert am FK.
- `app/controllers/bla/badges_controller.rb:6`: `export_index` ohne Formate → `/bla/badges.xlsx` enthält nur leere Zeilen.
- `app/models/admin_user.rb:15`: `AdminUser.admins` ohne `sub_admin_with_series` → keine Mails, nicht als `edit_user` wählbar.
- `app/mailers/import_request_mailer.rb:5-9`: kein NullMail ohne Empfänger → `ArgumentError` (wird nicht retried), wenn der einzige Admin selbst meldet.
- `app/mailers/login_mailer.rb` / `config/locales/mailer.de.yml:3`: Betreffs liegen unter `de.m3.login_mailer`, gesucht wird `de.login_mailer` → englische Betreffs.
- `app/uploaders/team_logo_uploader.rb:20`: `extension_white_list` → in CarrierWave 3 `extension_allowlist`; Endungsprüfung wirkungslos.

## Mit pending-Test – Serien
- `app/controllers/backend/series/round_imports_controller.rb:18`: Rückgabewert von `save` ignoriert → Redirect „Erfolg“ obwohl nichts importiert.
- `app/models/series/round_import.rb:96,144`: Rang 0 (leer/„D“) → `points_for_rank[-1]` → bekommt Punkte des letzten Platzes.
- `app/models/series/round_import.rb:24-30`: fehlende `series_*_round_keys` → `nil.each` NoMethodError.
- `app/models/series/round_import.rb:7,10`: `belongs_to :round/:cup` ohne `class_name` → `round_id=` wirft NameError.
- `app/models/series/assessment_calculation.rb:16-30`: ohne `honor_ranking_logic` keine Sortierung nach Rang → Einträge ohne Rang mitten in der Tabelle.

## Mit pending-Test – Charts / Sonstiges
- `app/helpers/chart/competitions_score_overview.rb:8`: `month_names[month - 1]` → Monatsnamen um eins verschoben (Array beginnt mit nil).
- `app/helpers/chart/competitions_score_overview.rb:22`: `day_names[wday]` mit 1..7 → Sonntag `nil`.
- `app/helpers/chart/team_show.rb:13`: Gender-Keys als String, `gender_color` erwartet Symbole → Tortenstücke ohne Farbe.
- `app/models/import/line.rb:15`: `Discipline.group?(check)` statt `check.discipline` → bei Gruppendisziplinen werden Personen gesucht.
- `app/models/team.rb:61-74` (`normalize_name`): römische Nummer + Lauf („FF Warin II C“) wird nicht gefunden; Lauf „D“ nicht entfernt.
- `app/controllers/concerns/merge_action.rb:17`: `resource_variable_name` existiert nicht → NameError statt JSON-Fehler.
- `app/decorators/change_log_decorator.rb`: Z. 45 `default_ab:` statt `default:`; Z. 116/124 Merge-Links ohne ID; Z. 65 rescue ruft erneut fehlerhafte Methode; Z. 20 `Series::Participation` existiert nicht.
- `app/decorators/competition_decorator.rb:64`: `hl_male` fehlt, `hb_male` doppelt.
- `app/serializers/user_serializer.rb:7`: `type` liefert bei dekorierten Objekten „admin-user-decorator“.
- `app/controllers/concerns/pdf_support.rb:19`: `prawnto` existiert in prawn-rails nicht mehr (toter Code).

## Ohne Test – zu entscheiden / prüfen
- **Rechte** (`app/models/ability.rb`): `can :index, ImportRequest` für normale Nutzer ohne Bedingung → Backend-Index zeigt fremde Import-Requests (Z. 66-67).
  Jeder registrierte Nutzer darf Teams ändern (u. a. als „geprüft“ markieren). Backend-Indexe öffentlich lesbarer Ressourcen ohne Login erreichbar.
  `can :manage, Link` doppelt (Z. 33). `sub_admin_with_series` darf `Series::Kind` nur lesen – gewollt?
- `app/models/import_request.rb:45-48`: Ergebnis von `keys.map` verworfen, `where(id: "12-female")` klappt nur durch Integer-Cast.
- `app/controllers/errors_controller.rb` `OLD_PATHS`: `best-performance-of-year` ↔ `best_scores` vermutlich vertauscht.
- `app/models/series/assessment_config.rb:68` `honor_rank` definiert, aber `assessment_calculation.rb:23` nutzt fest `rank <= 3`.
- `app/models/series/round_import.rb:84`: `raise config.disciplines` (Array) → TypeError.
- Toter/kaputter Code: `Series::TeamAssessmentDecorator`, `Series::AssessmentSerializer`, `decorates_association :participations`,
  `EntitySupport#storage_support_get`, `Bla::BadgeDecorator#second_time`, `Backend::ResourcesHelper#breadcrum`,
  `app/views/series/rounds/_endless_table.html.haml`, else-Zweig in `Api::SuggestionsController#people`.
- `Score.best_of*` filtern weder ungültige Zeiten noch Finals/außer Wertung (Ist-Verhalten im Spec festgehalten).
- `app/models/years/inprovement.rb:12`: Memoisierung greift nicht (`@person_ids ||` ohne Zuweisung).
- `app/models/caching/cache.rb:40-50`: `disable` ohne `ensure`, globales class_attribute (nicht threadsicher).
- `app/jobs/debug_job.rb:17,40`: `hostname` mit Zeilenumbruch im Mail-Betreff.
- `app/models/import/scores.rb:61`: neue Personen fest `nation_id: 1`.
- Factory `single_discipline :hb_female` setzt `default_for_male` statt `default_for_female`.
- capistrano3_featureset 1.2.0: `Capistrano::Error` existiert nicht (version_manager.rake).
