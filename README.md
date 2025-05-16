This repository contains code for a microservice demo project using [go](https://go.dev/doc/) and [postgres](https://www.postgresql.org/).
The entire process is documented and compiled into a paper using [typst](https://typst.app/).

- POS
    - Prüfungen + Noten: Exam Service (alle Prüfungen mit PN (uuid), Kürzel, Credits, Modulname)
    - PNr. + Englische Übersetzung: Translation Service (PN, Englische Übersetzung vom Modulnamen)
    - Student (Matrikelnummer, Vorname, Nachname)
    - Prüfungsverwaltung Service (PNr, Matr. Nr, Note)

- Use-Cases: Prüfung anmelden, abmelden, einsehen (mit oder ohne Übersetzung)

- Actors: Student

- Motivation
- Go gute Standardlib, Begrüdung für kein Framework
- Dockerfile, scratch Container, ~5MB klein
- Request Handler, Middleware, goroutine?, Asynchronität
- Datenbankzugriffe, Postgres Adapter
- QA (Tests, Dependency Injection)
- Architektur (hexagonal, Ports & Adapters) Begründung warum wir es gewählt haben
- Systemarchitektur auf einer höheren Ebene (Englische Übersetzung, vermeitdet Joins standortübergreifend)
- Eingrenzung, Scope
- Ausblick (andere Actors und Use-Cases implementieren, z.B. Prof)
- Security (Absichern von Endpunkten)
- Begründen warum kein ORM

- OpenAPI?
- Prometheus, Jaeger?
- Frontend?

- Meilensteine:
    0. Bis Montag: Boilerplate, Gliederung
    1. Programmieren fertig, Einleitung fürs Paper und grobe Struktur circa. 5 Seiten, festlegen was 50% bedeutet in 2
    2. 50% des Papers (TODO: in 1), Services laufen in K8s
    3. Done
    4. Präsentation

