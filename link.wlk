import direcciones.*

object link {
    var position = game.at(0, 1)
    var property estado = normal
    var property direccionActual = abajo
    var property armaEquipada = espada
    var property tieneLlave = false
    var property vidas = 3
    var property puntos = 0

    method image() {
        return "link-" + estado.forma() + "-" + direccionActual.texto() + ".png"
    }

    method position() {
        return position
    }

    method position(_position) {
        position = _position
    }

    method esAtravesable() = false

    method recibirAtaque(danio) {
        self.recibirDanio(danio)
    }

    method alChocarCon(personaje) {}

    method mover(direccion) {
        direccionActual = direccion
        if (estado.puedeMover()) {
            const nuevaPosition = direccion.siguiente(position)
            position = nuevaPosition
        }
    }

    method usarArma() {
        if (estado.puedeMover()) {
            armaEquipada.usar(self)
        }
    }

    method agarrarLlave() {
        tieneLlave = true
        game.say(self, "¡Tengo la llave!")
    }

    method curar(cantidad) {
        vidas = (vidas + cantidad).min(5)
        game.say(self, "Vidas: " + vidas.toString())
    }

    method recibirDanio(cantidad) {
        vidas = (vidas - cantidad).max(0)
        if (vidas == 0) {
            game.say(self, "PERDI")
            game.schedule(1000, { game.stop() })
        } else {
            game.say(self, "¡Auch! Vidas: " + vidas.toString())
        }
    }

    method sumarPuntos(cantidad) {
        puntos += cantidad
    }
}

class Estado {
    const property forma
    const property puedeMover
}

const normal = new Estado(forma = "normal", puedeMover = true)
const ataque = new Estado(forma = "ataque", puedeMover = false)

object espada {
    const property danio = 1

    method usar(personaje) {
        personaje.estado(ataque)
        const posObjetivo = personaje.direccionActual().posicionAlLado(personaje.position())

        const golpe = new GolpeDeEspada(
            position = posObjetivo,
            direccion = personaje.direccionActual(),
            danioGolpe = self.danio()
        )
        game.addVisual(golpe)
        golpe.activar()

        game.schedule(500, { personaje.estado(normal) })
    }
}

class GolpeDeEspada {
    var property position
    const direccion
    const danioGolpe

    method image() = "estocada-" + direccion.texto() + ".png"
    method esAtravesable() = true
    method recibirAtaque(danio) {}
    method alChocarCon(personaje) {}

    method activar() {
        game.getObjectsIn(position).forEach({ objeto =>
            objeto.recibirAtaque(danioGolpe)
        })
        game.schedule(150, {
            if (game.hasVisual(self)) {
                game.removeVisual(self)
            }
        })
    }
}