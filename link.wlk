import direcciones.*
import partida.*
import objetos.*

class Personaje {
    var property position = game.at(0, 0)
    var property estado = normal
    var property direccionActual = abajo
    var property armaEquipada = espada


    method image() {
        return self.nombreImagen() + "-" + estado.forma() + "-" + direccionActual.texto() + ".png"
    }

    method nombreImagen()

    method esAtravesable() = false

    method usarArma() {
        if (estado.puedeMover()) {
            armaEquipada.usar(self)
        }
    }

    method interactuarCon(personaje) {}
    method alChocarCon(personaje) {}
    method recibirExplosion(danio) {}
}

object link inherits Personaje(position = game.at(0, 1)) {
    var tieneLlave = false
    var corazones = 3
    var invulnerable = false
    var bombas = 0
    var pociones = 0
    var itemSeleccionado = itemBomba

    const juego = partida

    override method nombreImagen() = "link"

    method bombas() {
        return bombas
    }

    method pociones() {
        return pociones
    }

    method nombreItemSeleccionado() {
        return itemSeleccionado.nombre()
    }

    method agarrarBomba() {
        bombas += 1
    }

    method agarrarPocion() {
        pociones += 1
    }

    method seleccionarBomba() {
        itemSeleccionado = itemBomba
    }

    method seleccionarPocion() {
        itemSeleccionado = itemPocion
    }

    method usarItemSeleccionado() {
        if (estado.puedeMover()) {
            itemSeleccionado.usar(self)
        }
    }

    method usarBomba() {
        if (bombas > 0) {
            bombas -= 1
            self.colocarBomba()
        }
    }

    method colocarBomba() {
        const bomba = new BombaActiva(position = position)
        game.addVisual(bomba)
        bomba.activar()
    }

    method usarPocion() {
        if (pociones > 0) {
            pociones -= 1
            self.activarInvulnerabilidad(5000)
        }
    }

    method activarInvulnerabilidad(duracion) {
        invulnerable = true
        game.schedule(duracion, { self.volverAVulnerable() })
    }

    method tieneLlave() = tieneLlave
    method corazones() = corazones
    method invulnerable() = invulnerable

    method mover(direccion) {
        direccionActual = direccion
        if (estado.puedeMover()) {
            const posicionAnterior = position
            self.chocarConObjetosEn(direccion.posicionAlLado(position))
            if (position == posicionAnterior and not self.sinCorazones()) {
                position = direccion.siguiente(position)
            }
        }
    }

    method chocarConObjetosEn(destino) {
        if (tablero.dentro(destino)) {
            game.getObjectsIn(destino).forEach({ objeto => objeto.alChocarCon(self) })
        }
    }

    method interactuar() {
        if (estado.puedeMover()) {
            const destino = direccionActual.posicionAlLado(position)
            if (tablero.dentro(destino)) {
                game.getObjectsIn(destino).forEach({ objeto => objeto.interactuarCon(self) })
            }
        }
    }

    method agarrarLlave() {
        tieneLlave = true
    }

    method usarLlave() {
        tieneLlave = false
    }

    method curar(cantidad) {
        corazones = (corazones + cantidad).min(5)
    }

    method recibirAtaque(danio) {
        if (not invulnerable) {
            self.perderCorazones(danio)
        }
    }

    method perderCorazones(danio) {
        corazones = (corazones - danio).max(0)
        invulnerable = true
        game.schedule(1000, { self.volverAVulnerable() })
        if (self.sinCorazones()) {
            juego.perder()
        }
    }

    method volverAVulnerable() {
        invulnerable = false
    }

    method sinCorazones() = corazones == 0

    method reiniciar() {
        estado = normal
        direccionActual = abajo
        armaEquipada = espada
        tieneLlave = false
        corazones = 3
        invulnerable = false
        bombas = 0
        pociones = 0
        itemSeleccionado = itemBomba
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

    method estaEnRango(origen, destino) = tablero.estaAlLado(origen, destino)

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

    method activar() {
        game.getObjectsIn(position).forEach({ objeto =>
            if (objeto != self) {
                objeto.recibirAtaque(danioGolpe)
            }
        })
        game.schedule(150, {
            if (game.hasVisual(self)) {
                game.removeVisual(self)
            }
        })
    }

    method recibirExplosion(danio) {}

    method esAtravesable() = true
    method recibirAtaque(danio) {}
    method interactuarCon(personaje) {}
    method alChocarCon(personaje) {}
}

object itemBomba {
    method nombre() {
        return "Bomba"
    }

    method usar(personaje) {
        personaje.usarBomba()
    }
}

object itemPocion {
    method nombre() {
        return "Pocion"
    }

    method usar(personaje) {
        personaje.usarPocion()
    }
}