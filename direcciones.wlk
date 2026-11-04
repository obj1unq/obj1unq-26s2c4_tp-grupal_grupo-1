
object tablero {
    const property direcciones = [arriba, abajo, izquierda, derecha]

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
        return position.x().between(0, game.width() - 1) and position.y().between(0, game.height() - 1)
    }

    method validarAtravesable(position) {
        if (not self.esAtravesable(position)) {
            self.error(position.toString() + " no es atravesable")
        }
    }

    method esAtravesable(position) {
        return game.getObjectsIn(position).all({ visual => visual.esAtravesable() })
    }

    method puedeIr(position) {
        return self.dentro(position) and self.esAtravesable(position)
    }

    method direccionesLibres(position) {
        return direcciones.filter({ dir => dir.puedeAvanzar(position) })
    }

    method hayDireccionLibre(position) {
        return not self.direccionesLibres(position).isEmpty()
    }

    method estaAlLado(origen, destino) {
        return direcciones.any({ dir => dir.posicionAlLado(origen) == destino })
    }

    method direccionHaciaVecino(origen, destino) {
        return direcciones.find({ dir => dir.posicionAlLado(origen) == destino })
    }

    method distancia(pos1, pos2) {
        const dx = pos1.x() - pos2.x()
        const dy = pos1.y() - pos2.y()
        return (dx * dx) + (dy * dy)
    }
}

class Direccion {
    method texto()
    method posicionAlLado(position)

    method siguiente(position) {
        const nueva = self.posicionAlLado(position)
        tablero.validar(nueva)
        return nueva
    }

    method puedeAvanzar(position) {
        return tablero.puedeIr(self.posicionAlLado(position))
    }
}

object arriba inherits Direccion {
    override method texto() = "arriba"
    override method posicionAlLado(position) = position.up(1)
}

object abajo inherits Direccion {
    override method texto() = "abajo"
    override method posicionAlLado(position) = position.down(1)
}

object derecha inherits Direccion {
    override method texto() = "derecha"
    override method posicionAlLado(position) = position.right(1)
}

object izquierda inherits Direccion {
    override method texto() = "izquierda"
    override method posicionAlLado(position) = position.left(1)
}