//
//  InfoTarjeta.swift
//  RegistroTDC
//
//  Created by angel hernandez on 16/06/26.
//

import SwiftUI
import SwiftData


struct InfoTarjeta: View {
    
    let tarjeta: Tarjeta
    
    var body: some View {
        
        
            Text(String(tarjeta.nip.reversed()))
                .navigationTitle("Info")
        
    }
}

