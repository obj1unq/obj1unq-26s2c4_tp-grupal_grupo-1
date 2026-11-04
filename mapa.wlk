
import direcciones.*
import link.*
import objetos.*

// Símbolos para armar las salas
object p {  // pared
    method construirEn(posicion) {
        game.addVisual(new Pared(position = posicion))
    }
}

object o {  // piso
    method construirEn(posicion) {}
}

object j {  // inicio de Link
    const jugador = link

    method construirEn(posicion) {
        jugador.position(posicion)
    }
}

object l {  // llave
    method construirEn(posicion) {
        game.addVisual(new Llave(position = posicion))
    }
}

object v {  // vasija
    method construirEn(posicion) {
        game.addVisual(new Vasija(position = posicion))
    }
}

object e {  // puerta de entrada
    method construirEn(posicion) {
        game.addVisual(new Pared(position = posicion, image = "puerta-entrada.png"))
    }
}

object s {  // puerta de salida
    method construirEn(posicion) {
        game.addVisual(new PuertaConCandado(position = posicion))
    }
}

const sala1 = [
    [p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p],
    [p, l, o, p, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, p],
    [p, o, o, p, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, s],
    [p, p, v, p, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, p],
    [p, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, p],
    [p, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, p],
    [p, o, o, o, o, o, p, p, o, o, o, o, p, p, o, o, o, o, o, p],
    [p, o, o, o, o, o, p, p, o, o, o, o, p, p, o, o, o, o, o, p],
    [p, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, p],
    [p, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, p],
    [p, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, p],
    [p, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, p],
    [p, o, j, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, o, p],
    [p, p, e, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p]
]

object nivel{
    const jugador = link

    method configurarTeclas(){
        keyboard.left().onPressDo({ jugador.mover(izquierda)})
	    keyboard.right().onPressDo({ jugador.mover(derecha)})
	    keyboard.up().onPressDo({ jugador.mover(arriba)})
	    keyboard.down().onPressDo({ jugador.mover(abajo)})
        keyboard.z().onPressDo({ jugador.usarArma() })
    }

    method armar(filas) {
        const alto = filas.size()
        const indices = new Range(start = 0, end = alto - 1)
        // la primera fila de la lista es la de arriba de la pantalla
        indices.forEach({ i => self.armarFila(filas.get(i), alto - 1 - i) })
    }

    method armarFila(fila, y) {
        const columnas = new Range(start = 0, end = fila.size() - 1)
        columnas.forEach({ x => fila.get(x).construirEn(game.at(x, y)) })
    }
    
}