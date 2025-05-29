#import "template.typ": template

#show: template.with(
  title: "Microservices mit Google Go",
  authors: (
    (
      name: "Michael Pochtar",
      organization: "Technische Hochschule Mannheim",
      email: "michael.pochtar@stud.hs-mannheim.de"
    ),
    (
      name: "Paul Tormählen",
      organization: "Technische Hochschule Mannheim",
      email: "paul.tormaehlen@stud.hs-mannheim.de"
    )
  ),
  abstract: [
    TODO
  ],
  bibliography: bibliography("refs.bib"),
)

= Einleitung

== Motivation
An der Hochschule Mannheim existiert ein zentrales System zur Prüfungsorganisation (POS), das sämtliche prüfungsrelevanten Abläufe verwaltet.
Für jede Prüfung ist sowohl eine deutsche als auch eine englische Beschreibung erforderlich. Während die deutschen Beschreibungen in der
lokalen Datenbank der Hochschule Mannheim gespeichert sind, befinden sich die englischen Übersetzungen in einer externen Datenbank an
der Hochschule Reutlingen. Dadurch entstehen standortübergreifende JOIN-Operationen, die die Performance des Gesamtsystems spürbar beeinträchtigen.
Inspiriert von diesem Missstand untersucht dieses Paper eine mögliche Microservice-basierte Lösung für das beschriebene Problem.
Dabei werden die Prüfungsdetails und die englischen Übersetzungen in getrennten Datenbanken gespeichert.
Anstelle das Datenbankmanagementsystem für standortübergreifende JOIN-Operationen zu verwenden, werden Microservices so gestaltet
und komponiert, dass ein solcher JOIN nicht mehr notwendig ist.

== Akteure und Anwendungsfälle
Um den Umfang des Projekts einzugrenzen, wurde in diesem Paper prototypisch lediglich ein ausgewählter Teilbereich des
Prüfungsorganisationssystems (POS) implementiert. Im Fokus stehen dabei die Studierenden mit den zentralen Anwendungsfällen
der Anmeldung und Abmeldung zu Prüfungen sowie der Einsicht einer Übersicht aller angemeldeten Prüfungen. Zusätzlich wurden
Funktionalitäten zum Anlegen, Bearbeiten, Einsehen und Löschen von Prüfungen umgesetzt. Für diese administrativen Operationen
ist zwar kein expliziter Akteur definiert, sie sind jedoch notwendig, um die genannten Anwendungsfälle der Studierenden
sinnvoll abbilden zu können.

#figure(
  image("diagrams/use_cases.svg", width: 50%),
  caption: [
    Use-Case Diagramm der Prüfungsverwaltung für Studierende
  ],
) <use-cases>

@register-for-exam zeigt den Ablauf einer erfolgreichen Prüfungsanmeldung. Der Exam Management Service speichert, welcher
Student zu welcher Prüfung angemeldet ist. Dabei handelt es sich um eine Many-to-Many-Relation, deren Integrität auf Ebene
der Microservices sichergestellt werden muss. Zu diesem Zweck sendet der Exam Management Service jeweils eine GET-Anfrage
an den Exam Service sowie an den Student Service, um zu verifizieren, dass sowohl die Prüfung, für die sich der Student
anmelden möchte, existiert, als auch der Student mit der angegebenen Matrikelnummer im System vorhanden ist.

#figure(
  image("diagrams/register_for_exam.svg", width: 80%),
  caption: [
    Sequenzdiagramm für die Prüfungsanmeldung
  ],
) <register-for-exam>

== Zielsetzung
Der Schwerpunkt dieser Arbeit liegt auf der Auseinandersetzung mit den eingesetzten Technologien zur Implementierung.
Das dargestellte Anwendungsszenario erhebt dabei keinen Anspruch auf Vollständigkeit, und der entwickelte Prototyp ist nicht für den produktiven Einsatz vorgesehen.
Fehlende Aspekte, die in einer produktiven Umgebung zwingend erforderlich wären, werden in einem späteren Kapitel näher erläutert.

= Architektur
== Systemüberblick
Das Gesamtsystem besteht aus insgesamt fünf Microservices, dargestellt in @components. Jede Anfrage kommt zentral
über das Gateway in das System. Es fungiert als Reverse Proxy, der zum Beispiel Anfragen von nicht vertrauenswürdigen
IP-Adressen verwerfen kann. Jeder Microservice ist implementiert als RESTful Web Service und bietet jeweils seine
eigene HTTP-Schnittstelle an.

#figure(
  image("diagrams/components.svg", width: 50%),
  caption: [
    Komponentenansicht des Gesamtsystems
  ],
) <components>

== Hexagonales Microservice Design

= Implementierung
== Die Programmiersprache Go
== Goroutines

= Deployment

== Docker
Das Bauen der Docker Images erfolgt in zwei Stages. Die erste Stage enthält den Go Compiler
und kompiliert den Code zu einer statisch verlinkten ausführbaren Datei, abhängig von der konfigurierten Plattform.
Da die Docker Container unter Linux laufen, ist die Zielplattform Linux. In der zweiten Stage wird die kompilierte
Binary in einen Scratch Container kopiert, der nichts außer dieser ausführbaren Datei enthält. Dadurch entsteht
ein sehr schlankes Docker Image, wie @image-size zeigt. Ein Nachteil eines Scratch Containers ist,
dass dieser tatsächlich keinerlei zusätzliche Komponenten enthält – nicht einmal eine Shell.
Daher ist es zur Laufzeit unmöglich, sich mit dem Container zu verbinden, was das Debugging potenziell erschwert.

#figure(
  table(
    columns: 6,
    rows: 2,
    align: center,
    [Image Name], [Gateway], [Exam Management], [Translation], [Exam], [Student],
    [Image Size], [8.82 MB], [12.3 MB], [11.6 MB], [11.6 MB], [11.6 MB],
  ),
  caption: [Größe der Docker Images],
) <image-size>

== Kubernetes

= Probleme des Systems
Ein gravierender Designfehler im Aufbau des Systems besteht in der Trennung der englischen Übersetzung
vom Rest der Prüfungsentität. Zwar erfolgt der JOIN nicht mehr auf Datenbankebene, sondern wird im Microservice durch
mehrere getrennte Anfragen realisiert. Ist jedoch entweder der Translation Service oder der Exam Service bei der Erstellung
einer Prüfung nicht verfügbar, kann dies zu einem inkonsistenten Zustand führen. Dieses Problem erfordert den Einsatz
verteilter Transaktionen und die Implementierung eines Two-Phase Commit @two-phase-commit.

= Ausblick
== Secrutiy
== Monitoring
== Distributed Tracing

