//
//  PantallaBloqueoView.swift
//  RegistroTDC
//
//  Created by angel hernandez on 13/06/26.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import SwiftUI
import LocalAuthentication

struct PantallaBloqueoView<Content: View>: View {
    // La razón por la que se solicita la autenticación biométrica
    let razon: String
    // La vista destino que se desbloquea
    let contenidoDestino: Content
    
    // Variable de estado que controla si la app está abierta o cerrada
    @State private var estaDesbloqueado = false
    @State private var mensajeError = ""
    
    @Environment(\.scenePhase) private var scenePhase
    
    // Inicializador genérico para admitir una sintaxis declarativa limpia
    init(razon: String = "Desbloquea para continuar", @ViewBuilder contenidoDestino: () -> Content) {
        self.razon = razon
        self.contenidoDestino = contenidoDestino()
    }
    
    var body: some View {
        ZStack {
            if estaDesbloqueado {
                contenidoDestino
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.primary)
                    
                    Text("Acceso Restringido")
                        .font(.title2.bold())
                    
                    Text("Usa FaceID o el código del dispositivo para acceder")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    if !mensajeError.isEmpty {
                        Text(mensajeError)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                    
                    Button {
                        autenticar()
                    } label: {
                        Label("Desbloquear", systemImage: "faceid")
                            .font(.headline)
                            .foregroundStyle(Color(uiColor: .systemBackground))
                            .padding()
                            .frame(maxWidth: 200)
                            .background(Color.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 10)
                }
                .onAppear {
                    autenticar()
                }
            }
            
            // Pantalla de protección para ocultar datos sensibles en segundo plano (App Switcher)
            if scenePhase == .inactive || scenePhase == .background {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                    .overlay(
                        VStack(spacing: 12) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            Text("Pantalla Protegida")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    )
                    .transition(.opacity)
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                // Bloquear la pantalla al entrar en segundo plano para requerir autenticación al volver
                estaDesbloqueado = false
            }
        }
    }
    
    // --- LÓGICA DE AUTENTICACIÓN ---
    func autenticar() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: razon) { exito, errorAutenticacion in
                DispatchQueue.main.async {
                    if exito {
                        withAnimation {
                            estaDesbloqueado = true
                        }
                    } else {
                        mensajeError = String(localized: "No se pudo verificar la identidad.")
                    }
                }
            }
        } else {
            mensajeError = String(localized: "Este dispositivo no cuenta con bloqueo de seguridad configurado.")
        }
    }
}
