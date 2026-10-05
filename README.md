# La mazmorra de Link
_(Git Grupal: https://docs.google.com/presentation/d/1-o5zEUfuUT72ea8q2rk8mwHSqMkdJvTyQ9Y8eqUTVZA/edit?usp=sharing)_

## Equipo de desarrollo

- Leonardo Perez
- Facundo Gonzalo Vega

## Capturas

<p>
  <img src="assets/captura-sala1.png" width="250" height="250" style="object-fit: cover">
  <img src="assets/captura-jefe.png" width="250" height="250" style="object-fit: cover">
  <img src="assets/captura-gameover.png" width="250" height="250" style="object-fit: cover">
</p>


## Gameplay

_(video corto del juego nuestro cuando esté andando)_

## Reglas de Juego / Instrucciones

**Objetivo:** recorrer una mazmorra de 4 salas vista desde arriba, juntar los ítems que abren el camino, vencer a los enemigos y derrotar al jefe de la última sala. Perdés si te quedás sin corazones.

**Mazmorra**
- Cada sala es una grilla de 10×8 con paredes, una puerta de entrada y una de salida.
- Las puertas de salida están cerradas: algunas se abren con llave, otras con bomba, la del jefe se abre al vencer a todos los enemigos de la sala.
- Los enemigos se mueven solos; si tocan a Link le sacan un corazón.

**Controles**
- `←` `→` `↑` `↓`: mover a Link.
- `Espacio`: atacar con la espada a la celda de adelante.
- `B`: usar el ítem seleccionado (bomba, poción).
- `1` / `2`: elegir ítem.

**Enemigos**
- **Soldado:** te persigue. Cae con 2 golpes de espada.
- **Murciélago:** se mueve al azar y rápido. 1 golpe.
- **Estatua:** no se mueve, dispara en línea recta cada tanto. No se puede destruir; hay que esquivarla.
- **Jefe:** 6 golpes, te persigue y cada 3 turnos hace un ataque que ocupa las celdas vecinas.

**Ítems** (se agarran pasando por encima o abriendo cofres)
- **Llave:** abre una puerta con candado.
- **Bomba:** rompe una pared agrietada o le hace 3 de daño a lo que esté al lado.
- **Corazón:** recupera un corazón al instante.
- **Poción:** te hace invencible por unos turnos.

**Vida y puntos**
- Link tiene 3 corazones (máximo 5).
- Cada enemigo vencido suma puntos según el tipo; cada sala completada suma 200.

**Fin del juego**
- Sin corazones: GAME OVER. Al derrotar al jefe: pantalla de victoria con el puntaje.

**Inspiración:** las mazmorras de *The Legend of Zelda: A Link to the Past* (Nintendo, SNES, 1991), en versión chiquita. Los gráficos serán propios / libres.

### Posibles extensiones

Más salas, escudo que bloquea los disparos de las estatuas, mapa de la mazmorra, sonidos, ranking de puntajes.

## Otros

- UNQ Objetos 1 C4
- Wollok-TS-CLI v1.1.0
  Wollok-TS v4.3.0
  Wollok-Lang v4.0.0
- Una vez terminado, no tenemos problemas en que el repositorio sea público.
