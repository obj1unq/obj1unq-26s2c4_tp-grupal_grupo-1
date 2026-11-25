import direcciones.*
import partida.*
import mapa.*

class Personaje {
    var property position = game.at(0, 0)
    var property estado = normal
    var property direccionActual = abajo
    var property armaEquipada = espada

    method image() {
        return self.nombreImagen() + "-" + estado.forma() + "-" + direccionActual.texto() + ".png"
    }

    method nombreImagen()
    method estadoNormal() = armaEquipada.estadoNormal()
    method estadoPreparando() = armaEquipada.estadoPreparando()
    method estadoDisparando() = armaEquipada.estadoDisparando()

    method esAtravesable() = false
    method detieneProyectil() = true

    method usarArma() {
        if (estado.puedeMover()) {
            armaEquipada.usar(self)
        }
    }

    method interactuarCon(personaje) {}
    method alChocarCon(personaje) {}
}
object link inherits Personaje(position = game.at(0, 1)) {
    var tieneLlave = false
    var corazones = 3
    var invulnerable = false
    const juego = partida

    override method nombreImagen() = "link"
    override method estadoNormal() = armaEquipada.estadoNormal()
    override method estadoPreparando() = armaEquipada.estadoPreparando()
    override method estadoDisparando() = armaEquipada.estadoDisparando()

    method tieneLlave() = tieneLlave
    method corazones() = corazones
    method invulnerable() = invulnerable

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

    method agarrarLlave() {
        tieneLlave = true
    }

    method usarLlave() {
        tieneLlave = false
    }

    method curar(cantidad) {
        corazones = (corazones + cantidad).min(5)
    }

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

    method sinCorazones() = corazones == 0

    method reiniciar() {
        estado = normal
        direccionActual = abajo
        armaEquipada = espada
        tieneLlave = false
        corazones = 3
        invulnerable = false
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

object espada {
    const property danio = 1

    method nombre() = "Espada"
    method estadoNormal() = normal
    method estadoPreparando() = ataque
    method estadoDisparando() = ataque

    method estaEnRango(origen, destino) = tablero.estaAlLado(origen, destino)

    method usar(personaje) {
        personaje.estado(personaje.estadoDisparando())
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

        game.schedule(500, { personaje.estado(personaje.estadoNormal()) })
    }
}

class ArmaADistancia {
    method nombre()
    method alcance()
    method duracionAtaque()
    method estadoNormal() = normal
    method estadoPreparando() = ataque
    method estadoDisparando() = ataque
    method crearProyectil(posicion, direccion)

    method estaEnRango(origen, destino) {
        return tablero.estanAlineados(origen, destino)
            and tablero.distancia(origen, destino) <= self.alcance() * self.alcance()
            and tablero.caminoDespejado(origen, destino)
    }

    method usar(personaje) {
        personaje.estado(personaje.estadoPreparando())
        self.ejecutarDisparo(personaje)
    }

    method ejecutarDisparo(personaje) {
        self.disparar(personaje)
        game.schedule(self.duracionAtaque(), { personaje.estado(personaje.estadoNormal()) })
    }

    method disparar(personaje) {
        personaje.estado(personaje.estadoDisparando())
        const dir = personaje.direccionActual()
        const posInicial = dir.posicionAlLado(personaje.position())
        if (tablero.dentro(posInicial)) {
            self.crearProyectil(posInicial, dir).lanzar()
        }
    }
}

object arco inherits ArmaADistancia {
    override method nombre() = "Arco"
    override method alcance() = 8
    override method duracionAtaque() = 200
    override method estadoNormal() = arcoNormal
    override method estadoPreparando() = arcoTensando
    override method estadoDisparando() = arcoDisparado
    override method crearProyectil(posicion, direccion) = new Flecha(position = posicion, direccion = direccion)

    override method ejecutarDisparo(personaje) {
        game.schedule(150, {
            if (game.hasVisual(personaje)) {
                self.disparar(personaje)
                game.schedule(self.duracionAtaque(), { personaje.estado(personaje.estadoNormal()) })
            }
        })
    }
}

object canion inherits ArmaADistancia {
    override method nombre() = "Cañón"
    override method alcance() = 7
    override method duracionAtaque() = 900
    override method crearProyectil(posicion, direccion) = new BalaDeCanion(position = posicion, direccion = direccion)
}

class GolpeDeEspada {
    var property position
    const direccion
    const danioGolpe

    method image() = "estocada-" + direccion.texto() + ".png"

    method activar() {
        game.getObjectsIn(position).forEach({ objeto =>
            if (objeto != self) {
                objeto.recibirAtaque(danioGolpe)
            }
        })
        game.schedule(150, {
            if (game.hasVisual(self)) {
                game.removeVisual(self)
            }
        })
    }

    method esAtravesable() = true
    method detieneProyectil() = false
    method recibirAtaque(danio) {}
    method interactuarCon(personaje) {}
    method alChocarCon(personaje) {}
}

class Proyectil {
    var property position
    const direccion
    var activo = true
    var enMovimiento = false

    method image()
    method danio()
    method intervalo()
    method efectoAlImpactar()

    method esAtravesable() = true
    method detieneProyectil() = false
    method recibirAtaque(danio) {}
    method interactuarCon(personaje) {}

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
            self.danarObjetosEn(position)
            self.finalizarImpacto()
        }
    }

    method danarObjetosEn(pos) {
        game.getObjectsIn(pos).forEach({ objeto =>
            if (objeto != self) {
                objeto.recibirAtaque(self.danio())
            }
        })
    }

    method alChocarCon(personaje) {
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

    method desaparecer() {
        if (game.hasVisual(self)) {
            game.removeVisual(self)
        }
    }
}

class Flecha inherits Proyectil {
    override method image() = "flecha-" + direccion.texto() + ".png"
    override method danio() = 1
    override method intervalo() = 120

    override method efectoAlImpactar() {
        self.desaparecer()
    }
}

class BalaDeCanion inherits Proyectil {
    var imagenActual = "bala-canion.png"

    override method image() = imagenActual
    override method danio() = 2
    override method intervalo() = 250

    override method efectoAlImpactar() {
        imagenActual = "bala-explosion.png"
        spawner.redibujar(self)
        game.schedule(180, { self.mostrarHumo() })
    }

    method mostrarHumo() {
        if (game.hasVisual(self)) {
            imagenActual = "bala-humo.png"
            game.schedule(180, { self.desaparecer() })
        }
    }
}