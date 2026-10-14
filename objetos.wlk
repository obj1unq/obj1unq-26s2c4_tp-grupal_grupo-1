import link.*

class Llave{
    var property position
    method image() = "llave.png" //BUSCAR PNG
    method esAtravesable() = true
    
    method serAgarradaPor(personaje) {
    personaje.agarrarLlave()
    game.removeVisual(self)
  }
  
}