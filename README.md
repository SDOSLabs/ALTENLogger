- [ALTENLogger](#altenlogger)
  - [Introducción](#introducción)
  - [Instalación](#instalación)
    - [Añadir al proyecto](#añadir-al-proyecto)
    - [Como dependencia en Package.swift](#como-dependencia-en-packageswift)
  - [Cómo se usa](#cómo-se-usa)
    - [Ejemplos de uso](#ejemplos-de-uso)

# ALTENLogger
- Changelog: https://github.com/SDOSLabs/ALTENLogger/blob/main/CHANGELOG.md

## Introducción
`ALTENLogger` es una librería que se apoya en la librería `Logging` proporcionada por Apple en el [siguiente enlace](https://github.com/apple/swift-log.git). La librería `Logging` permite la creación de `Loggers` para personalizar la salida de los logs.
ALTENLogger proporciona dos `Loggers` que podemos usar en cualquier proyecto:
- `ALTENLoggerConsole`: Permite trazar logs que serán mostrados por consola
- `ALTENFirebaseLogHandler`: Permite trazar logs que serán enviados a `Firebase`

## Instalación

### Añadir al proyecto

Abrir Xcode y e ir al apartado `File > Add Packages...`. En el cuadro de búsqueda introducir la url del respositorio y seleccionar la versión:
```
https://github.com/SDOSLabs/ALTENLogger.git
```
`ALTENLogger` proporciona dos librerías que podemos añadir, en base a las necesidades del proyecto, al target de la aplicación en la que queremos que esté disponible:
- `ALTENLoggerConsole`
- `ALTENLoggerFirebase`

### Como dependencia en Package.swift

``` swift
dependencies: [
    .package(url: "https://github.com/SDOSLabs/ALTENLogger.git", .upToNextMajor(from: "1.0.0"))
]
```

`ALTENLogger` proporciona dos librerías que podemos añadir, en base a las necesidades del proyecto, al target de la aplicación en la que queremos que esté disponible:
``` swift
//Sólo ALTENLoggerConsole
.target(
    name: "MyTarget",
    dependencies: [
        .product(name: "ALTENLoggerConsole", package: "ALTENLogger")
    ]),
```

``` swift
//Sólo ALTENLoggerFirebase
.target(
    name: "MyTarget",
    dependencies: [
        .product(name: "ALTENLoggerFirebase", package: "ALTENLogger")
    ]),
```

``` swift
//Ambas dependencias: ALTENLoggerConsole y ALTENLoggerFirebase
.target(
    name: "MyTarget",
    dependencies: [
        .product(name: "ALTENLoggerConsole", package: "ALTENLogger"),
        .product(name: "ALTENLoggerFirebase", package: "ALTENLogger")
    ]),
```

## Cómo se usa

Para usar esta librería hay que seguir la documentación de la librería [`Logging`](https://github.com/apple/swift-log.git). Esta librería se usará como parte de su configuración.

De forma recomendada se puede añadir un fichero al proyecto con la siguiente implementación:

``` swift
//Fichero LoggerManager.swift

import Foundation
import Logging
import ALTENLoggerConsole
import ALTENLoggerFirebase
import FirebaseCrashlytics

public let logger: Logger = {
    var logger = Logger(label: Bundle.main.bundleIdentifier ?? "AppLogger") {
        MultiplexLogHandler([
            ALTENLoggerConsole.standardOutput(label: $0),
            ALTENFirebaseLogHandler.standardOutput(label: $0, crashlytics: Crashlytics.crashlytics())
        ])
    }
    logger.logLevel = .trace
    return logger
}()
```
> Si usamos `ALTENFirebaseLogHandler` es obligatorio haber iniciado la [configuración de Firebase](https://firebase.google.com/docs/ios/setup?hl=es) antes de inciar el `Logger`.
>
De esta forma tendremos disponible en todo el proyecto la variable `logger` que se usará para realizar los logs deseados.

---

Una vez realizada la configuración de `logger` se podrá usar en cualquier parte del proyecto.

### Ejemplos de uso

``` swift
public func loadData() async {
    logger.info("Start", metadata: nil)
    defer { logger.info("End", metadata: nil) }
    //Logic here
}
```
Salida por consola
```
🟦 2022-02-25T10:12:21+0100 [INFO com.your_bundle] [ListFilmViewModel.swift ➝ loadData() ➝ L:88] : Start
🟦 2022-02-25T10:12:21+0100 [INFO com.your_bundle] [ListFilmViewModel.swift ➝ loadData() ➝ L:89] : End
```
---
``` swift
public func search(searchTerm: String) async throws -> [FilmBO] {
    logger.debug("Start", metadata: ["searchTerm": "\(searchTerm)"])
    defer { logger.debug("End", metadata: ["searchTerm": "\(searchTerm)"]) }
    //Logic here
}
```
Salida por consola
```
🟩 2022-02-25T10:12:21+0100 [DEBUG com.your_bundle] [ListFilmViewModel.swift ➝ loadData() ➝ L:100] : Start - [searchTerm: "Avengers"]
🟩 2022-02-25T10:12:21+0100 [DEBUG com.your_bundle] [ListFilmViewModel.swift ➝ loadData() ➝ L:101] : End - [searchTerm: "Avengers"]
```
---
``` swift
public func save(text: String) {
    do {
        //Logic here
        logger.info("Save success", metadata: nil)
    } catch {
        logger.error("Error on save", metadata: ["error": "\(error.localizedDescription)"])
    }
}
```
Salida por consola
```
🟦 2022-02-25T10:12:21+0100 [INFO com.your_bundle] [ListFilmViewModel.swift ➝ loadData() ➝ L:132] : Save success
🟥 2022-02-25T10:12:21+0100 [ERROR com.your_bundle] [ListFilmViewModel.swift ➝ loadData() ➝ L:134] : Error on save
```
---

