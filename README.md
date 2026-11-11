# COARTADA  
  
> **Te pillaron. Habla.**  
  
**Coartada** es un juego móvil de escritura a contrarreloj: recibes una situación  
comprometida ("llegas 2 horas tarde", "te vieron donde no debías estar") y tienes  
que escribir una excusa creíble antes de que se acabe el tiempo. Un jurado  
automático puntúa tu texto de 0 a 100 — con **65 o más pasas la ronda**.  
  
Todo el procesamiento es **local**: no necesitas conexión a internet.  
  
## Cómo se juega  
  
1. **Elige la dificultad** en la pantalla de inicio: `FÁCIL`, `NORMAL` o `DURO`.  
   Afecta el tiempo inicial y la complejidad de los contextos.  
2. **Lee el contexto** de la ronda.  
3. **Escribe tu coartada** dentro del límite de palabras (ej. máx. 28).  
4. **Cumple las restricciones** si aparecen: a veces deberás *usar* una palabra  
   específica, *evitar* otra, o ambas cosas (aparecen a partir de la ronda 3).  
5. **Envía** con el botón o deja que el tiempo la mande solo.  
  
### Reglas  
  
- Puntuación **≥ 65** → pasas a la siguiente ronda (más difícil, menos tiempo).  
- Puntuación **< 65** → pierdes **1 de 3 vidas**.  
- Sin vidas → `SE ACABÓ`, empiezas desde cero.  
- El tiempo se reduce gradualmente por ronda, nunca hasta lo imposible.  
  
## Estructura del proyecto  
  
Proyecto en **Godot 4.7** (GDScript), viewport móvil vertical `720x1280`.  
  
| Archivo | Rol |  
| --- | --- |  
| `main.tscn` | Escena única con todas las pantallas: `Home`, `Round`, `Result`, `Over` |  
| `scripts/main.gd` | Controlador central: loop de juego, temporizador, transiciones |  
| `scripts/scoring.gd` | Motor de evaluación de texto (puntuación 0–100) |  
| `scripts/contexts.gd` | Banco de contextos y restricciones de palabras |  
| `scripts/audio.gd` | Audio procedural de tensión y efectos |  
| `ui/theme.tres` | Tema visual global |  
| `assets/` | Fuentes, ilustraciones y sonidos |  
| `.summer/GameSoul.md` | Documento de diseño y visión del juego |  
  
## Ejecutar el proyecto  
  
1. Instala [Godot 4.x](https://godotengine.org).  
2. Abre `project.godot` desde el gestor de proyectos.  
3. Presiona **F5** — la escena principal es `main.tscn`.  
  
## Diseño  
  
- **Estilo:** interfaz limpia tipo app, tipografía display + monoespaciada,  
  acentos en verde lima, cian y coral sobre fondo oscuro.  
- **Audio:** silencio en la lectura, tensión que sube con el tiempo, tono seco  
  al enviar.  
- **Inspiración:** *Two Truths and a Lie* — convencer con palabras bajo reglas  
  pequeñas y concretas.
