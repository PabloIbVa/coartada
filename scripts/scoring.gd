extends RefCounted

## Evalúa una excusa de 0 a 100 sin red.
## Mide por separado: sustancia, causa, datos concretos, cohesión, vocabulario y voz.
## La causa no depende solo de «porque»: también cuenta una razón contada
## («se me olvidó», «tuve que», «se descompuso»).

const PASS_SCORE := 65
const CAP_NO_CAUSE := 58
const CAP_MISSING_WORD := 40
const CAP_BANNED_WORD := 26

const CAUSAL_MARKERS: Array = [
	"porque", "es que", "ya que", "pues", "resulta que", "debido a", "por eso",
	"asi que", "entonces", "a causa de", "gracias a", "por culpa", "de modo que",
	"por lo que", "en cambio", "aunque", "sin embargo", "justo cuando",
]

const CAUSE_PHRASES: Array = [
	"se me olvido", "se me hizo tarde", "se me paso", "se me junto", "se me cayo",
	"no me di cuenta", "no me avisaron", "tuve que", "tenia que", "me toco",
	"me quede", "me quede dormido", "me enferme", "se descompuso", "se rompio",
	"se comio", "se cayo", "se perdio", "se mojo", "se quemo", "se escapo",
	"se acabo", "se bajo la bateria", "sin bateria", "no pude", "no alcance",
	"me atrase", "se complico", "me salio", "estaba cerrado", "no habia",
	"no encontre", "me equivoque", "me pidieron", "me mandaron", "me llamaron",
	"me agarro", "me dio", "me bajo", "estaba ayudando", "habia trafico",
	"mucho trafico", "se hizo tarde", "me quitaron", "me dieron", "me sacaron",
]

const PERSONAL: Array = [
	"yo", "me", "mi", "mis", "conmigo", "nos", "estaba", "estuve", "llegue",
	"olvide", "perdi", "pude", "tuve", "tenia", "tengo", "salgo", "salí", "voy",
	"fui", "hice", "dije", "quede", "atrase", "equivoque", "avise", "mande",
	"llame", "pague", "esperaba", "intente",
]

const POLITE: Array = [
	"profe", "profesor", "profesora", "jefe", "jefa", "senor", "senora",
	"senorita", "papa", "mama", "abuela", "abuelo", "perdon", "perdoname",
	"disculpa", "disculpe", "siento", "juro", "usted", "licenciado",
]

const TIME_WORDS: Array = [
	"ayer", "hoy", "manana", "noche", "madrugada", "temprano", "tarde",
	"semana", "mes", "hora", "horas", "minuto", "minutos", "lunes", "martes",
	"miercoles", "jueves", "viernes", "sabado", "domingo", "mediodia", "fecha",
]

const PLACE_WORDS: Array = [
	"casa", "trabajo", "escuela", "oficina", "calle", "camion", "carro", "coche",
	"metro", "cochera", "sala", "cocina", "hospital", "doctor", "banco",
	"tienda", "aqui", "alla", "afuera", "caminando",
]

const NUMBER_WORDS: Array = [
	"dos", "tres", "cuatro", "cinco", "seis", "siete", "ocho", "nueve", "diez",
	"once", "doce", "quince", "veinte", "treinta", "cuarenta", "cincuenta",
	"media", "medio", "un", "una",
]

const PRONOUNS: Array = ["me", "te", "se", "lo", "la", "le", "les", "los", "las", "nos"]

const STATE_WORDS: Array = [
	"cerrado", "cerrada", "parado", "parada", "lleno", "llena", "ocupado",
	"ocupada", "roto", "rota", "descompuesto", "atascado", "sin",
]


static func evaluate(raw: String, word_limit: int, include_word: String = "", exclude_word: String = "") -> Dictionary:
	var text: String = raw.strip_edges()
	var words: Array = _words(text)
	var n: int = words.size()
	var notes: Array = []

	var include_ok: bool = include_word.is_empty() or _has_word(words, include_word)
	var exclude_used: bool = not exclude_word.is_empty() and _has_word(words, exclude_word)

	if n == 0:
		var empty_notes: Array = ["No escribiste nada. El silencio también confiesa."]
		if not include_word.is_empty():
			empty_notes.append("Faltó «%s»." % include_word)
		return {
			"score": 0, "passed": false, "notes": empty_notes, "words": 0,
			"include_ok": include_ok, "exclude_used": exclude_used, "breakdown": {},
		}

	var flat: String = " " + " ".join(PackedStringArray(words)) + " "

	# 1. Sustancia: cuánta excusa hay que leer (0-24).
	var substance: float = clampf(float(n) / 18.0, 0.0, 1.0) * 24.0
	if n < 6:
		notes.append("Muy corto: el jurado no tiene con qué creerte.")
	elif n < 9:
		notes.append("Corto: falta el cómo o el cuándo.")

	# 2. Causa: marcadores, razones contadas y patrones («no pasó», «se me…») (0-26).
	var markers: Array = _find_in(flat, CAUSAL_MARKERS)
	var phrases: Array = _find_in(flat, CAUSE_PHRASES)
	var patterns: float = _cause_patterns(words)
	var cause: float = minf(18.0, float(markers.size()) * 6.0) + minf(10.0, float(phrases.size()) * 5.0) + patterns
	cause = clampf(cause, 0.0, 26.0)

	# 3. Datos concretos: hora, número, lugar, algo propio (0-14).
	var concrete: float = 0.0
	if _has_digit(text) or not _find_in(flat, TIME_WORDS).is_empty() or not _find_in(flat, NUMBER_WORDS).is_empty():
		concrete += 8.0
	if flat.contains(" mi ") or flat.contains(" mis "):
		concrete += 3.0
	if not _find_in(flat, PLACE_WORDS).is_empty():
		concrete += 3.0
	concrete = clampf(concrete, 0.0, 14.0)

	# 4. Cohesión: frases completas y longitud razonable (0-16).
	var sentences: int = 0
	var cleaned: String = text.replace("!", ".").replace("?", ".").replace("…", ".")
	for part in cleaned.split(".", false):
		if part.strip_edges().length() > 3:
			sentences += 1
	var cohesion: float = 4.0 if sentences == 1 else 7.0
	if text.ends_with(".") or text.ends_with("!") or text.ends_with("?"):
		cohesion += 4.0
	var per_sentence: float = float(n) / float(maxi(1, sentences))
	if per_sentence >= 6.0 and per_sentence <= 24.0:
		cohesion += 5.0
	cohesion = clampf(cohesion, 0.0, 16.0)

	# 5. Vocabulario: variedad y palabras de verdad (0-12).
	var lexical: float = 0.0
	if n >= 5:
		var uniq: Dictionary = {}
		for w in words:
			uniq[w] = true
		var ratio: float = float(uniq.size()) / float(n)
		lexical += clampf((ratio - 0.45) / 0.4, 0.0, 1.0) * 7.0
		if ratio < 0.5:
			notes.append("Repites las mismas palabras. Se nota.")
	var chars: int = 0
	for w in words:
		chars += String(w).length()
	var avg: float = float(chars) / float(n)
	if avg >= 3.6 and avg <= 9.5:
		lexical += 5.0
	elif avg >= 2.8:
		lexical += 3.0
	lexical = clampf(lexical, 0.0, 12.0)

	# 6. Voz: quién habla y a quién le habla (0-8).
	var voice: float = 0.0
	if text.substr(0, 1) == text.substr(0, 1).to_upper():
		voice += 3.0
	if not _find_in(flat, PERSONAL).is_empty():
		voice += 3.0
	if not _find_in(flat, POLITE).is_empty():
		voice += 2.0
	voice = clampf(voice, 0.0, 8.0)

	var score: float = substance + cause + concrete + cohesion + lexical + voice

	# Ruido que no es una excusa.
	if _looks_mashed(text):
		score -= 32.0
		notes.append("Eso parece tecleo de gato.")
	if _is_shouting(text) and n > 5:
		score -= 8.0
		notes.append("Gritar no es argumentar.")
	if n > word_limit:
		score -= 10.0

	if cause == 0.0:
		notes.push_front("Sin causa no hay coartada: ni un «porque» ni nada que lo explique.")
	elif concrete == 0.0 and score < PASS_SCORE:
		notes.append("Faltó un dato concreto: una hora, un lugar, un nombre.")
	if cohesion < 9.0 and score < PASS_SCORE:
		notes.append("Suena a lista de palabras: cuéntalo como una historia.")

	# Restricciones de la ronda.
	if not include_word.is_empty():
		if include_ok:
			score += 8.0
		else:
			notes.push_front("No usaste «%s» y era obligatoria." % include_word)
	if exclude_used:
		notes.push_front("Usaste «%s», que estaba prohibida." % exclude_word)

	var final_score: float = clampf(score, 0.0, 100.0)
	if cause == 0.0:
		final_score = minf(final_score, CAP_NO_CAUSE)
	if not include_ok:
		final_score = minf(final_score, CAP_MISSING_WORD)
	if exclude_used:
		final_score = minf(final_score, CAP_BANNED_WORD)

	var graded: int = int(round(final_score))
	var passed: bool = graded >= PASS_SCORE
	if passed and notes.is_empty():
		notes.append("Hay causa, hay detalle y cara de inocente.")
	elif not passed and notes.is_empty():
		notes.append("Le faltó detalle: qué pasó, cuándo y por qué.")

	return {
		"score": graded,
		"passed": passed,
		"notes": notes,
		"words": n,
		"include_ok": include_ok,
		"exclude_used": exclude_used,
		"breakdown": {
			"sustancia": int(round(substance)),
			"causa": int(round(cause)),
			"datos": int(round(concrete)),
			"cohesion": int(round(cohesion)),
			"vocabulario": int(round(lexical)),
			"voz": int(round(voice)),
		},
	}


static func word_count(text: String) -> int:
	return _words(text).size()


static func uses_word(text: String, word: String) -> bool:
	if word.is_empty():
		return false
	return _has_word(_words(text), word)


static func _find_in(flat: String, list: Array) -> Array:
	var found: Array = []
	for item in list:
		var needle: String = _norm(String(item)).strip_edges()
		if needle.is_empty():
			continue
		if flat.contains(" " + needle + " "):
			if not found.has(needle):
				found.append(needle)
	return found


## Detecta construcciones de causa sin depender de una frase exacta:
## "no pasó", "se me olvidó", "tuve que", "hubo un accidente", "estaba cerrado".
static func _cause_patterns(words: Array) -> float:
	var hits: float = 0.0
	var seen: Dictionary = {}
	var total: int = words.size()
	for i in total:
		var w: String = String(words[i])
		var direct: String = String(words[i + 1]) if i + 1 < total else ""
		var next_word: String = _next_content(words, i + 1)

		if w == "no" and next_word != "":
			var key_no: String = "no:" + next_word
			if not seen.has(key_no):
				seen[key_no] = true
				hits += 4.0
		elif w == "se" and direct == "me":
			if not seen.has("seme"):
				seen["seme"] = true
				hits += 4.0
		elif w == "se" and direct != "" and not PRONOUNS.has(direct):
			var key_se: String = "se:" + direct
			if not seen.has(key_se):
				seen[key_se] = true
				hits += 4.0
		elif (w == "tuve" or w == "tenia" or w == "tenian" or w == "tuvo" or w == "tuvimos") and next_word == "que":
			if not seen.has("tuveque"):
				seen["tuveque"] = true
				hits += 5.0
		elif w == "hubo" or w == "ocurrio":
			if not seen.has("hubo"):
				seen["hubo"] = true
				hits += 4.0
		elif (w == "estaba" or w == "estuvo" or w == "estaban") and STATE_WORDS.has(next_word):
			if not seen.has("estado"):
				seen["estado"] = true
				hits += 4.0
	return minf(hits, 14.0)


static func _next_content(words: Array, from: int) -> String:
	var i: int = from
	while i < words.size():
		var w: String = String(words[i])
		if not PRONOUNS.has(w):
			return w
		i += 1
	return ""


static func _has_digit(text: String) -> bool:
	for i in text.length():
		var cp: int = text.unicode_at(i)
		if cp >= 48 and cp <= 57:
			return true
	return false


static func _has_word(words: Array, word: String) -> bool:
	var target: String = _norm(word).strip_edges()
	if target.is_empty():
		return false
	for w in words:
		var token: String = String(w)
		if token == target:
			return true
		if target.length() >= 4 and token.begins_with(target):
			return true
	return false


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
			out.append(_norm(cur))
			cur = ""
	if cur.length() > 0:
		out.append(_norm(cur))
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
