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
    Diese Arbeit untersucht die prototypische Umsetzung eines verteilten Softwaresystems auf Basis einer
    Microservice-Architektur unter Verwendung der Programmiersprache Go. Im Rahmen des Prototyps wird ein
    abgegrenzter Teilbereich eines Prüfungs-Organisations-Systems realisiert, mit dem Schwerpunkt auf der
    Prüfungsverwaltung aus Sicht der Studierenden. Der Fokus der Arbeit liegt auf der praktischen Implementierung
    sowie der Auswahl und Anwendung geeigneter Technologien zur Umsetzung einer modularen und wartbaren
    Systemarchitektur. Inhaltlich konzentriert sich der Prototyp auf drei zentrale Anwendungsfälle, nämlich
    die Anmeldung zu einer Prüfung, die Abmeldung von einer Prüfung sowie das Einsehen der aktuell angemeldeten Prüfungen.
  ],
  bibliography: bibliography("refs.bib"),
)

= Einleitung
Der gesamte Quellcode für das Projekt, inklusive des Papers, der Präsentation und eines kleinen Angular Frontends
für die Live-Demo, befindet sich unter Versionskontrolle auf #link("https://github.com/PaulTorm/acd-microservice-go")[Github].

== Motivation
An der Technischen Hochschule Mannheim existiert ein zentrales System zur Prüfungs-Organisations-Systems (POS), das sämtliche prüfungsrelevanten Abläufe verwaltet.
Für jede Prüfung ist sowohl eine deutsche als auch eine englische Beschreibung erforderlich. Während die deutschen Beschreibungen in der
lokalen Datenbank der Technischen Hochschule Mannheim gespeichert sind, befinden sich die englischen Übersetzungen in einer externen Datenbank an
der Hochschule Reutlingen. Dadurch entstehen standortübergreifende JOIN-Operationen, die die Performance des Gesamtsystems spürbar beeinträchtigen.
Inspiriert von diesem Missstand untersucht dieses Paper eine mögliche Microservice-basierte Lösung für das beschriebene Problem.
Dabei werden die Prüfungsdetails und die englischen Übersetzungen in getrennten Datenbanken gespeichert.
Anstelle das Datenbankmanagementsystem für standortübergreifende JOIN-Operationen zu verwenden, werden Microservices so gestaltet
und komponiert, dass ein solcher JOIN nicht mehr notwendig ist.

== Akteure und Anwendungsfälle
Um den Umfang des Projekts einzugrenzen, wurde in diesem Paper prototypisch lediglich ein ausgewählter Teilbereich des
POS implementiert. Im Fokus stehen dabei die Studierenden mit den zentralen Anwendungsfällen
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
PostgreSQL-Instanz, um die Applikationen separat von einander betreiben und warten zu könne.. Außerdem wird ein Single Point of Failure bei der Datenbank vermieden.

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
Ein praktisches Beispiel für die Verwendung von Channels ist die Reaktion auf Betriebssystemsignale wie SIGINT oder SIGTERM @channel.
Das Paket os/signal aus der Standardbibliothek erlaubt es, entsprechende Signale über einen Channel zu empfangen. Dadurch können
Microservices auf externe Terminierungssignale reagieren und z.B. Ressourcen freigeben oder laufende Prozesse geordnet beenden (graceful shutdown).
#figure(align(center)[
```go
sigChan := make(chan os.Signal, 1)
signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)
<-sigChan
```
], caption: [
  Go Channel, der auf SIGINT und SIGTERM hört
]) <channel>
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
Der folgende Abschnitt beschreibt das Deployment der Microservices in Docker Compose und Kubernetes.
Dabei wurde für Kubernetes das Werkzeug Minikube verwendet.

== Docker
Das Bauen der Docker Images erfolgt in zwei Stages. Die erste Stage enthält den Go Compiler
und kompiliert den Code zu einer statisch verlinkten ausführbaren Datei, abhängig von der konfigurierten Plattform.
Da die Docker Container unter Linux laufen, ist die Zielplattform Linux. In der zweiten Stage wird die kompilierte
Binary in einen Scratch Container kopiert, der nichts außer dieser ausführbaren Datei enthält. Dadurch entsteht
ein sehr schlankes Docker Image, wie @image-size zeigt. Ein Nachteil eines Scratch Containers ist,
dass dieser tatsächlich keinerlei zusätzliche Komponenten enthält – nicht einmal eine Shell.
Daher ist es zur Laufzeit unmöglich, sich mit dem Container zu verbinden, was das Debugging potenziell erschwert.


#show table.cell.where(y: 0): set text(weight: "bold")
#figure(
  table(
    columns: 6,
    rows: 2,
    align: center,
    stroke: none,
    table.header[Image Name][Gateway][Exam Management][Translation][Exam][Student],
    [Image Size], [8.82 MB], [12.3 MB], [11.6 MB], [11.6 MB], [11.6 MB],
  ),
  caption: [Größe der Docker Images],
) <image-size>

=== Netzwerkstruktur bei Docker
Jeder Microservice, der eine Datenbankverbindung aufbaut, befindet sich gemeinsam mit seinem zugehörigen Datenbank-Service
in einem separaten Docker-Netzwerk. Damit sich die Microservices dennoch untereinander aufrufen können, existiert ein
zusätzliches, geteiltes Netzwerk, das jedoch keine Datenbank-Services enthält. Dadurch ist es beispielsweise dem Exam
Service nicht möglich, auf die Datenbank des Student Service zuzugreifen. Sollte ein Microservice durch einen Angriff
kompromittiert werden, lässt sich der potenzielle Schaden somit begrenzen.

== Kubernetes
Im Folgenden wird beschrieben, wie jeder Microservice und die jeweiligen PostgreSQL-Datenbank-Instanzen in das Minikube
Kubernetes-Cluster deployed werden. Dabei ist das Minikube-Cluster mit 4 CPU-Kernen und 4 GB Arbeitsspeicher konfiguriert
und befindet sich auf einer Node.

=== Deployment der Microservices
Für jeden Microservice ist ein Deployment und ein Service definiert, über welchen die
entsprechende API des Microservices ansprechbar ist. Der Service leitet die Anfragen dann an das Deployment weiter, welches
schließlich die Anfrage an die verfügbaren Pods verteilt. Da alle Microservices zustandslos sind, kann die Anzahl der
verfügbaren Pods, auf die der Service verteilt, dynamisch horizontal skaliert werden, um effektiv Lastspitzen abzufangen.
Die Services sind alle vom Service Typ ClusterIP, das bedeutet, sie sind nur innerhalb des Clusters erreichbar. Um das Gateway
extern ansprechen zu können, müssen einige Vorbereitungen getroffen werden. Zunächst muss ein Ingress-Controller in das
Cluster installiert werden. Dieser hat die Aufgabe, externe Anfragen entgegenzunehmen und an entsprechende Services zu
delegieren. Der in Minikube installierte Ingress-Controller ist eine vorkonfigurierte NGINX-Instanz @nginx, wobei die letztendliche
Implementierung des Ingress-Controllers austauschbar ist. Es ist also auch möglich, statt NGINX beispielsweise Traefik @traefik zu
verwenden. Anschließend muss für das Gateway eine Ingress-Ressource definiert werden. Diese ist nicht von der konkreten
Implementierung des Ingress-Controllers abhängig und definiert lediglich, welche Anfragen an welche Services weitergeleitet werden.
Es ist also eine reine Spezifikation, die ohne einen funktionierenden Ingress-Controller nutzlos wäre.

#figure(
  image("diagrams/k8s.png", width: 60%),
  caption: [
    Übersicht der Deployment Strategie
  ],
) <deployment>

Der Gateway-Ingress ist so konfiguriert, dass er Anfragen von der Domain api.hs-mannheim.int nimmt und sie
unverändert an den Gateway-Service weiterleitet. Dabei ist api.hs-mannheim.int eine fiktive Domain. Sie funktioniert nur lokal,
da sie in der /etc/hosts -Datei auf die Minikube-IP zeigt. Es gibt sonst keinen DNS-Eintrag mit dieser Domain.
Der Gateway ingress übernimmt dabei auch die Aufgabe des TLS Endpunkts und ermöglicht es damit eine Transportverschlüsselung und
Authentifizierung gegenüber dem Client zu machen. Wir haben ein Self-Signed TLS Zertifikat benutzt, welches auf api.hs-mannheim.int ausgestellt ist und
es in unserem eigenen Trust Store hinterlegt. Dadurch wird eine TLS Kommunikation ermöglicht, auch wenn wir die Domain garnicht besitzen, da wir
der Zertifikat ohne weiteres vertrauen.

#figure(
  image("diagrams/k8s-svc-relations.png", width: 60%),
  caption: [
    Übersicht Zusammenhänge der Kubernetes Services
  ],
) <deployment-relations>

=== Netzwerkstruktur bei Kubernetes
Alle Microservices befinden sich in einem gemeinsamen Subnetz, welches per Kubernetes-Standard allen Ingress und Egress für Pods
in diesem Subnetz erlaubt. Da dies, wie auch im vorherigen Punkt schon genannt, zu Sicherheitsrisiken führt, werden in Kubernetes
NetworkPolicies benutzt, um die In- und Egress-Möglichkeiten einzuschränken. Es wird empfohlen, ein Deny-All für den Ingress einer
jeden Applikation zu erstellen, um den Ingress von nicht beabsichtigten Applikationen zu unterbinden. Für die jeweiligen
Microservices, die Datenbanken und den Proxy werden NetworkPolicies erstellt, um Kommunikation explizit zu erlauben.
Für die Anwendung von NetworkPolicies muss ein Container Network Interface (CNI) Plugin installiert sein. Erst dieses erlaubt
es, NetworkPolicies zu nutzen und weitere Networking-Optionen. Beliebte Beispiele für CNI sind Calico oder Cilium.
@networkpolicies

=== Deployment des Angular Frontends
Für die Live-Demo wurde eine kleine Angular-Anwendung entwickelt, die auch in Kubernetes mit einem Service und Deployment
definiert ist. Um diese Webanwendung erreichen zu können, wurde, analog zum Gateway, ein Frontend-Ingress angelegt, der
Anfragen von noten.hs-mannheim.int an den Frontend-Service weiterleitet. Man bemerke, dass ein Ingress-Controller ausreicht,
auch wenn zwei Ingress-Ressourcen vorhanden sind. Für beide Ingress-Ressourcen findet die Kommunikation bis zum Ingress-Controller
mittels TLS statt. Das dazugehörige Zertifikat wurde mithilfe von OpenSSH selbst ausgestellt, signiert und als Kubernetes-Secret
in das Cluster importiert. Es bleibt nur noch das Deployment der PostgreSQL-Datenbank.

=== PostgreSQL in Kubernetes
Alle Microservices bis auf das Gateway benötigen Zugang zu getrennten Postgres-Datenbank-Instanzen. Die einfachste Möglichkeit,
dies zu erreichen, besteht darin, jeweils einzelne Pods mit dem Postgres-Image zu deployen. Das wäre das Analogon zum Deployment
mit Docker Compose. Dieser Ansatz hat jedoch einige Nachteile, denn es gibt keine Replikation der Datenbank-Instanzen, also auch
keine horizontale Skalierung. Darunter leidet insbesondere auch die Verfügbarkeit. Ein Deployment für die Datenbank mit mehreren
Replikas funktioniert nicht, da die darunterliegenden Pods zufällig hoch- und heruntergefahren werden und nicht individuell ansprechbar
sind, da der Pod-Namenssuffix zufällig ist. Bei verteilten Datenbanken ist dies nicht möglich, weil die Master-Datenbank nicht einfach
terminiert werden darf und die Reihenfolge, in der die Slave-Datenbanken gestartet und gestoppt werden, entscheidend ist. All diese
Probleme werden von einem StatefulSet gelöst. Es ist eine mögliche und bessere Lösung im Vergleich zum Deployment. Dennoch ist viel
manueller Aufwand damit verbunden, die Datenbank-Instanzen richtig zu konfigurieren und miteinander zu verbinden. Auch Backups müssen
manuell durchgeführt werden, und damit sind die Vorteile, eine standard Postgres-Datenbank in Kubernetes zu betreiben, gering. Es gibt aber
zum Glück noch eine bessere Lösung, wofür jedoch zunächst einige Kubernetes-Konzepte näher beleuchtet werden müssen.

=== Kubernetes Operator
Kubernetes Operators @kubernetes-operator sind eine Erweiterung des Kubernetes-Ökosystems, die die Automatisierung und Verwaltung komplexer Anwendungen
durch die Einbindung domänenspezifischer Kenntnisse ermöglichen. Sie basieren auf dem Konzept von Custom Resource Definitions (CRDs),
die es ermöglichen, Anwendungslogik in Form von benutzerdefinierten Ressourcen (Custom Resources) zu modellieren. Ein Operator ist
ein Controller, der diese Ressourcen überwacht und entsprechende Aktionen ausführt, um den gewünschten Zustand (Desired State) der
Anwendung sicherzustellen. Im Gegensatz zu standardisierten Kubernetes-Objekten wie Pods oder Services, die generische
Funktionalitäten abdecken, ermöglichen Operators die Automatisierung von Anwendungs-spezifischen Workflows, z.B. die Einrichtung von
Datenbankreplikaten, die Ausführung von Backups oder die Skalierung zustandsbehafteter Anwendungen. Der Nutzen von Operators liegt in der
Reduktion manueller Eingriffe, der Gewährleistung von Konsistenz und der Integration komplexer Anwendungen in die Kubernetes-Infrastruktur.

=== CloudNativePG
CloudNativePG @cloudnativepg ist ein Kubernetes-Operator, der speziell für die Verwaltung von PostgreSQL-Datenbanken in Kubernetes-Umgebungen entwickelt
wurde. Er bietet die Ressource Cluster, mit der eine verteilte Datenbank automatisiert hochgefahren und konfiguriert wird. Dabei wird
automatisch ein Service erstellt, über den die Datenbank-Instanzen erreichbar sind. Wenn in der Konfiguration kein Benutzername und kein
Passwort explizit angegeben werden, generiert CloudNativePG automatisch ein Kubernetes-Secret, das den Datenbankzugang bereitstellt.
Die Menge an Speicher sowie die Anzahl der Instanzen lassen sich dabei sehr einfach konfigurieren @cluster.
Im geclusterten Modus wird die Datenbank in primäre und sekundäre Instanzen unterteilt, wodurch eine Lastverteilung bei Leseoperationen entsteht.
Geplante und ungeplante Ausfälle werden durch einen automatischen Wechsel der primären Instanz ohne Unterbrechung des Betriebs abgefangen. Dadurch
wird eine hohe Verfügbarkeit des Services sichergestellt. Mit diesem Ansatz erhält jeder Microservice sein eigenes Datenbank-Cluster.
#figure(align(center)[
```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: student-db
spec:
  instances: 3
  storage:
    size: 1Gi
```
], caption: [
  Ressourcendefinition eines Datenbank Clusters
]) <cluster>

=== Secret Management
In Kubernetes spielt Secret Management eine zentrale Rolle beim sicheren Umgang mit sensiblen Informationen wie
Passwörtern, API-Schlüsseln oder TLS-Zertifikaten. Diese Daten sollten niemals in Klartext in Konfigurationsdateien
oder Umgebungsvariablen abgelegt werden, sondern in dedizierten Kubernetes-Secrets gespeichert werden, um sie vom
restlichen Anwendungscode zu trennen und kontrolliert zugänglich zu machen. Für ein höheres Sicherheitsniveau
empfiehlt sich der Einsatz spezialisierter Secret Vaults wie HashiCorp Vault, AWS Secrets Manager oder Azure Key Vault.
Diese Lösungen bieten zusätzliche Vorteile wie zentrale Verwaltung, Versionskontrolle, Audit-Logs und automatisches
Rotieren von Geheimnissen. In Kombination mit Kubernetes-Operatoren oder CSI-Providern ist es zudem möglich, Secrets
automatisch und sicher in den Cluster zu synchronisieren, ohne sie manuell einpflegen zu müssen. Trotz dieser Vorteile
setzen wir in unserem Projekt zur Vereinfachung der Infrastruktur und des Deployments auf den direkten Einsatz von
Kubernetes-Secrets, ohne Integration eines externen Vault-Systems.

= Schwächen des Systems

== Dateninkonsistenz
Ein wesentlicher Designmangel im aktuellen System besteht in der trennenden Modellierung der englischen Übersetzung
als separate Entität, losgelöst von der zentralen Prüfungsentität. Obwohl die Verknüpfung der Daten nicht mehr auf
Datenbankebene durch einen JOIN erfolgt, sondern im Microservice über mehrere voneinander unabhängige Anfragen
realisiert wird, birgt dieses Vorgehen erhebliche Risiken. Ist zum Zeitpunkt der Prüfungserstellung entweder der
Translation Service oder der Exam Service nicht verfügbar, kann dies zu einem inkonsistenten Systemzustand führen.
Zur Gewährleistung der Konsistenz wäre der Einsatz verteilter Transaktionen, etwa durch einen Two-Phase Commit
@two-phase-commit, erforderlich. Dies bringt jedoch erhöhte Komplexität und Performanceprobleme mit sich. Eine
saubere und langfristig wartbare Lösung bestünde darin, die englische Übersetzung direkt in die Prüfungsentität
zu integrieren, da es sich um eine eindeutige One-to-One Relation handelt. Dadurch ließe sich das Problem der
Dateninkonsistenz vollständig umgehen. Während eine solche Integration im Rahmen einer Neuentwicklung problemlos
realisierbar wäre, bedarf es für ein bestehendes System einer durchdachten Migrationsstrategie, um den Übergang
konsistent und ohne Datenverlust zu gestalten.

= Ausblick
Der implementierte Prototyp stellt eine funktionale Grundlage dar, ist jedoch noch nicht für den produktiven Einsatz geeignet.
Im Folgenden werden mögliche Weiterentwicklungen aufgezeigt, die für den Einsatz in einer realen Produktivumgebung erforderlich
oder zumindest wünschenswert wären.

== Security
=== Nutzer Authentifizierung
Die HTTP-Endpunkte aller Microservices sind in der aktuellen Implementierung ungeschützt, sodass grundsätzlich jeder
unautorisierte Zugriffe durchführen kann. Um diese Endpunkte abzusichern, kann ein vertrauenswürdiger Identity Provider @digital-identity-guidelines
genutzt werden, der sogenannte JSON Web Tokens (JWTs) ausstellt. Ein Student könnte beispielsweise ein JWT erhalten,
der seine Matrikelnummer sowie seine Rolle enthält. Dieser Token wird bei jeder Anfrage an den Microservice mitgesendet.
Der Microservice überprüft anschließend die Gültigkeit der Signatur, ob der Token abgelaufen ist und ob die im Token
enthaltene Rolle berechtigt ist, auf die angeforderte Ressource zuzugreifen. Auf diese Weise kann der Zugriff feingranular
gesteuert werden. Das zugrunde liegende Sicherheitskonzept wird als Role-Based Access Control (RBAC) bezeichnet. Es
ermöglicht eine präzise Definition von Berechtigungen basierend auf Rollen und sorgt dafür, dass nur autorisierte Nutzer
bestimmte Operationen auf bestimmten Ressourcen ausführen dürfen. Alternativ könnte auch ein Zugriff basierend auf Attributen erfolgen,
die dem JWT des Nutzers angefügt werden. Dies erlaubt eine ähnliche feingranulare Steuerung, wie beim RBAC.

=== Verschlüsselung
In unserem Prototyp wird lediglich die Verbindung zwischen Client und Ingress per TLS abgesichert. Dies ist Standard und bei konventionellen Deployments
meist die einzige Form an Transportverschlüsselung. Im Kontext von Kubernetes handelt es sich häufig um Zero-Trust-Umgebungen. Dies bedeutet, dass
jegliche Verbindung als unsicher angesehen werden muss. Dafür eignet sich mutual TLS (mTLS). Dabei wird nicht nur einseitig, klassischerweise vom
Server, ein TLS-Zertifikat bereitgestellt, sondern auch vom zweiten Partner ein Zertifikat. Damit kann die Authentizität des jeweiligen Partners
sichergestellt werden und es wird eine zusätzliche Form der Verschlüsselung ermöglicht. Im Rahmen von Kubernetes bietet es sich an, einen Dienst
wie Istio zu benutzen. Dieser kann als Sidecar-Container deployed werden. Durch das Deployment als Sidecar-Container ist es bei der Implementierung
der Applikation nicht notwendig, TLS in irgendeiner Form zu beachten oder selber Zertifikate zu verwalten. Sämtlicher Traffic wird dann im Pod selber
über die Loopback-Adresse zwischen dem Hauptcontainer und dem Sidecar-Container verschickt, und der Traffic von extern wird ausschließlich über den
Sidecar-Container abgewickelt.


== Monitoring
Verteilte Microservice-Architekturen erfordern eine umfassende Überwachung, um Verfügbarkeit, Stabilität und Fehlertoleranz
sicherzustellen. Mit Hilfe spezialisierter Werkzeuge wie Prometheus @prometheus können Dienste selbstständig Metriken erfassen und
exportieren, etwa zur Auslastung, Antwortzeiten oder Fehlerhäufigkeit. Diese Metriken lassen sich über Dashboards wie
Grafana @grafana in Echtzeit visualisieren, wodurch ein präziser Einblick in den Systemzustand ermöglicht wird. In Kombination
mit einem Alertmanager können definierte Schwellenwerte überwacht und bei kritischen Zuständen automatisiert Benachrichtigungen
an das Entwicklungsteam versendet werden. Darüber hinaus können Mechanismen zur automatisierten Neustartsteuerung implementiert
werden, um die Selbstheilung des Systems zu fördern. Durch dieses Monitoring- und Alerting-Konzept lässt sich die Betriebssicherheit
erhöhen und die Reaktionszeit auf Systemfehler deutlich verkürzen. Es können außerdem auch Optimierungen gemacht werden, bspw. eine Auslastungsanalyse, um Kosten
und Ressourcen einzusparen.

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
