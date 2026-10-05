
object link {
	var property energia = 1000 //El getter y setter solo lo necesito para testear
	var position = game.at(0,1) // game.origin() 
	var estado = "normal"


	method image(){
		return "link-" + estado + ".png"
	}

	
	method position() { //metodo necesario para wollok game
		return position
	}

	method position(_position) { //el setter solo lo necesito para testear
		position = _position 
  }

}