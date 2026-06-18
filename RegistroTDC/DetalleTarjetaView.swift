//
//  DetalleTarjetaView.swift
//  RegistroTDC
//
//  Created by angel hernandez on 10/06/26.
//

import SwiftUI
import SwiftData

struct DetalleTarjetaView: View {
    let tarjeta: Tarjeta
    @State private var mostrarFormulario = false
    
    var totalCompras: Double {
        // Hacemos la matemática directamente devolviendo el Double listo para mostrar
        let acumulado = tarjeta.compras.reduce(0) { $0 + $1.monto }
        return Double(acumulado) / 100.0
    }
    
    
    
    var body: some View {
        // Eliminamos los VStacks exteriores y usamos una sola List nativa
        List {
            
            // SECCIÓN 1: Deuda Total (Header destacado)
            Section {
                // 1. Usamos un VStack principal para que todo vaya de arriba hacia abajo
                VStack(spacing: 20) {
                    
                    // --- PARTE SUPERIOR: TEXTOS DE DEUDA ---
                    VStack(spacing: 8) {
                        Text("Deuda Total")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(totalCompras, format: .currency(code: "MXN"))
                            .font(.largeTitle)
                            .bold()
                    }
                    
                    // --- PARTE INFERIOR: BARRA HORIZONTAL ---
                    // 2. ¡MUY IMPORTANTE! Agregamos el 'in: 0...tarjeta.limiteCredito'
                    Gauge(value: totalCompras, in: 0...tarjeta.limiteCredito) {
                        Text("Límite de crédito")
                            .font(.caption)
                    } currentValueLabel: {
                        EmptyView() // Lo dejamos vacío porque el total ya está en grande arriba
                    } minimumValueLabel: {
                        Text(0, format: .currency(code: "MXN")) // Formato de moneda para el 0
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    } maximumValueLabel: {
                        // Formato de moneda para el límite (evita que se vea como 24300.0)
                        Text(tarjeta.limiteCredito, format: .currency(code: "MXN"))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    // Opcional: Le regresamos el gradiente de colores para que se vea más pro
                    .tint(Gradient(colors: [.green, .yellow, .red]))
                }
                .padding(.vertical, 8)
            }
            .listRowBackground(Color.clear)
            
            // SECCIÓN 2: Información/Configuración de la tarjeta
            Section {
                NavigationLink {
                    PantallaBloqueoNip(tarjeta: tarjeta)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "creditcard") // Un icono le da un toque más pro
                            .foregroundStyle(.blue)
                        Text("Información de la tarjeta")
                            .font(.body)
                    }
                }
                
            }
            
            // SECCIÓN 3: Historial de compras
            Section(header: Text("Historial de Compras")) {
                if tarjeta.compras.isEmpty {
                    // Si está vacío, mostramos un aviso limpio dentro de la fila
                    ContentUnavailableView(
                        "Sin compras",
                        systemImage: "bag",
                        description: Text("No has registrado ningún movimiento.")
                    )
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(tarjeta.compras) { compra in
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
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        // Puedes cambiar el estilo de la lista si quieres experimentar (.insetGrouped es el clásico de Ajustes de iOS)
        .listStyle(.insetGrouped)
        .navigationTitle("Compras")
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
            FormularioCompraView(tarjeta: tarjeta)
        }
    }
}

struct FormularioCompraView: View {
    @Environment(\.dismiss) var dismiss
    
    //acceder al contexto de swiftData
    @Environment(\.modelContext) private var modelContext
    
    let tarjeta: Tarjeta
    
    @State private var descripcion = ""
    @State private var monto = ""
    @State private var meses_sin_intereses = ""
    
    //validar que se ingresara una descripcion y un monto
    var formularioEsValido:Bool{
        !descripcion.isEmpty && !monto.isEmpty
    }
    
    
    
    var body: some View {
        NavigationStack {
            //formulario de registro
            Form {
                Section(header: Text("Datos de compra")) {
                    TextField("Descripcion", text: $descripcion)
                    TextField("Monto", text: $monto)
                        .keyboardType(.numberPad)
                    TextField("Meses sin intereses", text: $meses_sin_intereses)
                        .keyboardType(.numberPad)
                }//fin de la seccion
                
               
            }//fin del formulario de registro
            .navigationTitle("Registrar Compra")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                //boton de cancelar
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                //boton de guardar
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Guardar") {
                        let monto_format = Int( (Double(monto) ?? 0) * 100)
                        // crear un obtjeto de tipo tarjeta
                        let nuevaCompra = Compra(
                            monto: monto_format,
                            descripcion: descripcion,
                            meses_sin_intereses: Int(meses_sin_intereses) ?? 0
                        )
                        
                        nuevaCompra.tarjeta = tarjeta
                        //insertamo el objeto en la memoria local
                        modelContext.insert(nuevaCompra)
                        
                        dismiss()
                        
                       
                    }
                    .bold()
                    // Podemos deshabilitar el botón si no han llenado los datos
                    .disabled(!formularioEsValido)
                }
            }
        }
    }
}
