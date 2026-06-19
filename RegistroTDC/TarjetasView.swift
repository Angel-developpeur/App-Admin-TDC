//
//  TarjetasView.swift
//  RegistroTDC
//
//  Created by angel hernandez on 18/06/26.
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

struct TarjetasView: View {
    @Query var tarjetas: [Tarjeta] // Listado de tarjetas almacenadas
    @State private var mostrarFormulario = false // Indica si se muestra el formulario de creación
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                ScrollView {
                    LazyVStack {
                        if tarjetas.isEmpty {
                            // Si no hay tarjetas, mostrar un mensaje de estado vacío
                            ContentUnavailableView(
                                "Sin Tarjetas",
                                systemImage: "creditcard.and.123",
                                description: Text("Toca el botón + para registrar tu primera tarjeta.")
                            )
                        } else {
                            ForEach(tarjetas) { tarjeta in
                                NavigationLink {
                                    DetalleTarjetaView(tarjeta: tarjeta)
                                } label: {
                                    let colorFondo = Color(hex: tarjeta.color)
                                    HStack {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(tarjeta.banco).font(.headline)
                                            if tarjeta.nombreLogo.isEmpty {
                                                Text(tarjeta.tipo)
                                                    .font(.subheadline)
                                                    .opacity(0.8)
                                            } else {
                                                Image(tarjeta.nombreLogo)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 20)
                                            }
                                        }
                                        Spacer()
                                        Text("•••• \(tarjeta.ultimosDigitos)")
                                            .font(.system(.body, design: .monospaced))
                                    }
                                    .foregroundStyle(colorFondo.textoIdeal)
                                    .padding(20)
                                    .background(colorFondo)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Mis Tarjetas")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        mostrarFormulario = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $mostrarFormulario) {
                FormularioCreateTarjetaView()
            }
            .onAppear {
                NotificationManager.shared.solicitarPermiso()
                NotificationManager.shared.sincronizarNotificaciones(con: tarjetas)
            }
        }
    }
}

#Preview {
    TarjetasView()
        .modelContainer(for: Tarjeta.self, inMemory: true)
}
