# La mazmorra de Link
_(Git Grupal: https://docs.google.com/presentation/d/1-o5zEUfuUT72ea8q2rk8mwHSqMkdJvTyQ9Y8eqUTVZA/edit?usp=sharing)_

## Equipo de desarrollo

- Leonardo Perez
- Facundo Vega

## Capturas

_(agregar capturas del juego)_

## Gameplay

_(video corto del juego andando)_

## Reglas de Juego / Instrucciones

**Objetivo:** recorrer una mazmorra de 4 salas vista desde arriba, juntar los ítems que abren el camino, vencer a los enemigos y derrotar al jefe de la última sala. Perdés si te quedás sin corazones.

**Mazmorra**
- Cada sala es una grilla de 20×14 con paredes, una puerta de entrada y una salida. Arriba hay una fila con los corazones, flechas, llave, ítems y puntaje.
- Las salidas están cerradas: algunas se abren con llave, otras volando una pared agrietada con una bomba, y la puerta hacia el jefe se abre al vencer a todos los enemigos de la sala.
- Las estatuas disparan flechas periódicamente hacia abajo.
- Las vasijas bloquean el paso, se rompen con ataques o explosiones y pueden soltar recompensas al azar.

**Controles**
- `←` `→` `↑` `↓`: mover a Link.
- `Z` / `Espacio`: atacar con el arma equipada (espada o arco).
- `1` / `2`: cambiar de arma (`1`: espada, `2`: arco).
- `3` / `4`: seleccionar ítem (`3`: bomba, `4`: poción).
- `B`: usar el ítem seleccionado.
- `E`: interactuar (abrir puertas con candado y cofres).

**Armas**
- **Espada:** ataque cuerpo a cuerpo a la celda de adelante (1 de daño).
- **Arco:** dispara flechas en línea recta hasta 8 celdas de alcance (1 de daño). Link empieza con 10 flechas y puede recargar juntando flechas que sueltan vasijas o enemigos.

**Enemigos**
- **Soldado:** te persigue al acercarte y ataca cuerpo a cuerpo. Cae con 2 golpes (100 pts).
- **Arquero:** busca alinearse a distancia y dispara flechas. Cae con 2 golpes (120 pts).
- **Cañonero:** busca alinearse a distancia y dispara balas de cañón que hacen 2 de daño y explotan al impactar. Cae con 3 golpes (150 pts).
- **Murciélago:** espera quieto, se activa cuando te acercás y vuela rápido hacia vos. Cae con 1 golpe (50 pts).
- **Jefe:** 10 de vida (500 pts). Se activa al entrar en rango (6 celdas) o al recibir un golpe. Busca alinearse para arrojar su tridente giratorio (2 de daño); si te acercás a 2 celdas o menos, invoca una oleada de fuego en área alrededor suyo (1 de daño). Al llegar a la mitad de su vida (una sola vez por pelea), se cubre con su capa, se vuelve invulnerable durante 3 segundos y recupera 4 de vida.

**Ítems** (se agarran pasando por encima o abriendo cofres)
- **Llave:** abre una puerta con candado.
- **Corazón:** recupera 1 corazón al instante.
- **Flechas:** suma 5 flechas al carcaj.
- **Bomba:** se coloca en el piso y explota tras 1,5 segundos rompiendo paredes agrietadas o haciendo 3 de daño en cruz.
- **Poción:** otorga invulnerabilidad temporal durante 5 segundos.

**Vida y puntos**
- Link empieza con 3 corazones (máximo 5).
- Después de recibir un golpe, Link es invulnerable durante 1 segundo.
- Cada enemigo vencido suma puntos según el tipo (murciélago 50, soldado 100, arquero 120, cañonero 150, jefe 500) y cada sala completada suma 200 puntos.

**Fin del juego**
- Sin corazones: GAME OVER con el puntaje final. Al derrotar al jefe: pantalla de victoria (`¡GANASTE!`) con el puntaje final.

**Inspiración:** las mazmorras de *The Legend of Zelda: A Link to the Past* (Nintendo, SNES, 1991), en versión chiquita.

### Posibles extensiones

Más salas, escudo que bloquea disparos, mapa de la mazmorra, sonidos, ranking de puntajes.

## Otros

- UNQ Objetos 1 C4
- Wollok-TS-CLI v1.1.0
  Wollok-TS v4.3.0
  Wollok-Lang v4.0.0
- Una vez terminado, no tenemos problemas en que el repositorio sea público.