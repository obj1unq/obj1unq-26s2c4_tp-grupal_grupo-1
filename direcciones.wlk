

object tablero {
    method validar(position) {
        self.validarDentro(position)
        self.validarAtravesable(position)
    }


    method validarDentro(position) {
        if (not self.dentro(position)) {
            self.error(position.toString() + " no está dentro del tablero ")
        }
    }

    method dentro(position) {
        return position.x().between(0, game.width() -1) and position.y().between(0, game.height() -1 )
    }

    method validarAtravesable(position) {
       if (not game.getObjectsIn(position).all({visual => visual.esAtravesable()})) { 
            self.error(position.toString() + " no es atravesable")
        }
    }
}

object arriba {
    method texto() = "arriba"
    
    method siguiente(position) {
        const nueva = position.up(1) 
        tablero.validar(nueva)
        return nueva
    }
}

object abajo {
    method texto() = "abajo"

    method siguiente(position) {
        const nueva = position.down(1) 
        tablero.validar(nueva)
        return nueva
    }
}

object derecha {
    method texto() = "derecha"
    
    method siguiente(position) {
        const nueva = position.right(1) 
        tablero.validar(nueva)
        return nueva
    }

}

object izquierda{
    method texto() = "izquierda"
    
    method siguiente(position) {
        const nueva = position.left(1) 
        tablero.validar(nueva)
        return nueva
    }
}
