//
//  FormularioTarjetaView.swift
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

struct FormularioTarjetaView: View {
    @Environment(\.dismiss) var dismiss
    
    // Acceder al contexto de SwiftData
    @Environment(\.modelContext) private var modelContext
    
    // Variables de estado para capturar los datos
    @State private var banco = ""
    @State private var ultimosDigitos = ""
    @State private var tipoSeleccionado = "Visa"
    @State private var esPrincipal = false
    @State private var limiteCredito: Double = 10000
    @State private var colorDeTarjeta: Color = .blue
    @State private var nip = ""
    @State private var diaDeCorte: Int = 0
    @State private var creditoUsado = ""
    
    let tipos = ["Visa", "MasterCard", "American Express"]
    
    // Esta variable será 'true' solo si el formulario tiene datos válidos
    var formularioEsValido: Bool {
        !banco.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        ultimosDigitos.count == 4 &&
        !diaDeCorte.description.isEmpty &&
        nip.trimmingCharacters(in: .whitespacesAndNewlines).count == 4
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Datos de Identificación")) {
                    TextField("Nombre del Banco *", text: $banco)
                    TextField("Últimos 4 dígitos *", text: $ultimosDigitos)
                        .keyboardType(.numberPad)
                    ColorPicker("Color de identificación", selection: $colorDeTarjeta)
                }
                
                Section(header: Text("Configuración")) {
                    Picker("Tipo", selection: $tipoSeleccionado) {
                        ForEach(tipos, id: \.self) { Text($0).tag($0) }
                    }
                    Stepper("Límite: $\(limiteCredito, specifier: "%.0f")", value: $limiteCredito, step: 100)
                    
                    // Slider: Barra deslizable
                    Slider(value: $limiteCredito, in: 3000...500000, step: 100)
                    TextField("Credito usado", text: $creditoUsado).keyboardType(.numberPad)
                    TextField("Nip", text: $nip).keyboardType(.numberPad)
                    Picker("Día de corte", selection: $diaDeCorte) {
                        ForEach(1...31, id: \.self) { dia in
                            Text("\(dia)").tag(dia)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("Nueva Tarjeta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Guardar") {
                        // Crear un objeto de tipo tarjeta
                        let nuevaTarjeta = Tarjeta(
                            banco: banco,
                            ultimosDigitos: ultimosDigitos,
                            tipo: tipoSeleccionado,
                            color: colorDeTarjeta.toHex(),
                            limiteCrdito: limiteCredito,
                            nip: nip,
                            diaDeCorte: diaDeCorte,
                            creditoUsado: Int((Double(creditoUsado) ?? 0)) * 100
                        )
                        // Insertamos el objeto en SwiftData
                        modelContext.insert(nuevaTarjeta)
                        
                        dismiss()
                    }
                    .bold()
                    .disabled(!formularioEsValido)
                }
            }
        }
    }
}

#Preview {
    FormularioTarjetaView()
        .modelContainer(for: Tarjeta.self, inMemory: true)
}
