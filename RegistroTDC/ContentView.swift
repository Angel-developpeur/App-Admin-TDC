//Este archivo esta protegido por la licencia GPL, 2026

import SwiftUI
import SwiftData

struct ContentView: View {
    //Las varibles de estado se pone fuera del body
    @State private var mostrarFormulario = false //indica si se muestra el formulario de creacion de una tarjeta
    
    @Query var tarjetas: [Tarjeta] //listad de tarjetas almacenadas
    
   
    var body: some View {
        //menu de opciones
        TabView{
            //pestaña uno
            NavigationStack {
                ZStack {
                    Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                    ScrollView{
                        VStack{
                            if tarjetas.isEmpty {
                                //si no hay tarjetas mostrar un mensaje
                                ContentUnavailableView(
                                    "Sin Tarjetas",
                                    systemImage: "creditcard.and.123",
                                    description: Text("Toca el botón + para registrar tu primera tarjeta.")
                                )
                            } else {
                                ForEach(tarjetas) { tarjeta in
                                    
                                    NavigationLink{
                                    
                                        DetalleTarjetaView(tarjeta: tarjeta) //indicar a que vista nos vomeros a si como enviarle datos
                                    } label: {
                                        let colorFondo = Color(hex: tarjeta.color)
                                        HStack{
                                            VStack(alignment: .leading, spacing: 8){
                                                Text(tarjeta.banco).font(.headline)
                                                // ¡EL CAMBIO MÁGICO AQUÍ!
                                                    if tarjeta.nombreLogo.isEmpty {
                                                        // Si no hay logo para este tipo, mostramos el texto como antes
                                                        Text(tarjeta.tipo)
                                                            .font(.subheadline)
                                                            .opacity(0.8)
                                                    } else {
                                                        // Si tenemos el logo, lo pintamos
                                                        Image(tarjeta.nombreLogo)
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: 20) // Altura fija para mantener el diseño consistente
                                                    }
                                            }
                                            Spacer()
                                            Text("•••• \(tarjeta.ultimosDigitos)").font(.system(.body, design:.monospaced))
                                        }
                                        // SOLUCIÓN 2: Forzar todo el texto interno a blanco
                                        .foregroundStyle(colorFondo.textoIdeal)
                                            
                                        .padding(20)
                                        
                                        // 3. Pintamos el fondo
                                        .background(colorFondo)
                                        
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                    }.buttonStyle(.plain)
                                    
                                   
                                    
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                }
                
                 // 2. Este es el contenido de tu pantalla actual
                
                }
                 // 3. ¡AQUÍ ESTÁ EL TRUCO! Los modificadores van en el contenido interno, no en el stack
                .navigationTitle("Mis Tarjetas")
                 .toolbar {
                     ToolbarItem(placement: .topBarTrailing) {
                         // 4. Sintaxis correcta del Botón: Acción y Etiqueta (Label)
                         Button {
                             //activamos el estado de muestra a true
                             mostrarFormulario = true
                         } label: {
                             Image(systemName: "plus")
                         }
                     }
                 }
                //agrega sheet para el formulario
                 .sheet(isPresented: $mostrarFormulario) {
                    //llamar a la vista del formulario
                     FormularioTarjetaView()
                }
             }//cierre del navigation stack
            .tabItem { //indicamos que este fragmento de codigo sera una pestana en la lista de opciones, con dicho nombre y icono
                 Label("Tarjetas", systemImage: "creditcard")
             }// Fin del NavigationStack
            .tag(1) // con tag le indicamos que este es la opcion 1
            
            //un texto sera la visa dos
            VStack{
                var totalDeuda: Int {
                    var suma = 0
                    for tarjeta in tarjetas {
                        for compra in tarjeta.compras {
                            suma += compra.monto
                        }
                    }
                    return suma
                }
                Text("Deuda total de todas las compras : " + String(totalDeuda))
            }//fin del vstal
            .tabItem {
                Label("Deuda", systemImage: "dollarsign")
            }

        }.tint(.blue)
        // 1. El NavigationStack envuelve a toda la pantalla
       
    }
       
}

// 5. Creamos una vista separada para mantener el código ordenado
struct FormularioTarjetaView: View {
    @Environment(\.dismiss) var dismiss
    
    //acceder al contexto de swiftData
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
    
    // Esta variable será 'true' solo si el banco no está vacío
    // y si los últimos dígitos son exactamente 4.
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
                    Slider(value: $limiteCredito, in: 3000...50000, step: 100)
                    TextField("Credito usado", text: $creditoUsado).keyboardType(.numberPad)
                    TextField("Nip", text: $nip)
                    Picker("Día de corte", selection: $diaDeCorte) {
                                            ForEach(1...31, id: \.self) { dia in
                                                // El .tag() es crucial para que el Picker sepa qué valor asignar
                                                Text("\(dia)").tag(dia)
                                            }
                                        }
                                        // Opcional: Le da un estilo de menú desplegable nativo en iOS 16+
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
                        // crear un obtjeto de tipo tarjeta
                        let nuevaTarjeta = Tarjeta(
                            banco: banco,
                            ultimosDigitos: ultimosDigitos,
                            tipo: tipoSeleccionado,
                            color: colorDeTarjeta.toHex(),
                            limiteCrdito: limiteCredito,
                            nip: nip,
                            diaDeCorte: diaDeCorte,
                            creditoUsado: Int((Double(creditoUsado) ?? 0)) * 100,
                            
                        )
                        //insertamo el objeto en la memoria local
                        modelContext.insert(nuevaTarjeta)
                        
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

#Preview {
    ContentView()
}
