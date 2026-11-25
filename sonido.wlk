object sonido {
    var musicaFondo = null
    var volumenGeneral = 0.5

    method subirVolumen() {
        volumenGeneral = (volumenGeneral + 0.1).min(1)
        self.actualizarVolumenMusica()
    }

    method bajarVolumen() {
        volumenGeneral = (volumenGeneral - 0.1).max(0)
        self.actualizarVolumenMusica()
    }

    method volumenMusica() {
        return volumenGeneral * 0.6
    }

    method actualizarVolumenMusica() {
        if (musicaFondo != null) {
            musicaFondo.volume(self.volumenMusica())
        }
    }

    method iniciarMusica() {
        self.detenerMusica()
        musicaFondo = game.sound("loop.mp3")
        musicaFondo.shouldLoop(true)
        musicaFondo.volume(self.volumenMusica())
        musicaFondo.play()
    }

    method detenerMusica() {
        if (musicaFondo != null) {
            musicaFondo.stop()
            musicaFondo = null
        }
    }

    method reproducir(archivo) {
        const efecto = game.sound(archivo)
        efecto.volume(volumenGeneral)
        efecto.play()
    }

    method espada() {
        self.reproducir("espada.wav")
    }

    method explosion() {
        self.reproducir("explosion.wav")
    }

    method item() {
        self.reproducir("item.wav")
    }

    method vasija() {
        self.reproducir("vasija.wav")
    }

    method danio() {
        self.reproducir("danio.wav")
    }

    method salaCompletada() {
        self.reproducir("sala.wav")
    }

    method victoria() {
        self.reproducir("victoria.wav")
    }

    method flecha() {
        self.reproducir("flecha.wav")
    }

    method gameOver() {
        self.reproducir("gameover.wav")
    }
}