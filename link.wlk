
import direcciones.*

object link {
    var position = game.at(0,1) 
    var estado = normal
    var direccionActual = abajo

    method image(){
        return "link-" + estado.forma() + "-" + direccionActual.texto() + ".png"
    }

    method position() { 
        return position
    }

    method positionTest(_position){
        position = _position
    }

    method mover(direccion) {
        direccionActual = direccion 

        if(estado.puedeMover()){        
            const nuevaPosition = direccion.siguiente(position) 
            position = nuevaPosition 
        }
    }

		method position(_position) { //el setter solo lo necesito para testear
		position = _position 
	}

}

object normal{
	method forma(){
		return "normal"
	}

	method puedeMover(){
		return true
	}

}
