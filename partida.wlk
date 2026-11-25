import mapa.*
import link.*

object marcador {
    const enemigosVencidos = []
    var salasCompletadas = 0

    method registrarVencido(enemigo) {
        enemigosVencidos.add(enemigo)
    }

    method completarSala() {
        salasCompletadas += 1
    }

    method reiniciar() {
        enemigosVencidos.clear()
        salasCompletadas = 0
    }

    method puntaje() = enemigosVencidos.sum({ enemigo => enemigo.puntos() }) + salasCompletadas * 200
}

object pantallaInicio {
    method position() = game.at(0, 0)
    method image() = "portada.png"
}

object partida {
    const registro = marcador
    const salas = [sala1, sala2, sala3, sala4]
    var indiceSalaActual = 0

    method mostrarMenu() {
        spawner.detenerEnemigos()
        game.clear()
        game.addVisual(pantallaInicio)
        keyboard.enter().onPressDo({ self.iniciar() })
    }

    method iniciar() {
        registro.reiniciar()
        link.reiniciar()
        indiceSalaActual = 0
        nivel.cargarSala(salas.get(indiceSalaActual))
    }

    method completarSala() {
        registro.completarSala()
        indiceSalaActual += 1
        if (indiceSalaActual < salas.size()) {
            nivel.cargarSala(salas.get(indiceSalaActual))
        } else {
            self.ganar()
        }
    }

    method ganar() {
        self.terminar("¡GANASTE!")
    }

    method perder() {
        self.terminar("GAME OVER")
    }

    method terminar(mensaje) {
        spawner.detenerEnemigos()
        game.clear()
        game.addVisual(new Cartel(position = game.center(), text = mensaje + "   Puntaje: " + registro.puntaje().toString()))
    }
}

class Cartel {
    const property position
    const property text

    method textColor() = "FFFFFFFF"
}