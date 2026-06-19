//
//  DeudaView.swift
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
import Charts

struct DeudaView: View {
    @Query var tarjetas: [Tarjeta] // Listado de tarjetas almacenadas
    
    // Deuda acumulada calculada de todas las tarjetas
    var totalDeuda: Int {
        var suma = 0
        for tarjeta in tarjetas {
            for compra in tarjeta.compras {
                suma += compra.monto
            }
        }
        return suma
    }
    
    var body: some View {
        let sumaDeuda = totalDeuda
        VStack(spacing: 35) {
            VStack(spacing: 8) {
                Text("Deuda Total")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Text(Double(sumaDeuda) / 100.0, format: .currency(code: "MXN"))
                    // Usamos un tamaño masivo y fuente redondeada estilo Apple Wallet
                    .font(.system(size: 46, weight: .bold, design: .rounded))
                    // Si no hay deuda, se pinta verde, si hay, se pinta el color primario (negro/blanco)
                    .foregroundStyle(sumaDeuda == 0 ? .green : .primary)
            } // fin del vstack
            .padding(.top, 20)
            
            if sumaDeuda > 0 {
                Chart(tarjetas) { tarjeta in
                    let deudaDeEstaTarjeta = calcularDeuda(de: tarjeta)
                    
                    // SectorMark es el componente para gráficas de pastel/dona
                    SectorMark(
                        angle: .value("Deuda", deudaDeEstaTarjeta),
                        innerRadius: .ratio(0.65), // Esto hace el hueco del centro (dona)
                        angularInset: 2.0 // Esto separa las rebanadas ligeramente
                    )
                    // Pintamos la rebanada del mismo color que la tarjeta física
                    .foregroundStyle(Color(hex: tarjeta.color))
                    .cornerRadius(4)
                }
                // Forzamos la altura de la gráfica
                .frame(height: 220)
                .padding(.horizontal)
            } else {
                // Estado vacío elegante si no hay deudas
                ContentUnavailableView(
                    "Todo al corriente",
                    systemImage: "checkmark.seal.fill",
                    description: Text("No tienes deudas registradas en tus tarjetas.")
                )
            } // fin del if else
            
            if sumaDeuda > 0 {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Desglose")
                        .font(.title3.bold())
                        .padding(.horizontal)
                    
                    // Una lista limpia con el detalle de cada tarjeta
                    VStack(spacing: 0) {
                        ForEach(tarjetas) { tarjeta in
                            let deudaTarjeta = calcularDeuda(de: tarjeta)
                            
                            if deudaTarjeta > 0 {
                                HStack {
                                    // Circulito del color de la tarjeta
                                    Circle()
                                        .fill(Color(hex: tarjeta.color))
                                        .frame(width: 12, height: 12)
                                    
                                    Text(tarjeta.banco)
                                        .font(.body)
                                    
                                    Spacer()
                                    
                                    Text(deudaTarjeta, format: .currency(code: "MXN"))
                                        .bold()
                                } // fin del hstack
                                .padding()
                                Divider() // Línea separadora
                            } // fin del if
                        } // fin del foreach
                    } // fin del vstack
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                } // fin del vstack
            } // fin del if
        } // fin del vstack
    }
    
    // Método auxiliar para obtener la deuda en formato Double
    func calcularDeuda(de tarjeta: Tarjeta) -> Double {
        let acumulado = tarjeta.compras.reduce(0) { $0 + $1.monto }
        return Double(acumulado) / 100.0
    }
}

#Preview {
    DeudaView()
        .modelContainer(for: Tarjeta.self, inMemory: true)
}
