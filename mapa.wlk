import direcciones.*
import link.*
import objetos.*
import enemigos.*
import partida.*

object p {
    method construirEn(posicion) {
        game.addVisual(new Pared(position = posicion))
    }
}

object o {
    method construirEn(posicion) {}
}

object j {
    const jugador = link
    method construirEn(posicion) {
        jugador.position(posicion)
    }
}

object l {
    method construirEn(posicion) {
        game.addVisual(new Llave(position = posicion))
    }
}

object c {
    method construirEn(posicion) {
        game.addVisual(new Cofre(position = posicion, recompensa = new Llave()))
    }
}

object v {
    method construirEn(posicion) {
        game.addVisual(new Vasija(position = posicion))
    }
}

object e {
    method construirEn(posicion) {
        const lado = tablero.orientacionBorde(posicion)
        game.addVisual(new Pared(position = posicion, image = "puerta-entrada-" + lado.texto() + ".png"))
    }
}

object s {
    method construirEn(posicion) {
        game.addVisual(new PuertaConCandado(
            position = posicion,
            orientacion = tablero.orientacionBorde(posicion)
        ))
    }
}

object m {
    method construirEn(posicion) {
        spawner.spawnearEn(fabricanteMurcielago, posicion)
    }
}

object g {
    method construirEn(posicion) {
        spawner.spawnearEn(fabricanteSoldado, posicion)
    }
}

const sala1 = [
    [p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p],
    [p, l, o, p, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, p],
    [p, o, o, p, o, o, o, o, o, o, o, o, m, o, o, o, o, o, o, s],
    [p, p, v, p, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, p],
    [p, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, p],
    [p, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, p],
    [p, o, o, o, o, o, p, p, o, o, o, o, p, p, o, o, o, o, o, p],
    [p, o, o, o, o, o, p, p, o, o, o, o, p, p, o, o, o, o, o, p],
    [p, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, p],
    [p, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, g, o, o, p],
    [p, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, p],
    [p, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, p],
    [p, o, j, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, p],
    [p, p, e, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p]
]

const sala2 = [
    [p, p, p, p, p, p, p, p, p, s, p, p, p, p, p, p, p, p, p, p],
    [p, o, o, o, o, p, o, o, o, o, o, o, o, o, p, o, o, c, o, p],
    [p, o, o, o, o, p, o, o, o, o, o, o, o, o, p, o, o, o, o, p],
    [p, o, o, o, o, v, o, o, o, p, p, o, o, o, v, o, o, o, o, p],
    [p, o, o, o, o, p, o, o, o, p, p, o, o, o, p, p, p, p, p, p],
    [p, o, o, o, o, p, o, o, o, o, o, o, o, o, o, o, o, o, o, p],
    [p, p, v, p, p, p, o, o, o, o, o, o, o, o, o, o, o, o, o, p],
    [p, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, p],
    [p, o, o, o, o, o, o, o, p, p, p, p, o, o, o, o, o, o, o, p],
    [p, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, p],
    [p, o, o, o, p, p, o, o, o, o, o, o, o, o, p, p, o, o, o, p],
    [p, j, o, o, p, p, o, o, o, o, o, o, o, o, p, p, o, o, o, p],
    [p, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, p],
    [p, e, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p]
]

const sala3 = [
    [p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p],
    [p, c, v, o, o, o, o, o, o, p, p, o, o, o, o, o, o, o, o, p],
    [p, v, v, o, o, o, o, o, o, p, p, o, o, o, o, o, o, o, o, p],
    [p, o, o, o, o, p, p, o, o, o, o, o, o, p, p, o, o, o, o, p],
    [p, o, o, o, o, p, p, o, o, o, o, o, o, p, p, o, o, o, o, p],
    [p, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, p],
    [p, o, o, o, o, o, o, o, p, p, p, p, o, o, o, o, o, o, o, s],
    [p, o, o, o, o, o, o, o, p, p, p, p, o, o, o, o, o, o, o, p],
    [p, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, p],
    [p, o, o, o, o, p, p, o, o, o, o, o, o, p, p, o, o, o, o, p],
    [p, o, o, o, o, p, p, o, o, o, o, o, o, p, p, o, o, o, o, p],
    [p, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, p],
    [p, o, o, o, o, o, o, o, o, j, o, o, o, o, o, o, o, o, o, p],
    [p, p, p, p, p, p, p, p, p, e, p, p, p, p, p, p, p, p, p, p]
]

object randomizer {
    method position() {
        return game.at(
            (1 .. game.width() - 2).anyOne(),
            (1 .. game.height() - 3).anyOne()
        )
    }

    method emptyPosition() {
        const pos = self.position()
        if (game.getObjectsIn(pos).isEmpty() and pos != link.position() and not tablero.estaAlLado(pos, link.position())) {
            return pos
        } else {
            return self.emptyPosition()
        }
    }
}

object spawner {
    const enemigosActivos = #{}

    method spawnear(fabrica) {
        self.spawnearEn(fabrica, randomizer.emptyPosition())
    }

    method spawnearEn(fabrica, posicion) {
        const nuevo = fabrica.crear(posicion)
        game.addVisual(nuevo)
    }

    method spawnearVarios(fabrica, cantidad) {
        (1 .. cantidad).forEach({ _ => self.spawnear(fabrica) })
    }

    method spawnearEnRango(fabrica, min, max) {
        self.spawnearVarios(fabrica, (min .. max).anyOne())
    }

    method registrarEnemigo(enemigo) {
        enemigosActivos.add(enemigo)
    }

    method quitarEnemigo(enemigo) {
        enemigosActivos.remove(enemigo)
    }

    method detenerEnemigos() {
        enemigosActivos.forEach({ enemigo => enemigo.detenerMovimiento() })
        enemigosActivos.clear()
    }

    method redibujarPersonajes() {
        self.redibujar(link)
        enemigosActivos.forEach({ enemigo => self.redibujar(enemigo) })
    }

    method redibujar(visual) {
        if (game.hasVisual(visual)) {
            game.removeVisual(visual)
            game.addVisual(visual)
        }
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
        const soldado = new Soldado(position = position, recompensa = self.recompensaAlAzar())
        spawner.registrarEnemigo(soldado)
        return soldado
    }

    method recompensaAlAzar() {
        return [sinRecompensa, new Corazon()].anyOne()
    }
}

object fabricanteMurcielago {
    method crear(position) {
        const murcielago = new Murcielago(position = position)
        spawner.registrarEnemigo(murcielago)
        return murcielago
    }
}

object hud {
    const jugador = link
    const registro = marcador

    method position() = game.at(10, 14)

    method text() = "Corazones: " + jugador.corazones().toString() + "   Llave: " + self.textoLlave() + "   Puntaje: " + registro.puntaje().toString()

    method textoLlave() = if (jugador.tieneLlave()) "sí" else "no"

    method textColor() = "FFFFFFFF"

    method esAtravesable() = false
    method recibirAtaque(danio) {}
    method interactuarCon(personaje) {}
    method alChocarCon(personaje) {}
}

object nivel {
    const jugador = link

    method configurarTeclas() {
        keyboard.left().onPressDo({ jugador.mover(izquierda) })
        keyboard.right().onPressDo({ jugador.mover(derecha) })
        keyboard.up().onPressDo({ jugador.mover(arriba) })
        keyboard.down().onPressDo({ jugador.mover(abajo) })
        keyboard.z().onPressDo({ jugador.usarArma() })
        keyboard.space().onPressDo({ jugador.usarArma() })
        keyboard.e().onPressDo({ jugador.interactuar() })
    }

    method cargarSala(filas) {
        spawner.detenerEnemigos()
        game.clear()
        self.armar(filas)
        game.addVisual(jugador)
        self.poblarAlAzar()
        spawner.redibujarPersonajes()
        game.addVisual(hud)
        self.configurarTeclas()
    }

    method armar(filas) {
        const alto = filas.size()
        const indices = new Range(start = 0, end = alto - 1)
        indices.forEach({ i => self.armarFila(filas.get(i), alto - 1 - i) })
    }

    method armarFila(fila, y) {
        const columnas = new Range(start = 0, end = fila.size() - 1)
        columnas.forEach({ x => fila.get(x).construirEn(game.at(x, y)) })
    }

    method poblarAlAzar() {
        spawner.spawnearEnRango(fabricanteVasija, 3, 6)
        spawner.spawnearEnRango(fabricanteMurcielago, 1, 2)
        spawner.spawnearEnRango(fabricanteSoldado, 1, 2)
    }
}