object marcador {
    const enemigosVencidos = []
    var salasCompletadas = 0

    method registrarVencido(enemigo) {
        enemigosVencidos.add(enemigo)
    }

    method completarSala() {
        salasCompletadas += 1
    }

    method puntaje() = enemigosVencidos.sum({ enemigo => enemigo.puntos() }) + salasCompletadas * 200
}

object partida {
    const registro = marcador

    method completarSala() {
        registro.completarSala()
        // por ahora la mazmorra tiene una sola sala
        self.ganar()
    }

    method ganar() {
        self.terminar("¡GANASTE!")
    }

    method perder() {
        self.terminar("GAME OVER")
    }

    method terminar(mensaje) {
        game.clear()
        game.addVisual(new Cartel(position = game.center(), text = mensaje + "   Puntaje: " + registro.puntaje().toString()))
    }
}

class Cartel {
    const property position
    const property text

    method textColor() = "FFFFFFFF"
}