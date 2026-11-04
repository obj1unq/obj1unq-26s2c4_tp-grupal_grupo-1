
import direcciones.*
import partida.*

object link {
    var position = game.at(0,1) 
    var property estado = normal
    var property direccionActual = abajo
    var property armaEquipada = espada
    var property tieneLlave = false
    var corazones = 3
    var invulnerable = false
    const juego = partida
    method image(){
        return "link-" + estado.forma() + "-" + direccionActual.texto() + ".png"
    }

    method position() { 
        return position
    }


    method mover(direccion) {
        direccionActual = direccion 

        if(estado.puedeMover()){        
            self.interactuarConObjetosEn(direccion.posicionAlLado(position))
            const nuevaPosition = direccion.siguiente(position) 
            position = nuevaPosition 
        }
    }

    method interactuarConObjetosEn(destino) {
        game.getObjectsIn(destino).forEach({ objeto => objeto.interactuarCon(self) })
    }

    method usarArma() {
        if (estado.puedeMover()) {
            armaEquipada.usar(self)
        }
    }

		method position(_position) {
		position = _position 
	}

    method agarrarLlave() {
    tieneLlave = true
  }

    method usarLlave() {
        tieneLlave = false
    }

    method esAtravesable() = false

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

    method corazones() = corazones

    method sinCorazones() = corazones == 0

    method interactuarCon(personaje) {}

}

class Estado {
    const property forma
    const property puedeMover
}

const normal = new Estado(forma = "normal", puedeMover = true)
const ataque = new Estado(forma = "ataque", puedeMover = false)


object espada {

    const property danio = 1

    method usar(personaje) {
        personaje.estado(ataque)
        const posObjetivo = personaje.direccionActual().posicionAlLado(personaje.position())
        
        game.addVisual(new GolpeDeEspada(
            position = posObjetivo, 
            direccion = personaje.direccionActual(),
            danioGolpe = self.danio()
        ))
        
        game.schedule(500, { personaje.estado(normal) })
    }
}

class GolpeDeEspada {
    var property position
    const direccion 
    const danioGolpe
    
    method image() = "estocada-" + direccion.texto() + ".png"
    
    method initialize() {
        game.onCollideDo(self, { objeto => 
            objeto.recibirAtaque(danioGolpe) 
        })
        
        game.schedule(150, { game.removeVisual(self) })
    }

    method esAtravesable() = true

    method recibirAtaque(danio) {}

    method interactuarCon(personaje) {}
}

class Vasija {
    var property position
    var property estado = sana

    method image() = "vasija-" + estado.forma() + ".png"

    method recibirAtaque(danio) {
        estado = rota
    }

    method esAtravesable() = estado.puedeMover()

    method interactuarCon(personaje) {}
}

const rota = new Estado(forma = "rota", puedeMover = true)
const sana = new Estado(forma = "sana", puedeMover = false)