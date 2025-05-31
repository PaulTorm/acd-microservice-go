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


== Zielsetzung
Der Schwerpunkt dieser Arbeit liegt auf der Auseinandersetzung mit den eingesetzten Technologien zur Implementierung.
Das dargestellte Anwendungsszenario erhebt dabei keinen Anspruch auf Vollständigkeit, und der entwickelte Prototyp ist nicht für den produktiven Einsatz vorgesehen.
Fehlende Aspekte, die in einer produktiven Umgebung zwingend erforderlich wären, werden in einem späteren Kapitel näher erläutert.

= Architektur
== Systemüberblick
Das Gesamtsystem besteht aus insgesamt fünf Microservices, dargestellt in @components. Jede Anfrage gelangt zentral über das Gateway
in das System. Dieses fungiert als Reverse Proxy, der beispielsweise Anfragen von nicht vertrauenswürdigen IP-Adressen verwerfen kann.
Jeder Microservice ist als RESTful Web Service implementiert und bietet jeweils eine eigene HTTP-Schnittstelle an. Alle Microservices
sind zustandslos und speichern ihre Daten bei Bedarf in einer PostgreSQL-Datenbank. Dabei besitzt jeder Microservice eine eigene
PostgreSQL-Instanz, um einen Single Point of Failure zu vermeiden.

#figure(
  image("diagrams/components.svg", width: 50%),
  caption: [
    Komponentenansicht des Gesamtsystems
  ],
) <components>

== Abläufe
Aus den Anwendungsfällen in @use-cases lassen sich die folgenden drei Sequenzen ableiten.

=== Prüfungsanmeldung
@register-for-exam zeigt den Ablauf einer erfolgreichen Prüfungsanmeldung. Der Exam Management Service speichert, welcher
Student zu welcher Prüfung angemeldet ist. Dabei handelt es sich um eine Many-to-Many-Relation, deren Integrität auf Ebene
der Microservices sichergestellt werden muss. Zu diesem Zweck sendet der Exam Management Service jeweils eine GET-Anfrage
an den Exam Service sowie an den Student Service, um zu verifizieren, dass sowohl die Prüfung, für die sich der Student
anmelden möchte, existiert, als auch der Student mit der angegebenen Matrikelnummer (studentId) im System vorhanden ist.

#figure(
  image("diagrams/register_for_exam.svg", width: 80%),
  caption: [
    Sequenzdiagramm für die Prüfungsanmeldung
  ],
) <register-for-exam>

=== Prüfungsabmeldung
Um sich von einer Prüfung abzumelden, muss lediglich wie in @unregister-for-exam dargestellt
die entsprechende Relation zwischen Student und Prüfung entfernt werden.

#figure(
  image("diagrams/unregister_for_exam.svg", width: 80%),
  caption: [
    Sequenzdiagramm für die Prüfungsabmeldung
  ],
) <unregister-for-exam>

=== Angemeldete Prüfungen einsehen
Das Einsehen aller angemeldeten Prüfungen ist die aufwendigste Operation, da die englische Übersetzung von der
Prüfungsentität getrennt ist. Für jeden Eintrag in der Relationstabelle muss anhand der Prüfungsnummer eine
Anfrage an den Exam Service sowie eine weitere an den Translation Service gestellt werden, um sowohl die
Prüfung als auch die zugehörige englische Beschreibung zu erhalten. Diese Informationen werden anschließend
im Exam Management Service zu einem gemeinsamen Objekt zusammengeführt und zurückgegeben.

#figure(
  image("diagrams/view_registered_exams.svg", width: 80%),
  caption: [
    Sequenzdiagramm zum Einsehen der angemeldeten Prüfungen
  ],
) <view-registered-exams>

== Hexagonales Microservice Design
Jeder Microservice folgt dem Prinzip der hexagonalen Architektur, auch bekannt als Ports and Adapters @cockburn-hexagonal.
Dieses Architekturmuster kapselt die Geschäftslogik innerhalb eines zentralen Anwendungskerns, der unabhängig von technischen
Details operiert. Der Anwendungskern definiert dabei abstrakte Schnittstellen, sogenannte Ports, über die er mit der Außenwelt
interagiert. Diese Ports stellen Interfaces dar, beispielsweise für Datenzugriffe oder externe Kommunikationsprozesse,
ohne konkrete Implementierungen festzulegen. Die tatsächliche Anbindung an externe Systeme erfolgt über Adapter, welche die jeweiligen
Ports implementieren. Ein einzelner Port kann durch mehrere Adapter bedient werden, die sogar zur Laufzeit austauschbar sind. So kann
etwa ein Kommunikationsport wahlweise über HTTP, gRPC @grpc oder GraphQL @graphql angesprochen werden. Ebenso kann ein Datenzugriffsport
unterschiedliche Implementierungen für MariaDB, PostgreSQL oder MongoDB besitzen. Durch diese konsequente Trennung von Kernlogik
und technischen Schnittstellen entsteht eine lose Kopplung, welche die Testbarkeit erhöht, technologische Flexibilität ermöglicht
und eine klare Trennung der Verantwortlichkeiten innerhalb des Microservices begünstigt.

#figure(
  image("diagrams/hexagonal_architecture.svg", width: 50%),
  caption: [
    Hexagonale Architektur des Exam Management Microservice
  ],
) <hexagonal-architecture>

@hexagonal-architecture veranschaulicht die hexagonale Architektur am Beispiel des Exam Management Service. Dieser Service hängt von
drei definierten Ports ab, über die er mit der Außenwelt interagiert. Zum einen verarbeitet er eingehende Anfragen über den Handler
Port, der als Schnittstelle für externe Kommunikation fungiert. Zum anderen kommuniziert der Service selbst mit anderen Services,
wofür der Request Client Port verantwortlich ist. Zusätzlich werden persistente Daten über den Repository Port verwaltet, der den
Zugriff auf die Datenbank abstrahiert. Für jeden dieser Ports existiert genau ein zugehöriger Adapter: Eingehende Anfragen werden
über einen HTTP Handler entgegengenommen, ausgehende Anfragen an andere Services über einen HTTP Client gesendet, und die Datenhaltung
erfolgt über einen Postgres Repository Adapter.

= Implementierung
== Die Programmiersprache Go
Für die Implementierung des Systems wurde die Programmiersprache Go verwendet. Go ist eine von Google entwickelte, kompilierte Sprache,
die sich insbesondere durch ihre Einfachheit, Effizienz und gute Unterstützung für nebenläufige Programmierung auszeichnet. Sie kombiniert
die Leistungsfähigkeit systemnaher Sprachen mit einer modernen, übersichtlichen Syntax. Go bietet ein starkes, statisches Typsystem, eine
umfangreiche Standardbibliothek sowie native Unterstützung für Netzwerk- und Serverprogrammierung. Aufgrund des geringen Kompilier-Overheads
und der Möglichkeit, plattformunabhängige Binärdateien zu erzeugen, eignet sich Go besonders gut für den Einsatz in verteilten Systemen
und Microservice-Architekturen. Ein bemerkenswerter Aspekt ist, dass viele populäre Werkzeuge und Plattformen wie Docker, Kubernetes,
Prometheus @prometheus, Grafana @grafana und Jaeger @jaeger in Go entwickelt wurden. Diese breite Adaption in der Industrie unterstreicht die Reife und Praktikabilität der Sprache.
Go verzichtet bewusst auf bestimmte komplexe Sprachkonstrukte, wie zum Beispiel Vererbung. Ziel ist es, die Lesbarkeit und Wartbarkeit des
Codes zu erhöhen. Funktionale Konzepte wie map, filter oder reduce sind nicht Bestandteil der Sprache, ebenso wenig wie ternäre Operatoren
oder if-Expressions mit Rückgabewerten. Schleifen müssen explizit formuliert werden, was zu einem konsistenteren und vorhersagbaren Kontrollfluss führt.
Eine weitere Besonderheit ist das Fehlerbehandlungsmodell. Go folgt dem Ansatz "Errors as values". Funktionen geben typischerweise neben dem
eigentlichen Rückgabewert auch einen Fehlerwert vom Typ ```go error``` zurück. Ist dieser Wert ```go nil```, wurde die Funktion erfolgreich ausgeführt.
Tritt jedoch ein Fehler auf, wird erwartet, dass dieser möglichst unmittelbar behandelt wird. Dadurch wird ein explizites und robustes
Fehlermanagement gefördert, das sich gut in die klar strukturierte Syntax der Sprache einfügt.

== Goroutines
Das Modell der nebenläufigen Programmierung in Go basiert auf sogenannten Goroutinen. Ein Codeabschnitt wird zu einer Goroutine, wenn
er mit dem Schlüsselwort ```go go``` eingeleitet wird. Goroutinen sind keine klassischen Betriebssystem-Threads, sondern deutlich
leichtergewichtige Konstrukte, die von der Go-Runtime verwaltet werden. Es können tausende Goroutinen gleichzeitig ausgeführt werden,
obwohl typischerweise nur wenige Threads im Hintergrund aktiv sind. Die Go-Runtime übernimmt die Planung (Scheduling) und Zuordnung
der Goroutinen auf die verfügbaren Threads. Dadurch ist das Starten einer Goroutine extrem schnell und ressourcenschonend.
Die Kommunikation und Synchronisation zwischen Goroutinen erfolgt über sogenannte Channels. Channels sind typisierte, thread-sichere
Warteschlangen mit fester Kapazität, die es ermöglichen, Daten zwischen Goroutinen sicher auszutauschen. Eine Goroutine kann
beispielsweise blockieren, bis ein Wert aus einem Channel gelesen werden kann, oder selbst Werte in einen Channel schreiben.
Ein praktisches Beispiel für die Verwendung von Channels ist die Reaktion auf Betriebssystemsignale wie SIGINT oder SIGTERM.
Das Paket os/signal aus der Standardbibliothek erlaubt es, entsprechende Signale über einen Channel zu empfangen. Dadurch können
Microservices auf externe Terminierungssignale reagieren und z.B. Ressourcen freigeben oder laufende Prozesse geordnet beenden (graceful shutdown).
#align(center)[
```go
sigChan := make(chan os.Signal, 1)
signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)
<-sigChan
```
]
Auch der HTTP-Server aus der Standardbibliothek nutzt Goroutinen intern: Für jede eingehende Anfrage wird automatisch eine neue
Goroutine erzeugt, sodass Anfragen asynchron und parallel verarbeitet werden können.

== Verwendete Bibliotheken
Die Standardbibliothek von Go ist sehr umfangreich und enthält unter anderem bereits einen vollständig funktionsfähigen HTTP-Server.
Aus diesem Grund wurde bei der Implementierung bewusst auf zusätzliche Frameworks verzichtet. Die einzige externe Abhängigkeit im
Bereich Routing ist das Paket gorilla/mux, das zur Verteilung eingehender Anfragen auf definierte Routen verwendet wird.
Obwohl moderne Web-Frameworks wie Gin @gin oder Air @air eine Vielzahl zusätzlicher Funktionalitäten bieten, fiel die Wahl bewusst auf
eine schlanke und leichtgewichtige Lösung. Das Anwendungsszenario ist in seiner Komplexität überschaubar, weshalb ein vollwertiges
Framework als unnötiger Overhead betrachtet wurde. Durch die Reduktion auf das Wesentliche konnte die Größe und Komplexität
der Anwendung gering gehalten werden. Auch auf den Einsatz eines Object-Relational Mappers (ORM) wie GORM @gorm wurde bewusst verzichtet.
Stattdessen erfolgt der Zugriff auf die PostgreSQL-Datenbank direkt über das Paket pgxpool mittels SQL. Da in diesem Anwendungsszenario
alle notwendigen JOINs auf Ebene der Microservices erfolgen, würde ein ORM nur begrenzten Mehrwert bieten. Gleichzeitig würde dessen
Verwendung eine Vielzahl zusätzlicher Abhängigkeiten mit sich bringen. Für den Gateway Service wurde das ```go httputil.ReverseProxy```
aus der Standardbibliothek verwendet. Dieses ermöglicht es, eingehende HTTP-Anfragen entgegenzunehmen, zu verarbeiten und gezielt weiterzuleiten.

== Nachteile
Trotz ihrer zahlreichen Vorteile weist die Programmiersprache Go einige Einschränkungen auf, die je nach Anwendungskontext relevant
sein können. Die bewusste Reduktion auf ein minimalistisches Sprachdesign führt dazu, dass bestimmte Sprachmerkmale und -konzepte
fehlen, die in anderen modernen Programmiersprachen als selbstverständlich gelten. So unterstützte Go lange Zeit keine generischen
Datentypen. Mit Version 1.18 wurden Generics eingeführt, allerdings bleiben die Nutzungsmöglichkeiten bislang vergleichsweise
eingeschränkt und weniger ausdrucksstark als in anderen Sprachen. Auch der sehr explizit gehaltene Ansatz zur Fehlerbehandlung
bringt Nachteile mit sich. Die wiederholte Überprüfung, ob ein zurückgegebener Fehlerwert ```go nil``` ist, führt häufig zu redundanten
und wenig eleganten Codeabschnitten. Ein weiterer Nachteil besteht im Einsatz einer Garbage Collection. Obwohl diese in Go sehr
performant implementiert ist, kann sie in Anwendungen mit Echtzeitanforderungen oder strikt deterministischer Speicherverwaltung
problematisch sein. Darüber hinaus fehlt eine feingranulare Kontrolle über Speicherlayout und Speicherzugriff, was den Einsatz
von Go in hardwarenahen oder stark performancekritischen Szenarien einschränkt.

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

=== Netzwerk Struktur
Jeder Microservice, der eine Datenbankverbindung aufbaut, befindet sich gemeinsam mit seinem zugehörigen Datenbank-Service
in einem separaten Docker-Netzwerk. Damit sich die Microservices dennoch untereinander aufrufen können, existiert ein
zusätzliches, geteiltes Netzwerk, das jedoch keine Datenbank-Services enthält. Dadurch ist es beispielsweise dem Exam
Service nicht möglich, auf die Datenbank des Student Service zuzugreifen. Sollte ein Microservice durch einen Angriff
kompromittiert werden, lässt sich der potenzielle Schaden somit begrenzen.

== Kubernetes

= Schwächen des Systems

== Dateninkonsistenz
Ein gravierender Designfehler im Aufbau des Systems besteht in der Trennung der englischen Übersetzung
vom Rest der Prüfungsentität. Zwar erfolgt der JOIN nicht mehr auf Datenbankebene, sondern wird im Microservice durch
mehrere getrennte Anfragen realisiert. Ist jedoch entweder der Translation Service oder der Exam Service bei der Erstellung
einer Prüfung nicht verfügbar, kann dies zu einem inkonsistenten Zustand führen. Dieses Problem erfordert den Einsatz
verteilter Transaktionen und die Implementierung eines Two-Phase Commit @two-phase-commit.

= Ausblick
Der implementierte Prototyp stellt eine funktionale Grundlage dar, ist jedoch noch nicht für den produktiven Einsatz geeignet.
Im Folgenden werden mögliche Weiterentwicklungen aufgezeigt, die für den Einsatz in einer realen Produktivumgebung erforderlich
oder zumindest wünschenswert wären.

== Secrutiy
Die HTTP-Endpunkte aller Microservices sind in der aktuellen Implementierung ungeschützt, sodass grundsätzlich jeder
unautorisierte Zugriffe durchführen kann. Um diese Endpunkte abzusichern, kann ein vertrauenswürdiger Identity Provider @digital-identity-guidelines
genutzt werden, der sogenannte JSON Web Tokens (JWTs) ausstellt. Ein Student könnte beispielsweise ein JWT erhalten,
der seine Matrikelnummer sowie seine Rolle enthält. Dieser Token wird bei jeder Anfrage an den Microservice mitgesendet.
Der Microservice überprüft anschließend die Gültigkeit der Signatur, ob der Token abgelaufen ist und ob die im Token
enthaltene Rolle berechtigt ist, auf die angeforderte Ressource zuzugreifen. Auf diese Weise kann der Zugriff feingranular
gesteuert werden. Das zugrunde liegende Sicherheitskonzept wird als Role-Based Access Control (RBAC) bezeichnet. Es
ermöglicht eine präzise Definition von Berechtigungen basierend auf Rollen und sorgt dafür, dass nur autorisierte Nutzer
bestimmte Operationen auf bestimmten Ressourcen ausführen dürfen.

== Monitoring
Verteilte Microservice-Architekturen erfordern eine umfassende Überwachung, um Verfügbarkeit, Stabilität und Fehlertoleranz
sicherzustellen. Mit Hilfe spezialisierter Werkzeuge wie Prometheus @prometheus können Dienste selbstständig Metriken erfassen und
exportieren, etwa zur Auslastung, Antwortzeiten oder Fehlerhäufigkeit. Diese Metriken lassen sich über Dashboards wie
Grafana @grafana in Echtzeit visualisieren, wodurch ein präziser Einblick in den Systemzustand ermöglicht wird. In Kombination
mit einem Alertmanager können definierte Schwellenwerte überwacht und bei kritischen Zuständen automatisiert Benachrichtigungen
an das Entwicklungsteam versendet werden. Darüber hinaus können Mechanismen zur automatisierten Neustartsteuerung implementiert
werden, um die Selbstheilung des Systems zu fördern. Durch dieses Monitoring- und Alerting-Konzept lässt sich die Betriebssicherheit
erhöhen und die Reaktionszeit auf Systemfehler deutlich verkürzen.

== Distributed Tracing
In Microservice-Architekturen besteht eine der zentralen Herausforderungen darin, Anfragen über zahlreiche, voneinander getrennte
Dienste hinweg nachvollziehbar zu machen. Herkömmliches Logging reicht hierbei oft nicht aus, da eine einzelne Benutzeranfrage
mehrere Microservices durchlaufen kann, wobei jeder Dienst eigene Logs erzeugt. Zur Lösung dieses Problems wird Distributed Tracing
eingesetzt, ein Verfahren, das es ermöglicht, zusammenhängende Abläufe über Systemgrenzen hinweg konsistent zu verfolgen.
Mit Werkzeugen wie Jaeger @jaeger werden Anfragen mit eindeutigen Trace-IDs versehen, die während der gesamten Verarbeitung
erhalten bleiben. So können Zeitverläufe, Fehlerquellen und Performance-Engpässe über alle beteiligten Services hinweg analysiert werden.
Die gewonnenen Traces lassen sich visualisieren und bieten somit eine detaillierte Einsicht in das Laufzeitverhalten verteilter Systeme.
Durch Distributed Tracing können Abhängigkeiten transparent gemacht, Ursachen für Latenzen identifiziert und die Gesamtperformance einer
Microservice-Architektur gezielt optimiert werden. Es stellt damit ein wesentliches Werkzeug zur Fehlersuche und Qualitätssicherung in
komplexen, verteilten Anwendungen dar.
