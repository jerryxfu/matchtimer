package net.jerryxf.technexus.server

import io.ktor.server.application.Application
import io.ktor.server.routing.delete
import io.ktor.server.routing.get
import io.ktor.server.routing.post
import io.ktor.server.routing.put
import io.ktor.server.routing.route
import io.ktor.server.routing.routing

fun Application.batteries() {
    routing {
        route("/batteries") {
            get("/all") {

            }
            get("/{id}") {}
            put("/{id}") {}
            delete("/{id}") {}
            post("/new") {}
        }
    }
}
