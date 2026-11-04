import link.*

object sinRecompensa {
    method soltarEn(posicion) {}
}

class ElementoEscenario {
    var property position = game.at(0, 0)

    method esAtravesable() = true
    method recibirAtaque(danio) {}
    method alChocarCon(personaje) {}

    method soltarEn(posicion) {
        position = posicion
        game.addVisual(self)
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
        estado = rota
        recompensa.soltarEn(position)
        recompensa = sinRecompensa
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

    override method alChocarCon(personaje) {
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

const rota = new Estado(forma = "rota", puedeMover = true)
const sana = new Estado(forma = "sana", puedeMover = false)