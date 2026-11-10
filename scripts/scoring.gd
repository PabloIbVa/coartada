extends RefCounted

## Puntúa una excusa de 0 a 100 con reglas de texto, sin red.

const PASS_SCORE := 65

const CONNECTORS: Array = [
	"porque", "es que", "ya que", "pues", "resulta que", "debido a", "por eso",
	"entonces", "asi que", "aunque", "mientras", "cuando", "despues", "justo",
	"de repente", "en realidad", "la verdad", "te juro", "se me", "tuve que",
	"olvide", "perdi", "me quede", "no alcanzo",
]


static func evaluate(raw: String, word_limit: int) -> Dictionary:
	var text: String = raw.strip_edges()
	var words: Array = _words(text)
	var n: int = words.size()
	var notes: Array = []

	if n == 0:
		return {
			"score": 0,
			"passed": false,
			"notes": ["No escribiste nada. El silencio también confiesa."],
			"words": 0,
		}

	var score: float = 0.0

	# Sustancia: cuánto texto hay que leer (0-32).
	score += clampf(float(n) / 20.0, 0.0, 1.0) * 32.0
	if n < 6:
		score -= 15.0
		notes.append("Muy corto: el jurado no tiene con qué creerte.")
	elif n < 9:
		score -= 5.0

	# Causa y estructura de excusa (0-30).
	var flat: String = " " + " ".join(PackedStringArray(words)) + " "
	var found: Array = []
	for connector in CONNECTORS:
		var c: String = _norm(connector)
		if flat.contains(" " + c + " ") or (c.contains(" ") and flat.contains(c + " ")):
			if not found.has(c):
				found.append(c)
	score += minf(30.0, float(found.size()) * 10.0)
	if found.is_empty():
		notes.append("Falta el «porque»: sin causa no hay coartada.")

	# Variedad léxica (0-14).
	if n >= 5:
		var uniq: Dictionary = {}
		for w in words:
			uniq[w] = true
		var ratio: float = float(uniq.size()) / float(n)
		score += clampf((ratio - 0.45) / 0.4, 0.0, 1.0) * 14.0
		if ratio < 0.5:
			notes.append("Repites las mismas tres palabras. Se nota.")

	# Fraseo y puntuación (0-11).
	var sentences: int = 0
	var cleaned: String = text.replace("!", ".").replace("?", ".").replace("…", ".")
	for part in cleaned.split(".", false):
		if part.strip_edges().length() > 3:
			sentences += 1
	if sentences >= 2:
		score += 7.0
	elif sentences == 1:
		score += 4.0
	if text.ends_with(".") or text.ends_with("!") or text.ends_with("?"):
		score += 4.0

	# Palabras de verdad: longitud media (0-10).
	var chars: int = 0
	for w in words:
		chars += String(w).length()
	var avg: float = float(chars) / float(n)
	if avg >= 3.6 and avg <= 9.5:
		score += 10.0
	elif avg >= 2.8:
		score += 5.0
	else:
		notes.append("Las palabras no se entienden.")

	# Arranque con formalidad (0-5).
	if text.substr(0, 1) == text.substr(0, 1).to_upper():
		score += 5.0

	# Ensuciar la excusa.
	if _looks_mashed(text):
		score -= 32.0
		notes.append("Eso parece tecleo de gato.")
	if _is_shouting(text) and n > 5:
		score -= 8.0
		notes.append("Gritar no es argumentar.")
	if n > word_limit:
		score -= 10.0

	var final_score: int = int(round(clampf(score, 0.0, 100.0)))
	if found.is_empty() and final_score > 58:
		final_score = 58
	var passed: bool = final_score >= PASS_SCORE
	if passed and notes.is_empty():
		notes.append("Hay causa, hay detalle y cara de inocente.")
	elif not passed and notes.is_empty():
		notes.append("Le faltó detalle: qué pasó, cuándo y por qué.")

	return {
		"score": final_score,
		"passed": passed,
		"notes": notes,
		"words": n,
	}


static func word_count(text: String) -> int:
	return _words(text).size()


static func _words(text: String) -> Array:
	var out: Array = []
	var cur: String = ""
	for i in text.length():
		var cp: int = text.unicode_at(i)
		var is_word: bool = (cp >= 48 and cp <= 57) or (cp >= 65 and cp <= 90) \
			or (cp >= 97 and cp <= 122) or (cp >= 192 and cp <= 591)
		if is_word:
			cur += text[i]
		elif cur.length() > 0:
			out.append(cur.to_lower())
			cur = ""
	if cur.length() > 0:
		out.append(cur.to_lower())
	return out


static func _norm(s: String) -> String:
	var out: String = s.to_lower()
	var from: String = "áàäâãéèëêíìïîóòöôõúùüûñç"
	var to: String = "aaaaaeeeeiiiiooooouuuunc"
	for i in from.length():
		out = out.replace(from[i], to[i])
	return out


static func _looks_mashed(text: String) -> bool:
	var re := RegEx.new()
	if re.compile("[bcdfghjklmnpqrstvwxyz]{6,}") == OK and re.search(text.to_lower()) != null:
		return true
	var rep := RegEx.new()
	if rep.compile("([a-z])\\1{3,}") == OK and rep.search(text.to_lower()) != null:
		return true
	return false


static func _is_shouting(text: String) -> bool:
	var letters: int = 0
	for i in text.length():
		var cp: int = text.unicode_at(i)
		if (cp >= 65 and cp <= 90) or (cp >= 97 and cp <= 122):
			letters += 1
	if letters < 6:
		return false
	return text.to_upper() == text
