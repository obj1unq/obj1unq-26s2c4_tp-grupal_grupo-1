import direcciones.*
import link.*
import partida.*
import mapa.*
import sonido.*

object sinRecompensa {
    method soltarEn(posicion) {}
}

class ElementoEscenario {
    var property position = game.at(0, 0)

    method esAtravesable() = true
    method detieneProyectil() = not self.esAtravesable()
    method recibirAtaque(danio) {}
    method interactuarCon(personaje) {}
    method alChocarCon(personaje) {}

    method recibirExplosion(danio) {
        self.recibirAtaque(danio)
    }

    method soltarEn(posicion) {
        position = posicion
        game.addVisual(self)
        spawner.redibujarPersonajes()
    }

    method quitarDelTablero() {
        if (game.hasVisual(self)) {
            game.removeVisual(self)
        }
    }

    method otrosObjetosEn(pos) {
        return game.getObjectsIn(pos).filter({ objeto => objeto != self })
    }
}

class ItemRecolectable inherits ElementoEscenario {
    override method alChocarCon(personaje) {
        sonido.item()
        self.aplicarA(personaje)
        self.quitarDelTablero()
    }

    method aplicarA(personaje)
}

class Llave inherits ItemRecolectable {
    method image() = "llave.png"

    override method aplicarA(personaje) {
        personaje.agarrarLlave()
    }
}

class Corazon inherits ItemRecolectable {
    method image() = "corazon.png"

    override method aplicarA(personaje) {
        personaje.curar(1)
    }
}

class RefillFlechas inherits ItemRecolectable {
    const cantidad = 5

    method image() = "flecha-derecha.png"

    override method aplicarA(personaje) {
        personaje.agregarFlechas(cantidad)
    }
}

class Bomba inherits ItemRecolectable {
    method image() = "bomba.png"

    override method aplicarA(personaje) {
        personaje.agarrarBomba()
    }
}

class Pocion inherits ItemRecolectable {
    method image() = "pocion.png"

    override method aplicarA(personaje) {
        personaje.agarrarPocion()
    }
}

class Vasija inherits ElementoEscenario {
    var property estado = vasijaSana
    var property recompensa = sinRecompensa

    method image() = "vasija-" + estado.forma() + ".png"
    override method esAtravesable() = estado.esAtravesable()

    override method recibirAtaque(danio) {
        estado.alRecibirAtaque(self)
    }

    method romperse() {
        sonido.vasija()
        estado = vasijaRota
        recompensa.soltarEn(position)
        recompensa = sinRecompensa
        spawner.redibujarPersonajes()
    }
}

object vasijaSana {
    method forma() = "sana"
    method esAtravesable() = false

    method alRecibirAtaque(vasija) {
        vasija.romperse()
    }
}

object vasijaRota {
    method forma() = "rota"
    method esAtravesable() = true

    method alRecibirAtaque(vasija) {}
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

class Salida inherits ElementoEscenario {
    const orientacion = arriba
    const juego = partida

    method estaAbierta()
    method imagenCerrada()

    method image() {
        return if (self.estaAbierta()) {
            "puerta-abierta-" + orientacion.texto() + ".png"
        } else {
            self.imagenCerrada()
        }
    }

    override method esAtravesable() = self.estaAbierta()

    override method alChocarCon(personaje) {
        if (self.estaAbierta()) {
            self.cruzar()
        }
    }

    method cruzar() {
        juego.completarSala()
    }
}

class PuertaConCandado inherits Salida {
    var estado = puertaCerrada

    override method estaAbierta() = estado.esAtravesable()
    override method imagenCerrada() = "puerta-cerrada-" + orientacion.texto() + ".png"

    override method interactuarCon(personaje) {
        estado.interactuar(self, personaje)
    }

    method abrirCon(personaje) {
        self.validarLlave(personaje)
        personaje.usarLlave()
        estado = puertaAbierta
    }

    method validarLlave(personaje) {
        if (not personaje.tieneLlave()) {
            self.error("Necesitás una llave para abrir esta puerta")
        }
    }
}

object puertaCerrada {
    method esAtravesable() = false

    method interactuar(puerta, personaje) {
        puerta.abrirCon(personaje)
    }
}

object puertaAbierta {
    method esAtravesable() = true

    method interactuar(puerta, personaje) {}
}

class ParedAgrietada inherits Salida {
    var abierta = false

    override method estaAbierta() = abierta
    override method imagenCerrada() = "place_holder_cyan.png"

    override method recibirExplosion(danio) {
        abierta = true
    }
}

class PuertaPorEnemigos inherits Salida {
    override method estaAbierta() = not spawner.hayEnemigos()
    override method imagenCerrada() = "place_holder_cyan.png"
}

class BombaActiva inherits ElementoEscenario {
    method image() = "bomba.png"

    method activar() {
        game.schedule(1500, { self.explotar() })
    }

    method explotar() {
        sonido.explosion()
        self.quitarDelTablero()
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
    method image() = "place_holder_amarillo.png"

    method activar() {
        self.otrosObjetosEn(position).forEach({ objeto => objeto.recibirExplosion(3) })
        game.schedule(300, { self.quitarDelTablero() })
    }
}