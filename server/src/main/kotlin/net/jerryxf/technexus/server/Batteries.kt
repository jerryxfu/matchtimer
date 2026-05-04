package net.jerryxf.technexus.server

import io.ktor.server.application.*
import io.ktor.server.routing.*

fun Application.batteries() {
    routing {
        route("/batteries") {
            get("/all") {}
            get("/{id}") {}
            put("/{id}") {}
            delete("/{id}") {}
            post("/new") {}
        }
    }
}
