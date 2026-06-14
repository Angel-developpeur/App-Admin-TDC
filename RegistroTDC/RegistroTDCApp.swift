//
//  RegistroTDCApp.swift
//  RegistroTDC
//
//  Created by angel hernandez on 05/06/26.
//

import SwiftUI
import SwiftData

@main
struct RegistroTDCApp: App {
    var body: some Scene {
        WindowGroup {
            //ContentView()
            PantallaBloqueoView() //llamos a la pantallade desbloqueo
        }
        //permitimos que toda la aplicacion tenga acceso al modelo
        .modelContainer(for: [Tarjeta.self, Compra.self])
    }
}
