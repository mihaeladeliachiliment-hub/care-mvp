# Changelog

Toate modificările importante ale aplicației CARE sunt documentate în acest fișier.

Formatul este inspirat de principiile Keep a Changelog, iar versiunile respectă Semantic Versioning.

---

## [Unreleased]

### Teste

- Teste automate pentru istoricul antrenamentelor: salvare, încărcare, ordonare, fără dubluri, limită de 100, ștergere și date corupte.

### Eliminat

- Proiectul Flutter duplicat din subfolderul `care/` (PR #1).

### Modificat

- `README.md` descrie acum aplicația CARE, structura proiectului și pașii de rulare.
- Descrierea din `pubspec.yaml` a fost actualizată.
- Versiunea din `pubspec.yaml` a fost aliniată cu ultima versiune publicată (`1.1.0+2`).

### Planificat

- Mod întunecat (Dark Mode).
- Îmbunătățiri suplimentare de accesibilitate.
- Noi planuri de exerciții adaptate.
- Statistici mai detaliate despre progres.

---

## [1.1.0] - 2026-07-19

### Adăugat

- Buton STOP vizibil în bara superioară a ecranului de antrenament.
- Buton mare „Oprește antrenamentul”.
- Posibilitatea de a reveni la antrenament după apăsarea butonului „Mă simt rău”.

### Modificat

- Durata totală estimată a antrenamentului este afișată mai clar.
- Durata fiecărui exercițiu este afișată ca „Durată ghidată”.
- Dialogul „Mă simt rău” pune antrenamentul pe pauză și oferă două opțiuni:
  - Revenire la antrenament.
  - Încheierea antrenamentului.
- Dialogul de oprire explică faptul că antrenamentul rămâne în pauză până când utilizatorul apasă din nou „Pornește”.

### Siguranță

- Au fost păstrate mesajele de avertizare pentru durere, amețeală și dificultăți de respirație.
- Reluarea antrenamentului nu pornește automat cronometrul.
- Antrenamentele întrerupte nu sunt salvate ca finalizate.

---

## [1.0.1]

### Adăugat

- Buton „Trimite feedback”.

### Modificat

- Corectarea mesajului și a subiectului emailului de feedback.
- Îmbunătățiri minore ale interfeței.

---

## [1.0.0]

### Adăugat

- Prima versiune publică a aplicației CARE.
- Profil local al utilizatorului.
- Salvarea greutății și a greutății țintă.
- Calcul orientativ al IMC.
- Evaluare de sănătate.
- Recomandări de exerciții cu impact redus.
- Antrenament ghidat cu cronometru.
- Pauze între exerciții.
- Buton de siguranță „Mă simt rău”.
- Istoric local al antrenamentelor.
- Rezumat al progresului.
- APK Android pentru testare.