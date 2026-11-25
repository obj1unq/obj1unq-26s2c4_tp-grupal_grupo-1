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
    method recibirExplosion(danio) {
        self.recibirAtaque(danio)
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

class Bomba inherits ElementoEscenario {
    method image() {
        return "place_holder_negro.png"
    }

    override method alChocarCon(personaje) {
        personaje.agarrarBomba()
        if (game.hasVisual(self)) {
            game.removeVisual(self)
        }
    }
}

class Pocion inherits ElementoEscenario {
    method image() {
        return "place_holder_verde.png"
    }

    override method alChocarCon(personaje) {
        personaje.agarrarPocion()
        if (game.hasVisual(self)) {
            game.removeVisual(self)
        }
    }
}

class BombaActiva inherits ElementoEscenario {
    method image() {
        return "place_holder_negro.png"
    }

    method activar() {
        game.schedule(1500, { self.explotar() })
    }

    method explotar() {
        if (game.hasVisual(self)) {
            game.removeVisual(self)
        }
        self.posicionesAfectadas().forEach({ pos => self.detonarEn(pos) })
    }

    method posicionesAfectadas() {
        const vecinas = tablero.direcciones().map({ dir => dir.posicionAlLado(position) })
        const todas = [position] + vecinas
        return todas.filter({ pos => tablero.dentro(pos) })
    }

    method detonarEn(pos) {
        const explosion = new Explosion(position = pos)
        game.addVisual(explosion)
        explosion.activar()
    }
}

class Explosion inherits ElementoEscenario {
    method image() {
        return "place_holder_amarillo.png"
    }

    method activar() {
        game.getObjectsIn(position).forEach({ objeto =>
            if (objeto != self) {
                objeto.recibirExplosion(3)
            }
        })
        game.schedule(300, {
            if (game.hasVisual(self)) {
                game.removeVisual(self)
            }
        })
    }
}
class ParedAgrietada inherits ElementoEscenario {
    var estado = puertaCerrada
    const juego = partida

    method image() {
        return if (estado.esAtravesable()) "puerta-abierta-arriba.png" else "place_holder_cyan.png"
    }

    override method esAtravesable() {
        return estado.esAtravesable()
    }

    override method recibirAtaque(danio) {}

    override method recibirExplosion(danio) {
        estado = puertaAbierta
    }

    override method alChocarCon(personaje) {
        estado.alChocar(self, personaje)
    }

    method cruzar() {
        juego.completarSala()
    }
}

class PuertaPorEnemigos inherits ElementoEscenario {
    const orientacion = derecha
    const juego = partida

    method image() {
        if (self.estaAbierta()) {
            return "puerta-abierta-" + orientacion.texto() + ".png"
        } else {
            return "place_holder_cyan.png"
        }
    }

    method estaAbierta() {
        return !spawner.hayEnemigos()
    }

    override method esAtravesable() {
        return self.estaAbierta()
    }

    override method alChocarCon(personaje) {
        if (self.estaAbierta()) {
            juego.completarSala()
        }
    }
}

const rota = new Estado(forma = "rota", puedeMover = true)
const sana = new Estado(forma = "sana", puedeMover = false)