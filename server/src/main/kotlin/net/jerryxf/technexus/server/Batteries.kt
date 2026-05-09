package net.jerryxf.technexus.server

import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import net.jerryxf.technexus.shared.Battery
import net.jerryxf.technexus.shared.BatteryCycle

fun Application.batteries() {
    routing {
        route("/batteries") {
            get("/all") {
                call.respond(getBatteries())
            }
            get("/{id}") {
                val id = try {
                    call.parameters["id"]?.toUIntOrNull()
                } catch (_: Exception) {
                    null
                }
                if (id == null) {
                    call.respond(HttpStatusCode.BadRequest)
                    return@get
                }
                val bat = getBattery(id)
                if (bat == null) {
                    call.respond(HttpStatusCode.NotFound)
                    return@get
                }

                call.respond(bat)
            }
            put("/edit") {
                val body = try {
                    call.receive<Battery>()
                } catch (_: Exception) {
                    call.respond(HttpStatusCode.BadRequest)
                    return@put
                }
                val updated = updateBattery(body)
                if (updated) {
                    call.respond(HttpStatusCode.OK)
                    return@put
                }
                call.respond(HttpStatusCode.NotFound)
            }
            delete("/{id}") {
                val id = try {
                    call.parameters["id"]?.toUIntOrNull()
                } catch (_: Exception) {
                    null
                }
                if (id == null) {
                    call.respond(HttpStatusCode.BadRequest)
                    return@delete
                }
                deleteBattery(id)
                call.respond(HttpStatusCode.OK)
            }
            post("/new") {
                val body = try {
                    call.receive<Battery>()
                } catch (_: Exception) {
                    call.respond(HttpStatusCode.BadRequest)
                    return@post
                }
                call.respond(createBattery(body))
            }
        }
        route("/cycles") {
            get("/all") {
                call.respond(getCycles())
            }
            get("/{id}") {
                val id = try {
                    call.parameters["id"]?.toUIntOrNull()
                } catch (_: Exception) {
                    null
                }
                if (id == null) {
                    call.respond(HttpStatusCode.BadRequest)
                    return@get
                }
                val cycle = getCycle(id)
                if (cycle == null) {
                    call.respond(HttpStatusCode.NotFound)
                    return@get
                }

                call.respond(cycle)
            }
            put("/edit") {
                val body = try {
                    call.receive<BatteryCycle>()
                } catch (_: Exception) {
                    call.respond(HttpStatusCode.BadRequest)
                    return@put
                }
                val updated = updateCycle(body)
                if (updated) {
                    call.respond(HttpStatusCode.OK)
                    return@put
                }
                call.respond(HttpStatusCode.NotFound)
            }
            delete("/{id}") {
                val id = try {
                    call.parameters["id"]?.toUIntOrNull()
                } catch (_: Exception) {
                    null
                }
                if (id == null) {
                    call.respond(HttpStatusCode.BadRequest)
                    return@delete
                }
                deleteCycle(id)
                call.respond(HttpStatusCode.OK)
            }
            post("/new") {
                val body = try {
                    call.receive<BatteryCycle>()
                } catch (_: Exception) {
                    call.respond(HttpStatusCode.BadRequest)
                    return@post
                }
                call.respond(createCycle(body))
            }
        }
    }
}
