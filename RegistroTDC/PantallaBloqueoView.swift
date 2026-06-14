//
//  PantallaBloqueoView.swift
//  RegistroTDC
//
//  Created by angel hernandez on 13/06/26.
//

import SwiftUI
// 1. IMPORTAMOS EL FRAMEWORK DE SEGURIDAD
import LocalAuthentication

struct PantallaBloqueoView: View {
    // Variable de estado que controla si la app está abierta o cerrada
    @State private var estaDesbloqueado = false
    @State private var mensajeError = ""
    
    var body: some View {
        // Si ya se desbloqueó, mostramos tu aplicación real
        if estaDesbloqueado {
            // Aquí llamas a la vista principal que ya tienes
            ContentView()
        } else {
            // Si está bloqueado, mostramos la pantalla de seguridad
            VStack(spacing: 20) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
                
                Text("Registro TDC Protegido")
                    .font(.title2.bold())
                
                Text("Usa tu biometría para acceder a tus tarjetas")
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
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: 200)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top, 10)
            }
            // Ejecuta la autenticación automáticamente en cuanto aparece la pantalla
            .onAppear {
                autenticar()
            }
        }
    }
    
    // --- LÓGICA DE AUTENTICACIÓN ---
    func autenticar() {
        // 2. Creamos el contexto de autenticación
        let context = LAContext()
        var error: NSError?
        
        // 3. Verificamos si el dispositivo tiene Face ID o Touch ID configurado
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            // Razón que le aparecerá al usuario en el diálogo de TouchID (FaceID usa el del Info.plist)
            let razon = "Desbloquea para acceder a tus tarjetas."
            
            // 4. Lanzamos la petición de escanear la cara/huella
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: razon) { exito, errorAutenticacion in
                
                // IMPORTANTE: Como esto se ejecuta en segundo plano, debemos
                // actualizar las variables de estado en el hilo principal (Main)
                DispatchQueue.main.async {
                    if exito {
                        // ¡Éxito! Abrimos la puerta
                        withAnimation {
                            estaDesbloqueado = true
                        }
                    } else {
                        mensajeError = "No se pudo verificar la identidad."
                    }
                }
            }
        } else {
            // El dispositivo no tiene FaceID/TouchID o no está configurado
            mensajeError = "Este dispositivo no soporta biometría."
            
            // Tip de UX: Aquí podrías activar un fallback (.deviceOwnerAuthentication)
            // para pedir el PIN numérico del teléfono en su lugar.
        }
    }
}
