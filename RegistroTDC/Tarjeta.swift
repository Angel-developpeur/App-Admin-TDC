//
//  Tarjeta.swift
//  RegistroTDC
//
//  Created by angel hernandez on 07/06/26.
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
import Foundation
import SwiftData
import SwiftUI

@Model //indicamos que se trata de un mdoelo
class Tarjeta {
    //crear id
    @Attribute(.unique) var id: UUID
    
    //atributos de una tarjeta
    var banco: String
    var ultimosDigitos: String
    var tipo: String
    var color: String
    var limiteCredito: Int
    var nip: String
    var diaDeCorte: Int
    var creditoUsado: Int
    
    //relaciones
    @Relationship(deleteRule: .cascade) var compras: [Compra] = []
    
    //contructor
    init(banco: String, ultimosDigitos: String, tipo: String, color: String, limiteCrdito: Int, nip: String, diaDeCorte: Int, creditoUsado: Int){
        self.id = UUID() // Inicializamos el ID único
        self.banco = banco
        self.tipo = tipo
        self.color = color
        self.ultimosDigitos = ultimosDigitos
        self.limiteCredito = limiteCrdito
        self.nip = nip
        self.creditoUsado = creditoUsado
        self.diaDeCorte = diaDeCorte
    }
    
    var nombreLogo: String {
            // Convertimos a minúsculas para evitar errores si el usuario escribió "VISA" o "Visa"
            switch tipo.lowercased() {
            case "visa":
                return "Visa-Logo"
            case "mastercard":
                return "Mastercard-Logo"
            case "american express":
                return "American-Express-Logo"
            default:
                return "" // Retorna vacío si es otro tipo
            }
        }
}

extension Color {
    // 1. Convierte un Color visual a un texto para la base de datos
    func toHex() -> String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let r = Int(red * 255.0)
        let g = Int(green * 255.0)
        let b = Int(blue * 255.0)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
    
    // 2. Reconstruye el Color visual leyendo el texto de la base de datos
    init(hex: String) {
        let hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
    
    var textoIdeal: Color {
            // 1. Convertimos a UIColor para poder extraer los canales RGB
            let uiColor = UIColor(self)
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            
            uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            // 2. Aplicamos la fórmula estándar de luminancia relativa
            let luminancia = (0.299 * red) + (0.587 * green) + (0.114 * blue)
            
            // 3. Si la luminancia es mayor a 0.5 (fondo claro), devolvemos negro.
            // Si es menor (fondo oscuro), devolvemos blanco.
            return luminancia > 0.5 ? .black : .white
        }
}


