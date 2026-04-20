package net.jerryxf.technexus.shared

class MatchId {
    private constructor(type: MatchType, number: UShort) {
        this.type = type
        this.number = number
    }

    val type: MatchType
    val number: UShort

    fun getTBAKey(event: String): String {
        return event + "_" + type.short + "m" + number
    }

    enum class MatchType(val short: String) {
        PRACTICE("p"),
        QUALIFICATION("q"),
        ELIMINATION("e")
    }

    companion object {
        fun fromLabel(label: String): MatchId? {
            val lbl = label.lowercase()

            val type = if (lbl.startsWith("practice")) MatchType.PRACTICE
            else if (lbl.startsWith("qualification")) MatchType.QUALIFICATION
            else if (lbl.startsWith("elimination")) MatchType.ELIMINATION // TODO : check
            else return null

            val number = try {
                label.split(" ")[1].toUShortOrNull()
            } catch (_: Exception) {
                null
            }
            if (number == null) return null

            return MatchId(type, number)
        }

        fun fromShort(short: String): MatchId? {
            val lbl = short.lowercase()

            val type = when (lbl[0]) {
                'p' -> MatchType.PRACTICE
                'q' -> MatchType.QUALIFICATION
                'e' -> MatchType.ELIMINATION
                else -> return null
            }

            val number = try {
                lbl.subSequence(1, lbl.length - 1).toString().toUShortOrNull()
            } catch (_: Exception) {
                null
            }
            if (number == null) return null

            return MatchId(type, number)
        }
    }
}