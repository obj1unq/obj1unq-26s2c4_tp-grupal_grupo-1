import direcciones.*
import link.*
import objetos.*

class Enemigo {
    var property position = game.at(0, 0)
    var property estado = normal
    var property direccionActual = abajo
    var property armaEquipada = espada
    var property vidas
    const puntosQueOtorga
    var property recompensa = sinRecompensa

    method image()
    method intervaloMovimiento()
    method direccionElegida()

    method esAtravesable() = false

    method alChocarCon(personaje) {
        personaje.recibirDanio(1)
    }

    method usarArma() {
        if (estado.puedeMover()) {
            armaEquipada.usar(self)
        }
    }

    method recibirAtaque(danio) {
        vidas = (vidas - danio).max(0)
        if (vidas == 0) {
            self.morir()
        }
    }

    method morir() {
        link.sumarPuntos(puntosQueOtorga)
        game.removeTickEvent(self.idMovimiento())
        if (game.hasVisual(self)) {
            game.removeVisual(self)
        }
        recompensa.soltarEn(position)
    }

    method idMovimiento() {
        return "movimiento-" + self.identity().toString()
    }

    method iniciarMovimiento() {
        game.onTick(self.intervaloMovimiento(), self.idMovimiento(), { self.actuar() })
    }

    method actuar() {
        if (estado.puedeMover()) {
            if (tablero.estaAlLado(position, link.position())) {
                direccionActual = tablero.direccionHaciaVecino(position, link.position())
                self.usarArma()
            } else if (tablero.hayDireccionLibre(position)) {
                direccionActual = self.direccionElegida()
                position = direccionActual.posicionAlLado(position)
            }
        }
    }
}

class Soldado inherits Enemigo(vidas = 2, puntosQueOtorga = 100) {
    override method image() {
        return "soldado-" + estado.forma() + "-" + direccionActual.texto() + ".png"
    }

    override method intervaloMovimiento() = 1000

    override method direccionElegida() {
        return tablero.direccionesLibres(position).min({ dir =>
            tablero.distancia(dir.posicionAlLado(position), link.position())
        })
    }
}