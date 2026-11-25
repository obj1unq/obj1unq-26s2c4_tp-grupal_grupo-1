import direcciones.*
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
    method alChocarCon(personaje) {}

    method soltarEn(posicion) {
        position = posicion
        game.addVisual(self)
        spawner.redibujarPersonajes()
    }
}

class Llave inherits ElementoEscenario {
    method image() = "llave.png"

    override method alChocarCon(personaje) {
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

    override method alChocarCon(personaje) {
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
    const orientacion = arriba
    var estado = puertaCerrada
    const juego = partida

    method image() = "puerta-" + estado.forma() + "-" + orientacion.texto() + ".png"

    override method esAtravesable() = estado.esAtravesable()

    override method interactuarCon(personaje) {
        estado.interactuar(self, personaje)
    }

    override method alChocarCon(personaje) {
        estado.alChocar(self, personaje)
    }

    method abrirCon(personaje) {
        self.validarLlave(personaje)
        personaje.usarLlave()
        estado = puertaAbierta
    }

    method cruzar() {
        juego.completarSala()
    }

    method validarLlave(personaje) {
        if (not personaje.tieneLlave()) {
            self.error("Necesitás una llave para abrir esta puerta")
        }
    }
}

object puertaCerrada {
    method forma() = "cerrada"
    method esAtravesable() = false

    method interactuar(puerta, personaje) {
        puerta.abrirCon(personaje)
    }

    method alChocar(puerta, personaje) {}
}

object puertaAbierta {
    method forma() = "abierta"
    method esAtravesable() = true

    method interactuar(puerta, personaje) {}

    method alChocar(puerta, personaje) {
        puerta.cruzar()
    }
}

const rota = new Estado(forma = "rota", puedeMover = true)
const sana = new Estado(forma = "sana", puedeMover = false)