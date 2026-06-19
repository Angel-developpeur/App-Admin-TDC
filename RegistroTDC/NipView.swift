//
//  NipView.swift
//  RegistroTDC
//
//  Created by angel hernandez on 16/06/26.
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
import SwiftData

struct NipView: View {
    let tarjeta: Tarjeta
    
    @State private var mostrarNip = false
    @State private var copiado = false
    
    var body: some View {
        ZStack {
            // Fondo degradado sutil para dar profundidad
            LinearGradient(
                colors: [Color(uiColor: .systemBackground), Color(uiColor: .secondarySystemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 35) {
                // 1. Representación visual de la Tarjeta física
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text(tarjeta.banco)
                            .font(.system(.title3, design: .rounded))
                            .bold()
                        Spacer()
                        if !tarjeta.nombreLogo.isEmpty {
                            Image(tarjeta.nombreLogo)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 22)
                        } else {
                            Text(tarjeta.tipo)
                                .font(.subheadline.bold())
                        }
                    }
                    
                    Spacer()
                    
                    // Chip de la tarjeta simulado
                    HStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [Color.yellow, Color.orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 42, height: 32)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        Spacer()
                    }
                    
                    HStack {
                        Text("•••• •••• •••• \(tarjeta.ultimosDigitos)")
                            .font(.system(.title3, design: .monospaced))
                            .bold()
                        Spacer()
                    }
                }
                .padding(25)
                .frame(height: 200)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: tarjeta.color))
                        .shadow(color: Color(hex: tarjeta.color).opacity(0.3), radius: 12, x: 0, y: 8)
                )
                .foregroundStyle(Color(hex: tarjeta.color).textoIdeal)
                .padding(.horizontal)
                
                // 2. Contenedor del NIP
                VStack(spacing: 20) {
                    Text("NIP DE SEGURIDAD")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                        .tracking(2)
                    
                    HStack(spacing: 12) {
                        // Creamos 4 casillas para los dígitos del NIP
                        ForEach(0..<4, id: \.self) { index in
                            let char = obtenerCaracterNip(en: index)
                            
                            Text(mostrarNip ? char : "•")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .frame(width: 55, height: 65)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                                        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(mostrarNip ? Color(hex: tarjeta.color) : Color.clear, lineWidth: 1.5)
                                )
                                .scaleEffect(mostrarNip ? 1.05 : 1.0)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // Botón para revelar / ocultar NIP
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            mostrarNip.toggle()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: mostrarNip ? "eye.slash.fill" : "eye.fill")
                            Text(mostrarNip ? "Ocultar NIP" : "Mostrar NIP")
                        }
                        .font(.subheadline.bold())
                        .foregroundStyle(Color(uiColor: .systemBackground))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color.primary)
                        .clipShape(Capsule())
                        .shadow(color: Color(hex: tarjeta.color).opacity(0.2), radius: 5, x: 0, y: 3)
                    }
                }
                .padding(25)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(uiColor: .systemGroupedBackground))
                        .shadow(color: .black.opacity(0.02), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal)
                
                // 3. Acciones y Advertencia de Seguridad
                VStack(spacing: 25) {
                    Button {
                        UIPasteboard.general.string = tarjeta.nip
                        withAnimation {
                            copiado = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                copiado = false
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: copiado ? "checkmark.circle.fill" : "doc.on.doc.fill")
                            Text(copiado ? "NIP Copiado" : "Copiar NIP al portapapeles")
                        }
                        .font(.subheadline.bold())
                        .foregroundStyle(copiado ? .green : .primary)
                    }
                    .disabled(tarjeta.nip.isEmpty)
                    
                    
                }
                
                Spacer()
            }
            .padding(.top, 20)
        }
        .navigationTitle("NIP de Tarjeta")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Función segura para obtener el carácter en cada posición
    private func obtenerCaracterNip(en index: Int) -> String {
        let nipStr = tarjeta.nip
        guard index < nipStr.count else { return "" }
        let idx = nipStr.index(nipStr.startIndex, offsetBy: index)
        return String(nipStr[idx])
    }
}

#Preview {
    NipView(tarjeta: Tarjeta(
        banco: "Santander",
        ultimosDigitos: "1234",
        tipo: "Visa",
        color: "#1B3B6F",
        limiteCrdito: 5000000,
        nip: "4321",
        diaDeCorte: 15,
        creditoUsado: 2500
    ))
}
