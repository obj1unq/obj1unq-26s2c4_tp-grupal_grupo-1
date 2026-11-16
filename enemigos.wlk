import direcciones.*
import link.*
import objetos.*
import partida.*
import mapa.*

class Enemigo inherits Personaje {
    const property objetivo = link
    const registro = marcador
    var danioRecibido = 0
    var property recompensa = sinRecompensa

    method initialize() {
        self.iniciarMovimiento()
    }

    method iniciarMovimiento() {
        game.onTick(self.intervalo(), self.nombreDelMovimiento(), { self.moverse() })
    }

    method detenerMovimiento() {
        game.removeTickEvent(self.nombreDelMovimiento())
    }

    method nombreDelMovimiento() = "moverse-" + self.identity().toString()

    override method interactuarCon(personaje) {
        self.tocarA(personaje)
    }

    method tocarA(personaje) {
        personaje.recibirAtaque(1)
    }

    method recibirAtaque(danio) {
        danioRecibido += danio
        if (self.estaVencido()) {
            self.morir()
        }
    }

    method estaVencido() = danioRecibido >= self.vida()

    method morir() {
        self.detenerMovimiento()
        spawner.quitarEnemigo(self)
        if (game.hasVisual(self)) {
            game.removeVisual(self)
        }
        registro.registrarVencido(self)
        recompensa.soltarEn(position)
    }

    method moverse() {
        if (estado.puedeMover()) {
            if (tablero.estaAlLado(position, objetivo.position())) {
                direccionActual = tablero.direccionHaciaVecino(position, objetivo.position())
                self.tocarA(objetivo)
            } else if (tablero.hayDireccionLibre(position)) {
                direccionActual = self.direccionElegida()
                position = direccionActual.posicionAlLado(position)
            }
        }
    }

    method vida()
    method puntos()
    method intervalo()
    method direccionElegida()
}

class Murcielago inherits Enemigo {
    override method nombreImagen() = "murcielago"
    override method image() = "murcielago.png"
    override method vida() = 1
    override method puntos() = 50
    override method intervalo() = 400
    override method direccionElegida() = tablero.direccionesLibres(position).anyOne()
}

class Soldado inherits Enemigo {
    override method nombreImagen() = "soldado"
    override method vida() = 2
    override method puntos() = 100
    override method intervalo() = 800

    override method direccionElegida() {
        return tablero.direccionesLibres(position).min({ dir =>
            tablero.distancia(dir.posicionAlLado(position), objetivo.position())
        })
    }
}