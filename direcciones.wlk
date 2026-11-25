object tablero {
    const property direcciones = [arriba, abajo, izquierda, derecha]

    method validar(position) {
        self.validarDentro(position)
        self.validarAtravesable(position)
    }

    method validarDentro(position) {
        if (not self.dentro(position)) {
            self.error(position.toString() + " no está dentro del tablero")
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

    method estanAlineados(origen, destino) {
        return origen != destino and (origen.x() == destino.x() or origen.y() == destino.y())
    }

    method caminoDespejado(origen, destino) {
        const dir = self.direccionHacia(origen, destino)
        return self.pasosDespejadosDesde(dir.posicionAlLado(origen), destino, dir)
    }

    method pasosDespejadosDesde(actual, destino, dir) {
        return actual == destino or (self.puedeIr(actual) and self.pasosDespejadosDesde(dir.posicionAlLado(actual), destino, dir))
    }

    method direccionHacia(origen, destino) {
        const dx = destino.x() - origen.x()
        const dy = destino.y() - origen.y()
        return if (dx.abs() >= dy.abs()) {
            if (dx > 0) derecha else izquierda
        } else {
            if (dy > 0) arriba else abajo
        }
    }

    method distancia(pos1, pos2) {
        const dx = pos1.x() - pos2.x()
        const dy = pos1.y() - pos2.y()
        return (dx * dx) + (dy * dy)
    }

    method orientacionBorde(position) {
        return if (position.x() == 0) {
            izquierda
        } else if (position.x() == game.width() - 1) {
            derecha
        } else if (position.y() == 0) {
            abajo
        } else {
            arriba
        }
    }
}

class Direccion {
    method texto()
    method posicionAlLado(position)
    method sufijoEspalda() = ""

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
    override method sufijoEspalda() = "-espalda"
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