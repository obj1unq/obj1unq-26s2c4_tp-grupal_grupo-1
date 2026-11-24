import link.*
import partida.*
import mapa.*

object sinRecompensa {
    method soltarEn(posicion) {}
}

class ElementoEscenario {
    var property position = game.at(0, 0)

    method esAtravesable() = true
    method recibirAtaque(danio) {}
    method interactuarCon(personaje) {}

    method soltarEn(posicion) {
        position = posicion
        game.addVisual(self)
        spawner.redibujarPersonajes()
    }
}

class Llave inherits ElementoEscenario {
    method image() = "llave.png"

    override method interactuarCon(personaje) {
        self.serAgarradaPor(personaje)
    }

    method serAgarradaPor(personaje) {
        personaje.agarrarLlave()
        if (game.hasVisual(self)) {
            game.removeVisual(self)
        }
    }
}

class Corazon inherits ElementoEscenario {
    method image() = "corazon.png"

    override method interactuarCon(personaje) {
        personaje.curar(1)
        if (game.hasVisual(self)) {
            game.removeVisual(self)
        }
    }
}

class Vasija inherits ElementoEscenario {
    var property estado = sana
    var property recompensa = sinRecompensa

    method image() = "vasija-" + estado.forma() + ".png"

    override method recibirAtaque(danio) {
        if (estado == sana) {
            estado = rota
            recompensa.soltarEn(position)
            recompensa = sinRecompensa
            spawner.redibujarPersonajes()
        }
    }

    override method esAtravesable() = estado.puedeMover()
}

class Cofre inherits ElementoEscenario {
    var property abierto = false
    var property recompensa = sinRecompensa

    method image() = if (abierto) "cofre-abierto.png" else "cofre-cerrado.png"

    override method esAtravesable() = abierto

    override method recibirAtaque(danio) {
        self.abrir()
    }

    override method interactuarCon(personaje) {
        self.abrir()
    }

    method abrir() {
        if (not abierto) {
            abierto = true
            recompensa.soltarEn(position)
            recompensa = sinRecompensa
        }
    }
}

class Pared inherits ElementoEscenario {
    const property image = "pared.png"

    override method esAtravesable() = false
}

class PuertaConCandado inherits ElementoEscenario {
    var estado = cerrada
    const juego = partida

    method image() = "puerta-" + estado.forma() + ".png"

    override method esAtravesable() = estado.puedeMover()

    override method interactuarCon(personaje) {
        if (not self.esAtravesable()) {
            self.abrirCon(personaje)
        }
    }

    method abrirCon(personaje) {
        self.validarLlave(personaje)
        personaje.usarLlave()
        estado = abierta
        juego.completarSala()
    }

    method validarLlave(personaje) {
        if (not personaje.tieneLlave()) {
            self.error("Necesitás una llave para abrir esta puerta")
        }
    }
}

const rota = new Estado(forma = "rota", puedeMover = true)
const sana = new Estado(forma = "sana", puedeMover = false)
const cerrada = new Estado(forma = "cerrada", puedeMover = false)
const abierta = new Estado(forma = "abierta", puedeMover = true)