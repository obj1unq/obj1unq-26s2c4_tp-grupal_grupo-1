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

    override method recibirAtaque(danio) {
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

    method detenerYDesregistrar() {
        self.detenerMovimiento()
        spawner.quitarEnemigo(self)
        registro.registrarVencido(self)
    }

    method morir() {
        self.detenerYDesregistrar()
        self.quitarDelTablero()
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
            self.actuarEnTurno()
        }
    }

    method actuarEnTurno() {
        if (self.puedeAtacar()) {
            direccionActual = tablero.direccionHacia(position, objetivo.position())
            self.atacar()
        } else {
            self.desplazarse()
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

    method direccionElegida() = self.direccionHaciaObjetivo()

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

    method puedeDispararDesde(origen) = armaEquipada.estaEnRango(origen, objetivo.position())

    override method direccionElegida() {
        return tablero.direccionesLibres(position).findOrElse(
            { dir => self.puedeDispararDesde(dir.posicionAlLado(position)) },
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

    override method nombreImagen() = "murcielago"
    override method sufijoImagen() = modo.sufijoImagen(self)
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
        self.detenerYDesregistrar()

        game.schedule(500, {
            if (game.hasVisual(self)) {
                self.quitarDelTablero()
                recompensa.soltarEn(position)
            }
        })
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
        if (murcielago.objetivoEnRangoDeActivacion()) {
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

    method image() = "estatua.png"
    override method esAtravesable() = false
    override method detieneProyectil() = false
    override method recibirExplosion(danio) {}

    method iniciarDisparos() {
        game.onTick(2500, self.nombreTick(), { self.disparar() })
    }

    method detener() {
        game.removeTickEvent(self.nombreTick())
    }

    method nombreTick() = "estatua-" + self.identity().toString()

    method disparar() {
        new Flecha(position = position, direccion = direccion).lanzar()
    }
}

class TridenteArrojado inherits Proyectil {
    const orientaciones = [arriba, derecha, abajo, izquierda]
    var indiceFrame = 0

    override method image() = "tridente-" + orientaciones.get(indiceFrame).texto() + ".png"
    override method danio() = 2
    override method intervalo() = 140

    override method avanzar() {
        indiceFrame = (indiceFrame + 1) % orientaciones.size()
        super()
    }
}

class FuegoJefe inherits ElementoEscenario {
    var frame = 1

    method image() = "fuego-" + frame.toString() + ".png"

    method cambiarFrame(numero) {
        frame = numero
    }

    override method alChocarCon(personaje) {
        personaje.recibirAtaque(1)
    }
}

class OleadaDeFuego {
    const posiciones
    const objetivo
    const fuegos = []

    method iniciar() {
        posiciones.forEach({ pos =>
            const fuego = new FuegoJefe(position = pos)
            fuegos.add(fuego)
            game.addVisual(fuego)
        })
        self.danarSiEstaObjetivo()
        game.schedule(150, { self.avanzarFrame(2) })
        game.schedule(300, { self.avanzarFrame(3) })
        game.schedule(450, { self.avanzarFrame(4) })
        game.schedule(600, { self.apagar() })
    }

    method sigueActiva() = not fuegos.isEmpty() and game.hasVisual(fuegos.first())

    method avanzarFrame(numero) {
        if (self.sigueActiva()) {
            fuegos.forEach({ fuego => fuego.cambiarFrame(numero) })
            self.danarSiEstaObjetivo()
        }
    }

    method danarSiEstaObjetivo() {
        if (posiciones.any({ pos => pos == objetivo.position() })) {
            objetivo.recibirAtaque(1)
        }
    }

    method apagar() {
        fuegos.forEach({ fuego => fuego.quitarDelTablero() })
        fuegos.clear()
    }
}

class Jefe inherits EnemigoADistancia {
    var modo = activoJefe
    var yaSeRegenero = false

    override method nombreImagen() = "jefe"
    override method sufijoImagen() = modo.sufijoImagen(self)
    override method sufijoOrientacion() = direccionActual.sufijoEspalda()
    override method vida() = 10
    override method puntos() = 500
    override method intervalo() = 850

    override method actuarEnTurno() {
        modo.actuar(self)
    }

    override method recibirAtaque(danio) {
        if (modo.puedeRecibirDanio()) {
            super(danio)
            if (not self.estaVencido() and not yaSeRegenero and danioRecibido >= self.vida() / 2) {
                self.iniciarRegeneracion()
            }
        }
    }

    method programarSiSigueVivo(tiempo, accion) {
        game.schedule(tiempo, {
            if (game.hasVisual(self)) {
                accion.apply()
            }
        })
    }

    method iniciarRegeneracion() {
        yaSeRegenero = true
        modo = regenerandoJefe
        self.programarSiSigueVivo(3000, {
            danioRecibido = (danioRecibido - 4).max(0)
            modo = activoJefe
        })
    }

    method ejecutarTurno() {
        direccionActual = tablero.direccionHacia(position, objetivo.position())
        if (self.objetivoCerca()) {
            self.iniciarAtaqueEnArea()
        } else if (self.puedeDispararDesde(position)) {
            self.iniciarLanzamientoTridente()
        } else {
            self.desplazarse()
        }
    }

    method objetivoCerca() = tablero.distancia(position, objetivo.position()) <= 4

    override method puedeDispararDesde(origen) {
        return tablero.estanAlineados(origen, objetivo.position())
            and tablero.caminoDespejado(origen, objetivo.position())
    }

    method iniciarLanzamientoTridente() {
        modo = preparandoTridenteJefe
        self.programarSiSigueVivo(180, { modo.siguienteFase(self) })
    }

    method dispararTridente() {
        modo = tridenteDisparadoJefe
        const posInicial = direccionActual.posicionAlLado(position)
        if (tablero.dentro(posInicial)) {
            new TridenteArrojado(position = posInicial, direccion = direccionActual).lanzar()
        }
        self.programarSiSigueVivo(350, { modo.terminarAccion(self) })
    }

    method iniciarAtaqueEnArea() {
        modo = atacandoArea1Jefe
        self.programarSiSigueVivo(220, { modo.siguienteFase(self) })
    }

    method invocarFuego() {
        modo = atacandoArea2Jefe
        new OleadaDeFuego(
            posiciones = self.posicionesDeFuego(),
            objetivo = objetivo
        ).iniciar()
        self.programarSiSigueVivo(450, { modo.terminarAccion(self) })
    }

    method posicionesDeFuego() {
        const offsets = [-2, -1, 0, 1, 2]
        const candidatas = offsets.flatMap({ dx =>
            offsets.map({ dy => game.at(position.x() + dx, position.y() + dy) })
        })
        return candidatas.filter({ pos =>
            tablero.distancia(position, pos).between(1, 4)
            and tablero.dentro(pos)
            and (tablero.esAtravesable(pos) or pos == objetivo.position())
        })
    }

    method volverAActivo() {
        modo = activoJefe
    }

    override method morir() {
        super()
        partida.ganar()
    }
}

class ModoJefe {
    method forma()
    method sufijoImagen(jefe) = self.forma() + jefe.sufijoOrientacion()
    method puedeRecibirDanio() = true
    method actuar(jefe) {}
    method siguienteFase(jefe) {}
    method terminarAccion(jefe) {}
}

object activoJefe inherits ModoJefe {
    override method forma() = "normal"
    override method actuar(jefe) { jefe.ejecutarTurno() }
}

object preparandoTridenteJefe inherits ModoJefe {
    override method forma() = "tridente"
    override method siguienteFase(jefe) { jefe.dispararTridente() }
}

object tridenteDisparadoJefe inherits ModoJefe {
    override method forma() = "tridente-disparado"
    override method terminarAccion(jefe) { jefe.volverAActivo() }
}

object atacandoArea1Jefe inherits ModoJefe {
    override method forma() = "ataque-area-1"
    override method siguienteFase(jefe) { jefe.invocarFuego() }
}

object atacandoArea2Jefe inherits ModoJefe {
    override method forma() = "ataque-area-2"
    override method terminarAccion(jefe) { jefe.volverAActivo() }
}

object regenerandoJefe inherits ModoJefe {
    override method forma() = "regeneracion"
    override method sufijoImagen(jefe) = self.forma()
    override method puedeRecibirDanio() = false
}