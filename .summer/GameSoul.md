# Coartada

## Vision
Un juego móvil donde el jugador recibe una situación comprometida y tiene que inventar una excusa creíble antes de que se acabe el tiempo. La premisa es simple: te pillaron, ahora habla. Cada ronda entrega un contexto distinto, una cuenta regresiva que aprieta y, a veces, una palabra que debes usar o evitar para complicarte la vida.

Jugar se siente como ese segundo de pánico real antes de dar una explicación que sabes que es débil. La presión es la mecánica. Escribir rápido, escribir bien, convencer. No hay combate ni plataformas; solo tú, el teclado y la urgencia de salir del apuro.

## Genre and Style
- **Type**: Juego de escritura a contrarreloj con calificación automática de texto. Se juega en sesiones cortas desde el celular.
- **Inspirations**: Two Truths and a Lie, por su dinámica de convencer con palabras dentro de reglas pequeñas y concretas. De ahí se toma la idea de que el texto del jugador se mide contra criterios, no contra otro humano.
- **What makes it theirs**: La combinación de restricciones cambiantes por ronda (incluir o excluir palabras) con una dificultad que escala el tiempo disponible. No es solo escribir libre; es escribir libre dentro de un cerco que se cierra. Inferido a partir de sus elecciones de mecánica.

## Look and Feel
- **Art style**: Ilustración vectorial plana, líneas limpias y peso parejo, sin degradados salvo brillos suaves. Fondo blanco o gris muy claro. Paleta de azul marino, verde azulado, amarillo, coral suave. Las pantallas se sienten como una interfaz de app cuidada, sin ruido visual. Los personajes están estilizados pero no caricaturescos.
- **Mood and sound**: Silencio casi total en la lectura del contexto. Música minimalista y tensa que sube conforme el tiempo baja. Un tono seco al enviar la excusa. Sonido distinto si pasas o si pierdes una vida, corto y sin dramatismo.

## The Hero, the World, the Moment
El jugador es un universitario despistado que siempre tiene una justificación estudiantil a mano. Su tono es el de alguien acostumbrado a improvisar, lo que da permiso de que las excusas sean ingeniosas sin sentirse inverosímiles.

Las situaciones ocurren en cualquier contexto cotidiano que te ponga en un aprieto: llegas tarde, olvidaste algo, te vieron donde no debías estar. No hay un mundo construido; hay momentos reconocibles que el jugador ya vivió o teme vivir.

El núcleo del juego es ese instante de escritura a contrarreloj. El tiempo corre en pantalla, las restricciones de palabras están visibles, y el jugador tiene que redactar su excusa sabiendo que cada segundo que pasa le queda menos margen.

## Core Mechanics
El jugador lee el contexto, ve el tiempo disponible y escribe su excusa dentro del límite de palabras indicado. Puede enviarla antes de que el tiempo termine o esperar a que se mande sola. La aplicación evalúa el texto y devuelve una puntuación de 0 a 100; con 65 o más se pasa de ronda. Con menos de 65 se pierde una vida. El jugador tiene 3 vidas; al perderlas todas empieza desde cero.

Conforme avanzan las rondas, el tiempo disponible se reduce gradualmente y pueden aparecer restricciones de palabras: incluir una palabra específica, excluir otra, o ambas a la vez. La dificultad inicial se configura antes de jugar y afecta el tiempo de partida y la complejidad de los contextos. Supuesto: el mínimo de tiempo antes de envío automático nunca baja de 5 segundos para que la mecánica sea jugable.

## First Playable Version
Una ronda completa: pantalla de inicio con el botón de jugar, contexto situacional, cuenta regresiva visible, campo de texto con límite de palabras, botón de enviar y pantalla de resultado con puntuación y estado de vidas. Sin restricciones de palabras todavía. Un solo nivel de dificultad. Loop cerrado de inicio a fin.

## Open Questions
¿Cuántos contextos distintos tendrá el banco inicial antes del lanzamiento?
¿La puntuación de 0 a 100 se muestra con alguna explicación de por qué subió o bajó?
¿Hay un tope de rondas por partida o se juega hasta perder todas las vidas?
¿Las restricciones de palabras se muestran desde que aparece el contexto o aparecen después de unos segundos?

## Board pictures
The concept board's pictures are saved in their assets (My Assets). Look at one when you need the look of the hero, the world or a moment; there is no need to import them all.
- El universitario despistado (hero, asset 16e6c823-4717-4e2a-9b3a-e3c6534023dd): https://res.cloudinary.com/dol86wsz1/image/upload/v1794343244/summer_art/img-6fdb39f4-c7db-43cc-a540-7da2de744c53-1794343244133-0_1794343244133_l1gas6bj.png
- Escribir la excusa a contrarreloj (moment, asset b8f89234-6920-4795-a83d-a3dd030b4f87): https://res.cloudinary.com/dol86wsz1/image/upload/v1794343244/summer_art/img-6fdb39f4-c7db-43cc-a540-7da2de744c53-1794343243664-0_1794343243664_ok7l356s.png
- La oficinista estresada (hero, asset 52c15c55-790a-45ed-9165-975e37836852): https://res.cloudinary.com/dol86wsz1/image/upload/v1794343243/summer_art/img-6fdb39f4-c7db-43cc-a540-7da2de744c53-1794343242989-0_1794343242989_yz7eqluc.png
- El abuelito pillado (hero, asset 2d62368e-36d8-4e00-9803-94d7b7b6610f): https://res.cloudinary.com/dol86wsz1/image/upload/v1794343243/summer_art/img-6fdb39f4-c7db-43cc-a540-7da2de744c53-1794343243322-0_1794343243322_92974rhy.png
- Sala familiar en domingo (world, asset 9337c44b-8184-4b8f-8323-9e3855a0f40f): https://res.cloudinary.com/dol86wsz1/image/upload/v1794343243/summer_art/img-6fdb39f4-c7db-43cc-a540-7da2de744c53-1794343243224-0_1794343243224_9plbwa30.png
- Oficina de jefe severo (world, asset a5c6bada-7dc8-4a7a-82c8-3218cc2770ae): https://res.cloudinary.com/dol86wsz1/image/upload/v1794343243/summer_art/img-6fdb39f4-c7db-43cc-a540-7da2de744c53-1794343243409-0_1794343243409_vwdodbew.png
- Grupo de chat en pantalla (world, asset caa6c772-6395-4d1d-a413-c9ce415ffd12): https://res.cloudinary.com/dol86wsz1/image/upload/v1794343244/summer_art/img-6fdb39f4-c7db-43cc-a540-7da2de744c53-1794343243996-0_1794343243996_eyt277vs.png
- Leer la situación comprometedora (moment, asset 1ff825e6-db0b-4c32-a05e-f5e8fa1399e9): https://res.cloudinary.com/dol86wsz1/image/upload/v1794343243/summer_art/img-6fdb39f4-c7db-43cc-a540-7da2de744c53-1794343243510-0_1794343243510_77ob63bp.png
- Recibir el veredicto del jurado (moment, asset b154aca3-c684-4940-8c33-e84ba042b85c): https://res.cloudinary.com/dol86wsz1/image/upload/v1794343244/summer_art/img-6fdb39f4-c7db-43cc-a540-7da2de744c53-1794343243584-0_1794343243584_9jjzf1kv.png
- La vecina entrometida (picture, asset 730aa0c7-531d-4351-bafb-0aad015b0b5d): https://res.cloudinary.com/dol86wsz1/image/upload/v1794343580/summer_art/img-6fdb39f4-c7db-43cc-a540-7da2de744c53-1794343579744-0_1794343579745_lrov1o8e.png
- Aula universitaria en examen (picture, asset d57eb897-6b95-4512-85f7-fd64b400f6bd): https://res.cloudinary.com/dol86wsz1/image/upload/v1794343453/summer_art/img-6fdb39f4-c7db-43cc-a540-7da2de744c53-1794343453134-0_1794343453134_iok5ef46.png
- El chef en apuros (picture, asset 93e59b4e-ab0c-4f54-a74b-6f6f4c41727e): https://res.cloudinary.com/dol86wsz1/image/upload/v1794343584/summer_art/img-6fdb39f4-c7db-43cc-a540-7da2de744c53-1794343583901-0_1794343583901_ekh0glg1.png

## Ajustes posteriores (v2, 2026-11-10)
El dueño del juego cambió la dirección del proyecto. Esto manda sobre lo anterior:

- **Sin personaje.** No hay protagonista ni universitario: el jugador solo inventa excusas para situaciones cotidianas en general.
- **Sin ilustraciones en la ronda.** El contexto es solo texto: un título grande y un subtítulo corto. Nada de imágenes.
- **Contextos cortos.** Se leen en un segundo: título grande ("Llegas 2 horas tarde a la cena familiar") y subtítulo que aprieta ("Todos están sentados. Tu abuela quiere oír algo creíble").
- **Restricciones de palabras.** A partir de cierta ronda puede aparecer una palabra obligatoria, una palabra prohibida, o ambas más adelante. La dificultad decide desde cuándo.
- **Diseño.** Dark Mode Neo-Brutalist con toques de Neo-Futurismo Tech / arcade cyber minimalista: fondo casi negro con rejilla, bordes rectos de 2 px, sombras duras desplazadas, bloques lima/cian/magenta, tipografía Archivo Black + Space Grotesk + JetBrains Mono.
- **Pantalla de inicio.** Selector de dificultad (Fácil / Normal / Duro) y un apartado para apoyar al creador con dinero.
- **Salir.** Botón de regreso al menú durante la ronda (con confirmación: se pierde el progreso) y en el final de partida.
- **Sonido.** Clic en botones, tic de reloj en los últimos 10 segundos (sube de tono), golpe seco al enviar, tono distinto al pasar y al fallar, doble tono al terminar, y un drone grave sintetizado que se acelera y sube conforme se acaba el tiempo.
- **Jurado de texto.** La nota sale de seis medidas: sustancia, causa (marcadores como «porque» o razones contadas como «se me olvidó», «no pasó», «tuve que»), datos concretos (hora, lugar, número), cohesión, vocabulario y voz. Sin causa detectable la nota se topa en 58.
- La ilustración plana del brief original queda como referencia histórica, ya no se usa.
