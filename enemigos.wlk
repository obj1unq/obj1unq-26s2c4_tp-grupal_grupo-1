import direcciones.*
import link.*
import partida.*

class Enemigo {
    var property position
    const property objetivo = link
    const registro = marcador
    var danioRecibido = 0

    method initialize() {
        game.onTick(self.intervalo(), self.nombreDelMovimiento(), { self.moverse() })
    }

    method nombreDelMovimiento() = "moverse-" + self.identity().toString()

    method esAtravesable() = false

    method interactuarCon(personaje) {
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
        game.removeTickEvent(self.nombreDelMovimiento())
        game.removeVisual(self)
        registro.registrarVencido(self)
    }

    method moverse() {
        const destino = self.direccionElegida().posicionAlLado(position)
        if (objetivo.position() == destino) {
            self.tocarA(objetivo)
        } else if (tablero.estaLibre(destino)) {
            position = destino
        }
    }

    // Cada tipo de enemigo define estos métodos
    method image()
    method vida()
    method puntos()
    method intervalo()
    method direccionElegida()
}

class Murcielago inherits Enemigo {
    override method image() = "murcielago.png"
    override method vida() = 1
    override method puntos() = 50
    override method intervalo() = 400
    override method direccionElegida() = [arriba, abajo, izquierda, derecha].anyOne()
}

class Soldado inherits Enemigo {
    override method image() = "soldado.png"
    override method vida() = 2
    override method puntos() = 100
    override method intervalo() = 800

    override method direccionElegida() {
        const dx = self.objetivo().position().x() - self.position().x()
        const dy = self.objetivo().position().y() - self.position().y()
        return if (dx.abs() >= dy.abs()) self.horizontal(dx) else self.vertical(dy)
    }

    method horizontal(dx) = if (dx > 0) derecha else izquierda

    method vertical(dy) = if (dy > 0) arriba else abajo
}