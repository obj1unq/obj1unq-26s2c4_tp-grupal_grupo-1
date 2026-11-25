import direcciones.*
import link.*
import objetos.*
import partida.*
import mapa.*

class Enemigo inherits Personaje {
    const property objetivo = link
    const registro = marcador
    var danioRecibido = 0
    var property recompensa = sinRecompensa
    var activo = false

    method initialize() {
        self.iniciarMovimiento()
    }

    method iniciarMovimiento() {
        game.onTick(self.intervalo(), self.nombreDelMovimiento(), { self.moverse() })
    }

    method detenerMovimiento() {
        game.removeTickEvent(self.nombreDelMovimiento())
    }

    method nombreDelMovimiento() = "moverse-" + self.identity().toString()

    override method alChocarCon(personaje) {
        self.tocarA(personaje)
    }

    method tocarA(personaje) {
        personaje.recibirAtaque(1)
    }

    method recibirAtaque(danio) {
        activo = true
        danioRecibido += danio
        if (self.estaVencido()) {
            self.morir()
        }
    }
    override method recibirExplosion(danio) {
        self.recibirAtaque(danio)
    }

    method estaVencido() = danioRecibido >= self.vida()

    method morir() {
        self.detenerMovimiento()
        spawner.quitarEnemigo(self)
        if (game.hasVisual(self)) {
            game.removeVisual(self)
        }
        registro.registrarVencido(self)
        recompensa.soltarEn(position)
    }

    method rangoActivacion() = 3

    method objetivoEnRangoDeActivacion() {
        return tablero.distancia(position, objetivo.position()) <= self.rangoActivacion() * self.rangoActivacion()
    }

    method moverse() {
        if (not activo and self.objetivoEnRangoDeActivacion()) {
            activo = true
        }
        if (activo and estado.puedeMover()) {
            if (self.puedeAtacar()) {
                direccionActual = tablero.direccionHacia(position, objetivo.position())
                self.atacar()
            } else {
                self.desplazarse()
            }
        }
    }

    method puedeAtacar() = armaEquipada.estaEnRango(position, objetivo.position())

    method atacar() {
        self.usarArma()
    }

    method desplazarse() {
        if (tablero.hayDireccionLibre(position)) {
            direccionActual = self.direccionElegida()
            position = direccionActual.posicionAlLado(position)
        }
    }

    method direccionElegida() {
        return self.direccionHaciaObjetivo()
    }

    method direccionHaciaObjetivo() {
        return tablero.direccionesLibres(position).min({ dir =>
            tablero.distancia(dir.posicionAlLado(position), objetivo.position())
        })
    }

    method vida()
    method puntos()
    method intervalo()
}

class Soldado inherits Enemigo {
    override method nombreImagen() = "soldado"
    override method vida() = 2
    override method puntos() = 100
    override method intervalo() = 700
}

class EnemigoADistancia inherits Enemigo {
    override method rangoActivacion() = 6

    override method direccionElegida() {
        return tablero.direccionesLibres(position).findOrElse(
            { dir => armaEquipada.estaEnRango(dir.posicionAlLado(position), objetivo.position()) },
            { self.direccionHaciaObjetivo() }
        )
    }
}

class Arquero inherits EnemigoADistancia {
    override method initialize() {
        armaEquipada = arco
        estado = self.estadoNormal()
        super()
    }

    override method nombreImagen() = "arquero"
    override method vida() = 2
    override method puntos() = 120
    override method intervalo() = 700
}

class Canionero inherits EnemigoADistancia {
    override method initialize() {
        armaEquipada = canion
        super()
    }

    override method nombreImagen() = "canionero"
    override method vida() = 3
    override method puntos() = 150
    override method intervalo() = 1000
}

class Murcielago inherits Enemigo {
    var modo = standbyMurcielago
    var frameActual = 1
    const rangoActivacion = 3

    override method nombreImagen() = "murcielago"
    override method image() = self.nombreImagen() + "-" + modo.sufijoImagen(self) + ".png"
    override method vida() = 1
    override method puntos() = 50
    override method intervalo() = 400
    override method esAtravesable() = modo.esAtravesable()
    override method detieneProyectil() = modo.puedeRecibirDanio()

    method frameActual() = frameActual

    override method moverse() {
        modo.actuar(self)
    }

    override method alChocarCon(personaje) {
        modo.alChocarCon(self, personaje)
    }

    override method recibirAtaque(danio) {
        if (modo.puedeRecibirDanio()) {
            super(danio)
        }
    }

    override method direccionElegida() {
        return self.direccionesDeVuelo().min({ dir =>
            tablero.distancia(dir.posicionAlLado(position), objetivo.position())
        })
    }

    override method morir() {
        modo = derrotadoMurcielago
        self.detenerMovimiento()
        spawner.quitarEnemigo(self)
        registro.registrarVencido(self)

        game.schedule(500, {
            if (game.hasVisual(self)) {
                game.removeVisual(self)
                recompensa.soltarEn(position)
            }
        })
    }

    method objetivoEnRango() {
        return tablero.distancia(position, objetivo.position()) <= rangoActivacion * rangoActivacion
    }

    method despertar() {
        modo = activoMurcielago
    }

    method perseguirOAtacar() {
        self.avanzarAleteo()
        if (position == objetivo.position()) {
            self.pasarDeLargo()
        } else {
            self.volarHaciaObjetivo()
        }
    }

    method volarHaciaObjetivo() {
        if (not self.direccionesDeVuelo().isEmpty()) {
            direccionActual = self.direccionElegida()
            position = direccionActual.posicionAlLado(position)
            if (position == objetivo.position()) {
                self.tocarA(objetivo)
            }
        }
    }

    method pasarDeLargo() {
        const siguientePos = direccionActual.posicionAlLado(position)
        if (tablero.puedeIr(siguientePos)) {
            position = siguientePos
        } else if (tablero.hayDireccionLibre(position)) {
            direccionActual = tablero.direccionesLibres(position).anyOne()
            position = direccionActual.posicionAlLado(position)
        }
    }

    method direccionesDeVuelo() {
        return tablero.direcciones().filter({ dir => self.puedeVolarA(dir.posicionAlLado(position)) })
    }

    method puedeVolarA(pos) {
        return tablero.puedeIr(pos) or pos == objetivo.position()
    }

    method avanzarAleteo() {
        frameActual = (frameActual % 4) + 1
    }
}

object standbyMurcielago {
    method sufijoImagen(murcielago) = "standby"
    method esAtravesable() = false
    method puedeRecibirDanio() = true

    method actuar(murcielago) {
        if (murcielago.objetivoEnRango()) {
            murcielago.despertar()
        }
    }

    method alChocarCon(murcielago, personaje) {
        murcielago.despertar()
        murcielago.tocarA(personaje)
    }
}

object activoMurcielago {
    method sufijoImagen(murcielago) = "aleteo-" + murcielago.frameActual().toString()
    method esAtravesable() = true
    method puedeRecibirDanio() = true

    method actuar(murcielago) {
        murcielago.perseguirOAtacar()
    }

    method alChocarCon(murcielago, personaje) {
        murcielago.tocarA(personaje)
    }
}

object derrotadoMurcielago {
    method sufijoImagen(murcielago) = "derrotado"
    method esAtravesable() = true
    method puedeRecibirDanio() = false

    method actuar(murcielago) {}
    method alChocarCon(murcielago, personaje) {}
}

class Estatua inherits ElementoEscenario {
    const direccion = abajo

    method initialize() {
        self.iniciarDisparos()
    }

    method image() {
        return "place_holder_rosa.png"
    }

    override method esAtravesable() {
        return false
    }

    override method recibirExplosion(danio) {}

    method iniciarDisparos() {
        game.onTick(2500, self.nombreTick(), { self.disparar() })
    }

    method detener() {
        game.removeTickEvent(self.nombreTick())
    }

    method nombreTick() {
        return "estatua-" + self.identity().toString()
    }

    method disparar() {
        const origen = direccion.posicionAlLado(position)
        if (tablero.dentro(origen)) {
            const proyectil = new Proyectil(position = origen, direccion = direccion)
            spawner.registrarTrampa(proyectil)
            game.addVisual(proyectil)
        }
    }
}

class Proyectil inherits ElementoEscenario {
    const direccion

    method initialize() {
        game.onTick(250, self.nombreTick(), { self.avanzar() })
    }

    method image() {
        return "place_holder_amarillo.png"
    }

    method nombreTick() {
        return "proyectil-" + self.identity().toString()
    }

    method detener() {
        game.removeTickEvent(self.nombreTick())
    }

    method avanzar() {
        const siguiente = direccion.posicionAlLado(position)
        if (siguiente == link.position()) {
            link.recibirAtaque(1)
            self.destruir()
        } else if (tablero.puedeIr(siguiente)) {
            position = siguiente
        } else {
            self.destruir()
        }
    }

    method destruir() {
        self.detener()
        spawner.quitarTrampa(self)
        if (game.hasVisual(self)) {
            game.removeVisual(self)
        }
    }
}

class Jefe inherits Enemigo {
    var turnos = 0

    override method nombreImagen() {
        return "jefe"
    }

    override method image() {
        return "place_holder_rosa.png"
    }

    override method vida() {
        return 6
    }

    override method puntos() {
        return 500
    }

    override method intervalo() {
        return 900
    }

    override method moverse() {
        if (estado.puedeMover()) {
            turnos += 1
            if (self.tocaAtaqueEnArea()) {
                self.atacarEnArea()
            } else {
                super()
            }
        }
    }

    method tocaAtaqueEnArea() {
        return turnos % 3 == 0
    }

    method atacarEnArea() {
        const vecinas = self.posicionesVecinasValidas()
        vecinas.forEach({ pos => self.golpearEn(pos) })
    }

    method posicionesVecinasValidas() {
        const vecinas = tablero.direcciones().map({ dir => dir.posicionAlLado(position) })
        return vecinas.filter({ pos => tablero.dentro(pos) })
    }

    method golpearEn(pos) {
        const golpe = new GolpeJefe(position = pos)
        game.addVisual(golpe)
        golpe.activar()
    }

    override method direccionElegida() {
        const libres = tablero.direccionesLibres(position)
        return libres.min({ dir => tablero.distancia(dir.posicionAlLado(position), objetivo.position()) })
    }

    override method morir() {
        super()
        partida.ganar()
    }
}

class GolpeJefe inherits ElementoEscenario {
    method image() {
        return "place_holder_amarillo.png"
    }

    method activar() {
        if (link.position() == position) {
            link.recibirAtaque(1)
        }
        game.schedule(300, {
            if (game.hasVisual(self)) {
                game.removeVisual(self)
            }
        })
    }
}