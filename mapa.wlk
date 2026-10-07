
import direcciones.*
import link.*

object nivel{
    const jugador = link

    method configurarTeclas(){
        keyboard.left().onPressDo({ jugador.mover(izquierda)})
	    keyboard.right().onPressDo({ jugador.mover(derecha)})
	    keyboard.up().onPressDo({ jugador.mover(arriba)})
	    keyboard.down().onPressDo({ jugador.mover(abajo)})
    }
    
}