//
//  DetalleTarjetaView.swift
//  RegistroTDC
//
//  Created by angel hernandez on 10/06/26.
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

struct DetalleTarjetaView: View {
    let tarjeta: Tarjeta
    @State private var mostrarFormularioCompra = false
    @State private var mostrarFormularioPago = false
    
    var totalCompras: Double {
        return Double(tarjeta.creditoUsado) / 100.0
    }
    
    var body: some View {
        let sumaCompras = totalCompras
        List {
            
            // SECCIÓN 1: Deuda Total (Header destacado)
            Section {
                VStack(spacing: 20) {
                    
                    // --- PARTE SUPERIOR: TEXTOS DE DEUDA ---
                    VStack(spacing: 8) {
                        Text("Deuda Total")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(sumaCompras, format: .currency(code: "MXN"))
                            .font(.largeTitle)
                            .bold()
                    }
                    
                    // --- PARTE INFERIOR: BARRA HORIZONTAL ---
                    let limiteReal = Double(tarjeta.limiteCredito) / 100.0
                    Gauge(value: sumaCompras, in: 0...limiteReal) {
                        Text("Límite de crédito")
                            .font(.caption)
                    } currentValueLabel: {
                        EmptyView()
                    } minimumValueLabel: {
                        Text(0, format: .currency(code: "MXN"))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    } maximumValueLabel: {
                        Text(limiteReal, format: .currency(code: "MXN"))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .tint(Gradient(colors: [.green, .yellow, .red]))
                    
                    
                }
                .padding(.vertical, 8)
            }
            .listRowBackground(Color.clear)
            
            // SECCIÓN 2: Información/Configuración de la tarjeta
            Section {
                NavigationLink {
                    PantallaBloqueoView(razon: String(localized: "Desbloquea para ver el NIP")) {
                        NipView(tarjeta: tarjeta)
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "creditcard")
                            .foregroundStyle(.blue)
                        Text("Información de la tarjeta")
                            .font(.body)
                    }
                }
            }
            
            // SECCIÓN 3: Historial de movimientos
            Section(header: Text("Historial de Movimientos")) {
                if tarjeta.compras.isEmpty {
                    ContentUnavailableView(
                        "Sin movimientos",
                        systemImage: "bag",
                        description: Text("No has registrado ningún movimiento.")
                    )
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(tarjeta.compras.sorted(by: { $0.fecha > $1.fecha })) { compra in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(compra.descripcion)
                                    .font(.headline)
                                
                                Text(compra.fecha.formatted(date: .abbreviated, time: .omitted))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            let montoReal = Double(compra.monto) / 100.0
                            Text(montoReal, format: .currency(code: "MXN"))
                                .bold()
                                .foregroundColor(compra.monto < 0 ? .green : .primary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Detalles")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        mostrarFormularioCompra = true
                    } label: {
                        Label("Registrar Compra", systemImage: "plus.circle")
                    }
                    Button {
                        mostrarFormularioPago = true
                    } label: {
                        Label("Registrar Pago", systemImage: "checkmark.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $mostrarFormularioCompra) {
            FormularioCompraView(tarjeta: tarjeta)
        }
        .sheet(isPresented: $mostrarFormularioPago) {
            FormularioPagoView(tarjeta: tarjeta)
        }
    }
}

struct FormularioCompraView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let tarjeta: Tarjeta
    
    @State private var descripcion = ""
    @State private var monto = ""
    @State private var meses_sin_intereses = ""
    
    var formularioEsValido: Bool {
        !descripcion.isEmpty && !monto.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Datos de compra")) {
                    TextField("Descripción", text: $descripcion)
                    TextField("Monto", text: $monto)
                        .keyboardType(.decimalPad)
                    TextField("Meses sin intereses", text: $meses_sin_intereses)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Registrar Compra")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Guardar") {
                        let montoSanitizado = monto.replacingOccurrences(of: ",", with: ".")
                        let montoDouble = Double(montoSanitizado) ?? 0.0
                        let monto_format = Int(round(montoDouble * 100.0))
                        
                        let nuevaCompra = Compra(
                            monto: monto_format,
                            descripcion: descripcion,
                            meses_sin_intereses: Int(meses_sin_intereses) ?? 0
                        )
                        
                        nuevaCompra.tarjeta = tarjeta
                        tarjeta.creditoUsado += monto_format
                        
                        modelContext.insert(nuevaCompra)
                        dismiss()
                    }
                    .bold()
                    .disabled(!formularioEsValido)
                }
            }
        }
    }
}

struct FormularioPagoView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let tarjeta: Tarjeta
    
    @State private var descripcion = String(localized: "Pago de tarjeta")
    @State private var monto = ""
    @State private var fecha = Date()
    
    var formularioEsValido: Bool {
        !descripcion.isEmpty && !monto.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Datos del pago")) {
                    TextField("Descripción", text: $descripcion)
                    TextField("Monto", text: $monto)
                        .keyboardType(.decimalPad)
                    DatePicker("Fecha", selection: $fecha, displayedComponents: .date)
                }
            }
            .navigationTitle("Registrar Pago")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Guardar") {
                        let montoSanitizado = monto.replacingOccurrences(of: ",", with: ".")
                        let montoDouble = Double(montoSanitizado) ?? 0.0
                        let montoCentavos = Int(round(montoDouble * 100.0))
                        
                        let nuevoPago = Compra(
                            monto: -montoCentavos,
                            descripcion: descripcion,
                            meses_sin_intereses: 0,
                            fecha: fecha
                        )
                        
                        nuevoPago.tarjeta = tarjeta
                        tarjeta.creditoUsado -= montoCentavos
                        
                        modelContext.insert(nuevoPago)
                        dismiss()
                    }
                    .bold()
                    .disabled(!formularioEsValido)
                }
            }
        }
    }
}
