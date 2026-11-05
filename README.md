# CARE

CARE este o aplicație Flutter de exerciții ușoare și ghidate, gândită pentru persoane care vor să se miște în siguranță, în ritmul lor.

## Funcționalități

- **Profil** – greutate actuală, greutate-țintă și IMC orientativ.
- **Evaluare de sănătate** – afecțiuni cardiace, hipertensiune, dureri de genunchi, probleme de echilibru; planul de exerciții se adaptează în funcție de răspunsuri.
- **Exerciții recomandate** – plan ghidat (respirație calmă, mobilizări, exerciții din șezut sau cu sprijin).
- **Antrenament ghidat** – cronometru, buton STOP, opțiunea „Mă simt rău” care pune antrenamentul pe pauză și afișează mesaje de siguranță.
- **Istoric** – antrenamente finalizate, timp total activ, exerciții efectuate.

Datele sunt salvate local pe dispozitiv (`shared_preferences`).

## Structura proiectului

```
lib/
  main.dart              punctul de pornire
  app/app.dart           configurarea aplicației (temă, ecran inițial)
  screens/               ecranele: home, profile, health, exercises, workout
  services/              salvarea locală: profil, sănătate, istoric antrenamente
test/                    teste automate
```

## Rulare locală

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Versiuni

Istoricul modificărilor este în [CHANGELOG.md](CHANGELOG.md). Versiunile publicate sunt marcate cu taguri Git (de exemplu `v1.1.0`).

## Notă

CARE nu înlocuiește sfatul medicului. Înainte de a începe orice program de exerciții, utilizatorul trebuie să consulte un specialist.
