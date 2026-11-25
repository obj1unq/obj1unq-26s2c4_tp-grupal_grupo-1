object sonido {

    var musicaFondo = null

    method iniciarMusica() {
        self.detenerMusica()
        musicaFondo = game.sound("loop.mp3")
        musicaFondo.shouldLoop(true)
        musicaFondo.volume(0.3)
        musicaFondo.play()
    }

    method detenerMusica() {
        if (musicaFondo != null) {
            musicaFondo.stop()
            musicaFondo = null
        }
    }

    method reproducir(archivo) {
        game.sound(archivo).play()
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

    method gameOver() {
        self.reproducir("gameover.wav")
    }
}