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
)

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

= Grundlagen

== Die Programmiersprache Go

== Goroutinen

= Deployment

== Docker

== Kubernetes

= Ausblick

== Secrutiy

== Monitoring

== Distributed Tracing

