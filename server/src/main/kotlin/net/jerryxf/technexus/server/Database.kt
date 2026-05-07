package net.jerryxf.technexus.server

import net.jerryxf.technexus.shared.Battery
import net.jerryxf.technexus.shared.BatteryCycle
import org.jetbrains.exposed.v1.core.dao.id.UIntIdTable
import org.jetbrains.exposed.v1.core.eq
import org.jetbrains.exposed.v1.datetime.timestamp
import org.jetbrains.exposed.v1.jdbc.*
import org.jetbrains.exposed.v1.jdbc.transactions.suspendTransaction

private object Batteries : UIntIdTable() {
    val name = varchar("name", 30)
    val type = varchar("type", 20)
    val year = ubyte("year")
}

private object BatteryCycles : UIntIdTable() {
    val batteryId = reference("battery_id", Batteries.id)
    val startTime = timestamp("start_time")
    val endTime = timestamp("end_time")
}

suspend fun createBattery(item: Battery) = suspendTransaction {
    Batteries.insert {
        it[Batteries.name] = item.name
        it[Batteries.type] = item.type
        it[Batteries.year] = item.year
    }
}

suspend fun getBattery(id: UInt): Battery? = suspendTransaction {
    Batteries.selectAll()
        .where { Batteries.id eq id }
        .map {
            Battery(
                it[Batteries.id].value,
                it[Batteries.name],
                it[Batteries.type],
                it[Batteries.year]
            )
        }
        .singleOrNull()
}

suspend fun getBatteries(): List<Battery> = suspendTransaction {
    Batteries.selectAll().map {
        Battery(
            it[Batteries.id].value,
            it[Batteries.name],
            it[Batteries.type],
            it[Batteries.year]
        )
    }
}

suspend fun updateBattery(item: Battery) = suspendTransaction {
    Batteries.update({ Batteries.id eq item.id }) {
        it[Batteries.name] = item.name
        it[Batteries.type] = item.type
        it[Batteries.year] = item.year
    }
}

suspend fun deleteBattery(id: UInt) = suspendTransaction {
    Batteries.deleteWhere { Batteries.id eq id }
}

suspend fun createCycle(item: BatteryCycle) = suspendTransaction {
    BatteryCycles.insert {
        it[BatteryCycles.batteryId] = item.id
        it[BatteryCycles.startTime] = item.startTime
        it[BatteryCycles.endTime] = item.endTime
    }
}

suspend fun getCycle(id: UInt): BatteryCycle? = suspendTransaction {
    Batteries.selectAll()
        .where { BatteryCycles.id eq id }
        .map {
            BatteryCycle(
                it[BatteryCycles.id].value,
                getBattery(it[BatteryCycles.batteryId].value) ?: return@map null,
                it[BatteryCycles.startTime],
                it[BatteryCycles.endTime]
            )
        }
        .singleOrNull()
}

/**
 * Only updates times (not battery)
 * use updateBattery for that
 */
suspend fun updateCycle(item: BatteryCycle) = suspendTransaction {
    Batteries.update({ BatteryCycles.id eq item.id }) {
        it[BatteryCycles.startTime] = item.startTime
        it[BatteryCycles.endTime] = item.endTime
    }
}

suspend fun deleteCycle(id: UInt) = suspendTransaction {
    Batteries.deleteWhere { BatteryCycles.id eq id }
}
