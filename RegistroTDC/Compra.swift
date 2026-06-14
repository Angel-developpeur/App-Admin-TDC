//
//  Compra.swift
//  RegistroTDC
//
//  Created by angel hernandez on 10/06/26.
//

//
import Foundation
import SwiftData
import SwiftUI

@Model
class Compra{
    
    @Attribute(.unique) var id: UUID
    
    var monto: Int
    var descripcion: String
    var meses_sin_intereses: Int
    var fecha: Date
    
    // NUEVO: La relación inversa (Una compra pertenece a UNA tarjeta)
    // No usamos @Relationship aquí porque SwiftData lo infiere de la clase Tarjeta.
    var tarjeta: Tarjeta?
    
    init(monto: Int, descripcion: String, meses_sin_intereses: Int, fecha: Date = Date()){
        self.id = UUID()
        self.monto = monto
        self.descripcion = descripcion
        self.meses_sin_intereses = meses_sin_intereses
        self.fecha = fecha
    }
    
}
