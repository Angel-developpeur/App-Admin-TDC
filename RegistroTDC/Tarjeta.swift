//
//  Tarjeta.swift
//  RegistroTDC
//
//  Created by angel hernandez on 07/06/26.
//
import Foundation
import SwiftData
import SwiftUI

@Model //indicamos que se trata de un mdoelo
class Tarjeta {
    var banco: String
    var ultimosDigitos: String
    var tipo: String
    var color: String
    var limiteCredito: Double
    
    //contructor
    init(banco: String, ultimosDigitos: String, tipo: String, color: String, limiteCrdito: Double){
        self.banco = banco
        self.tipo = tipo
        self.color = color
        self.ultimosDigitos = ultimosDigitos
        self.limiteCredito = limiteCrdito
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
                return "gh" // Retorna vacío si es otro tipo
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


