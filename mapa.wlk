import direcciones.*
import link.*
import objetos.*
import enemigos.*

object randomizer {
    method position() {
        return game.at(
            (0 .. game.width() - 1).anyOne(),
            (0 .. game.height() - 1).anyOne()
        )
    }

    method emptyPosition() {
        const position = self.position()
        const objetosEnPos = game.getObjectsIn(position)

        if (objetosEnPos.isEmpty()) {
            return position
        } else {
            return self.emptyPosition()
        }
    }
}

object spawner {
    const property spawneados = #{}

    method spawnear(fabrica) {
        const nuevo = fabrica.crear(randomizer.emptyPosition())
        spawneados.add(nuevo)
        game.addVisual(nuevo)
    }

    method spawnearVarios(fabrica, cantidad) {
        (1 .. cantidad).forEach({ _ => self.spawnear(fabrica) })
    }

    method spawnearEnRango(fabrica, min, max) {
        self.spawnearVarios(fabrica, (min .. max).anyOne())
    }

    method quitar(spawneado) {
        if (game.hasVisual(spawneado)) {
            game.removeVisual(spawneado)
        }
        spawneados.remove(spawneado)
    }

    method limpiarSala() {
        spawneados.forEach({ elem => self.quitar(elem) })
    }
}

object fabricanteCofre {
    method crear(position) {
        return new Cofre(position = position, recompensa = new Llave())
    }
}

object fabricanteVasija {
    method crear(position) {
        return new Vasija(position = position, recompensa = self.recompensaAlAzar())
    }

    method recompensaAlAzar() {
        return [sinRecompensa, sinRecompensa, new Corazon()].anyOne()
    }
}

object fabricanteSoldado {
    method crear(position) {
        const soldado = new Soldado(position = position, recompensa = new Corazon())
        soldado.iniciarMovimiento()
        return soldado
    }
}

object nivel {
    const jugador = link

    method iniciar() {
        spawner.spawnear(fabricanteCofre)
        spawner.spawnearEnRango(fabricanteVasija, 3, 10)
        spawner.spawnearEnRango(fabricanteSoldado, 3, 5)
        game.addVisual(jugador)
        self.configurarTeclas()
        self.configurarColisiones()
    }

    method configurarTeclas() {
        keyboard.left().onPressDo({ jugador.mover(izquierda) })
        keyboard.right().onPressDo({ jugador.mover(derecha) })
        keyboard.up().onPressDo({ jugador.mover(arriba) })
        keyboard.down().onPressDo({ jugador.mover(abajo) })
        keyboard.z().onPressDo({ jugador.usarArma() })
        keyboard.space().onPressDo({ jugador.usarArma() })
    }

    method configurarColisiones() {
        game.onCollideDo(jugador, { objeto => objeto.alChocarCon(jugador) })
    }
}