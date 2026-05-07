package net.jerryxf.technexus.server

import io.ktor.http.HttpStatusCode
import io.ktor.server.application.*
import io.ktor.server.request.receive
import io.ktor.server.response.respond
import io.ktor.server.routing.*
import net.jerryxf.technexus.shared.Battery

fun Application.batteries() {
    routing {
        route("/batteries") {
            get("/all") {
                call.respond(getBatteries())
            }
            get("/{id}") {
                val id = try {
                    call.parameters["id"]?.toUIntOrNull()
                } catch (e: Exception) {
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
            put("/{id}") {
                val body = try {
                    call.receive<Battery>()
                } catch (e: Exception) {
                    call.respond(HttpStatusCode.BadRequest)
                    return@put
                }
                val id = try {
                    call.parameters["id"]?.toUIntOrNull()
                } catch (e: Exception) {
                    null
                }
                if (id == null) {
                    call.respond(HttpStatusCode.BadRequest)
                    return@put
                }
            }
            delete("/{id}") {}
            post("/new") {}
        }
    }
}
