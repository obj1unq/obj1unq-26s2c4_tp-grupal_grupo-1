import link.*

class Llave{
    var property position
    method image() = "llave.png" //BUSCAR PNG
    method esAtravesable() = true
    
    method serAgarradaPor(personaje) {
    personaje.agarrarLlave()
    game.removeVisual(self)
  }

    method recibirAtaque(danio) {}

    method interactuarCon(personaje) {
        self.serAgarradaPor(personaje)
    }
  
}

class PuertaConCandado {
    var property position
    var estado = cerrada

    method image() = "puerta-" + estado.forma() + ".png"

    method esAtravesable() = estado.puedeMover()

    method recibirAtaque(danio) {}

    method interactuarCon(personaje) {
        if (not self.esAtravesable()) {
            self.abrirCon(personaje)
        }
    }

    method abrirCon(personaje) {
        self.validarLlave(personaje)
        personaje.usarLlave()
        estado = abierta
    }

    method validarLlave(personaje) {
        if (not personaje.tieneLlave()) {
            self.error("Necesitás una llave para abrir esta puerta")
        }
    }
}

const cerrada = new Estado(forma = "cerrada", puedeMover = false)
const abierta = new Estado(forma = "abierta", puedeMover = true)