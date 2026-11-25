import direcciones.*
import partida.*
import mapa.*
import objetos.*
import sonido.*

class Personaje inherits ElementoEscenario {
    var property estado = normal
    var property direccionActual = abajo
    var property armaEquipada = espada

    method image() = self.nombreImagen() + "-" + self.sufijoImagen() + ".png"
    method nombreImagen()
    method sufijoImagen() = estado.forma() + self.sufijoOrientacion()
    method sufijoOrientacion() = "-" + direccionActual.texto()

    method estadoNormal() = armaEquipada.estadoNormal()

    override method esAtravesable() = false
    override method recibirExplosion(danio) {}

    method puedeDispararArco() = true
    method consumirFlecha() {}
    method agregarFlechas(cantidad) {}

    method usarArma() {
        if (estado.puedeMover()) {
            armaEquipada.usar(self)
        }
    }
}

object link inherits Personaje(position = game.at(0, 1)) {
    var tieneLlave = false
    var corazones = 3
    var invulnerable = false
    var flechas = 10
    var bombas = 0
    var pociones = 0
    var itemSeleccionado = itemBomba

    const juego = partida

    override method nombreImagen() = "link"

    method flechas() = flechas
    method tieneFlechas() = flechas > 0
    override method puedeDispararArco() = self.tieneFlechas()

    override method consumirFlecha() {
        flechas = (flechas - 1).max(0)
    }

    override method agregarFlechas(cantidad) {
        flechas += cantidad
    }

    method bombas() = bombas
    method pociones() = pociones
    method nombreItemSeleccionado() = itemSeleccionado.nombre()
    method tieneLlave() = tieneLlave
    method corazones() = corazones
    method invulnerable() = invulnerable
    method sinCorazones() = corazones == 0

    method agarrarBomba() { bombas += 1 }
    method agarrarPocion() { pociones += 1 }
    method seleccionarBomba() { itemSeleccionado = itemBomba }
    method seleccionarPocion() { itemSeleccionado = itemPocion }
    method agarrarLlave() { tieneLlave = true }
    method usarLlave() { tieneLlave = false }

    method usarItemSeleccionado() {
        if (estado.puedeMover()) {
            itemSeleccionado.usar(self)
        }
    }

    method usarBomba() {
        if (bombas > 0) {
            bombas -= 1
            self.colocarBomba()
        }
    }

    method colocarBomba() {
        const bomba = new BombaActiva(position = position)
        game.addVisual(bomba)
        bomba.activar()
    }

    method usarPocion() {
        if (pociones > 0) {
            pociones -= 1
            self.activarInvulnerabilidad(5000)
        }
    }

    method activarInvulnerabilidad(duracion) {
        invulnerable = true
        game.schedule(duracion, { self.volverAVulnerable() })
    }

    method volverAVulnerable() {
        invulnerable = false
    }

    method equipar(arma) {
        if (estado.puedeMover()) {
            armaEquipada = arma
            estado = self.estadoNormal()
        }
    }

    method mover(direccion) {
        direccionActual = direccion
        if (estado.puedeMover()) {
            const posicionAnterior = position
            self.chocarConObjetosEn(direccion.posicionAlLado(position))
            if (position == posicionAnterior and not self.sinCorazones()) {
                position = direccion.siguiente(position)
            }
        }
    }

    method chocarConObjetosEn(destino) {
        if (tablero.dentro(destino)) {
            game.getObjectsIn(destino).forEach({ objeto => objeto.alChocarCon(self) })
        }
    }

    method interactuar() {
        if (estado.puedeMover()) {
            const destino = direccionActual.posicionAlLado(position)
            if (tablero.dentro(destino)) {
                game.getObjectsIn(destino).forEach({ objeto => objeto.interactuarCon(self) })
            }
        }
    }

    method curar(cantidad) {
        corazones = (corazones + cantidad).min(5)
    }

    override method recibirAtaque(danio) {
        if (not invulnerable) {
            self.perderCorazones(danio)
        }
    }

    method perderCorazones(danio) {
        sonido.danio()
        corazones = (corazones - danio).max(0)
        self.activarInvulnerabilidad(1000)
        if (self.sinCorazones()) {
            juego.perder()
        }
    }

    method reiniciar() {
        estado = normal
        direccionActual = abajo
        armaEquipada = espada
        tieneLlave = false
        corazones = 3
        invulnerable = false
        flechas = 10
        bombas = 0
        pociones = 0
        itemSeleccionado = itemBomba
        arco.reiniciar()
    }
}

class Estado {
    const property forma
    const property puedeMover
}

const normal = new Estado(forma = "normal", puedeMover = true)
const ataque = new Estado(forma = "ataque", puedeMover = false)
const arcoNormal = new Estado(forma = "arco-normal", puedeMover = true)
const arcoTensando = new Estado(forma = "arco-tensando", puedeMover = false)
const arcoDisparado = new Estado(forma = "arco-disparado", puedeMover = false)

class Arma {
    method nombre()
    method duracionAtaque()
    method estadoNormal() = normal
    method estadoPreparando() = ataque
    method estadoDisparando() = ataque
    method estaEnRango(origen, destino)
    method usar(personaje)

    method programarVueltaANormal(personaje) {
        game.schedule(self.duracionAtaque(), {
            personaje.estado(personaje.estadoNormal())
        })
    }
}

object espada inherits Arma {
    const property danio = 1

    override method nombre() = "Espada"
    override method duracionAtaque() = 500
    override method estaEnRango(origen, destino) = tablero.estaAlLado(origen, destino)

    override method usar(personaje) {
        sonido.espada()
        personaje.estado(self.estadoDisparando())
        const posObjetivo = personaje.direccionActual().posicionAlLado(personaje.position())

        if (tablero.dentro(posObjetivo)) {
            const golpe = new GolpeDeEspada(
                position = posObjetivo,
                direccion = personaje.direccionActual(),
                danioGolpe = self.danio()
            )
            game.addVisual(golpe)
            golpe.activar()
        }

        self.programarVueltaANormal(personaje)
    }
}

class ArmaADistancia inherits Arma {
    method alcance()
    method crearProyectil(posicion, direccion)

    override method estaEnRango(origen, destino) {
        return tablero.estanAlineados(origen, destino)
            and tablero.distancia(origen, destino) <= self.alcance() * self.alcance()
            and tablero.caminoDespejado(origen, destino)
    }

    override method usar(personaje) {
        personaje.estado(self.estadoPreparando())
        self.ejecutarDisparo(personaje)
    }

    method ejecutarDisparo(personaje) {
        self.disparar(personaje)
        self.programarVueltaANormal(personaje)
    }

    method disparar(personaje) {
        personaje.estado(self.estadoDisparando())
        const dir = personaje.direccionActual()
        const posInicial = dir.posicionAlLado(personaje.position())
        if (tablero.dentro(posInicial)) {
            self.crearProyectil(posInicial, dir).lanzar()
        }
    }
}

object arco inherits ArmaADistancia {
    var puedeDisparar = true
    const cooldownMs = 900

    override method nombre() = "Arco"
    override method alcance() = 8
    override method duracionAtaque() = 200
    override method estadoNormal() = arcoNormal
    override method estadoPreparando() = arcoTensando
    override method estadoDisparando() = arcoDisparado
    override method crearProyectil(posicion, direccion) = new Flecha(position = posicion, direccion = direccion)

    method puedeUsar(personaje) = puedeDisparar and personaje.puedeDispararArco()

    override method usar(personaje) {
        if (self.puedeUsar(personaje)) {
            personaje.consumirFlecha()
            self.iniciarCooldown()
            super(personaje)
        }
    }

    method iniciarCooldown() {
        puedeDisparar = false
        game.schedule(cooldownMs, { puedeDisparar = true })
    }

    override method ejecutarDisparo(personaje) {
        game.schedule(150, {
            if (game.hasVisual(personaje)) {
                self.disparar(personaje)
                self.programarVueltaANormal(personaje)
            }
        })
    }

    method reiniciar() {
        puedeDisparar = true
    }
}

object canion inherits ArmaADistancia {
    override method nombre() = "Cañón"
    override method alcance() = 7
    override method duracionAtaque() = 900
    override method crearProyectil(posicion, direccion) = new BalaDeCanion(position = posicion, direccion = direccion)
}

class GolpeDeEspada inherits ElementoEscenario {
    const direccion
    const danioGolpe

    method image() = "estocada-" + direccion.texto() + ".png"

    method activar() {
        self.otrosObjetosEn(position).forEach({ objeto => objeto.recibirAtaque(danioGolpe) })
        game.schedule(80, { self.quitarDelTablero() })
    }
}

class Proyectil inherits ElementoEscenario {
    const direccion
    var activo = true
    var enMovimiento = false

    method image()
    method danio()
    method intervalo()

    method nombreDelMovimiento() = "proyectil-" + self.identity().toString()

    method lanzar() {
        spawner.registrarProyectil(self)
        game.addVisual(self)
        if (self.hayImpactoEn(position)) {
            self.impactar()
        } else {
            self.iniciarMovimiento()
        }
    }

    method iniciarMovimiento() {
        enMovimiento = true
        game.onTick(self.intervalo(), self.nombreDelMovimiento(), { self.avanzar() })
    }

    method detener() {
        if (enMovimiento) {
            enMovimiento = false
            game.removeTickEvent(self.nombreDelMovimiento())
        }
    }

    method avanzar() {
        if (activo) {
            const siguiente = direccion.posicionAlLado(position)
            if (not tablero.dentro(siguiente)) {
                self.finalizarImpacto()
            } else if (self.hayImpactoEn(siguiente)) {
                position = siguiente
                self.impactar()
            } else {
                position = siguiente
            }
        }
    }

    method hayImpactoEn(pos) {
        return game.getObjectsIn(pos).any({ objeto => objeto.detieneProyectil() })
    }

    method impactar() {
        if (activo) {
            self.otrosObjetosEn(position).forEach({ objeto => objeto.recibirAtaque(self.danio()) })
            self.finalizarImpacto()
        }
    }

    override method alChocarCon(personaje) {
        if (activo) {
            personaje.recibirAtaque(self.danio())
            self.finalizarImpacto()
        }
    }

    method finalizarImpacto() {
        activo = false
        self.detener()
        spawner.quitarProyectil(self)
        self.efectoAlImpactar()
    }

    method efectoAlImpactar() {
        self.quitarDelTablero()
    }

}

class Flecha inherits Proyectil {
    override method image() = "flecha-" + direccion.texto() + ".png"
    override method danio() = 1
    override method intervalo() = 120

    override method lanzar() {
        sonido.flecha()
        super()
    }

    override method efectoAlImpactar() {
        self.quitarDelTablero()
    }
}

class BalaDeCanion inherits Proyectil {
    var imagenActual = "bala-canion.png"

    override method image() = imagenActual
    override method danio() = 2
    override method intervalo() = 250

    override method efectoAlImpactar() {
        sonido.explosion()
        imagenActual = "bala-explosion.png"
        spawner.redibujar(self)
        game.schedule(180, { self.mostrarHumo() })
    }

    method mostrarHumo() {
        if (game.hasVisual(self)) {
            imagenActual = "bala-humo.png"
            game.schedule(180, { self.quitarDelTablero() })
        }
    }
}

object itemBomba {
    method nombre() = "Bomba"

    method usar(personaje) {
        personaje.usarBomba()
    }
}

object itemPocion {
    method nombre() = "Pocion"

    method usar(personaje) {
        personaje.usarPocion()
    }
}