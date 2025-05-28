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
  abstract: lorem(50)
)

= Einleitung

== Motivation
An der Hochschule Mannheim existiert ein zentrales System zur Prüfungsorganisation, das sämtliche prüfungsrelevanten Abläufe verwaltet.
Für jede Prüfung ist sowohl eine deutsche als auch eine englische Beschreibung erforderlich. Während die deutschen Beschreibungen in der
lokalen Datenbank der Hochschule Mannheim gespeichert sind, befinden sich die englischen Übersetzungen in einer externen Datenbank an
der Hochschule Reutlingen. Dadurch entstehen standortübergreifende JOIN-Operationen, die die Performance des Gesamtsystems spürbar beeinträchtigen.
Inspiriert von diesem Missstand untersucht dieses Paper eine mögliche Microservice-basierte Lösung für das beschriebene Problem.
Dabei werden die Prüfungsdetails und die englischen Übersetzungen in getrennten Datenbanken gespeichert.
Anstelle das Datenbankmanagementsystem für standortübergreifende JOIN-Operationen zu verwenden, werden Microservices so gestaltet
und komponiert, dass ein solcher JOIN nicht mehr notwendig ist.

== Akteure und Anwendungsfälle
#lorem(50)

= Architektur

== Systemüberblick
#lorem(50)

== Hexagonales Microservice Design
#lorem(50)

= Grundlagen
#lorem(50)

== Die Programmiersprache Go
#lorem(50)

== Goroutinen
#lorem(50)

= Deployment
#lorem(50)

== Docker
#lorem(50)

== Kubernetes
#lorem(50)

= Ausblick
#lorem(30)

== Secrutiy
#lorem(50)

== Monitoring
#lorem(50)

== Distributed Tracing
#lorem(50)
