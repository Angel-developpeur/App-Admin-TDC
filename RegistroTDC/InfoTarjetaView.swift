//
//  InfoTarjeta.swift
//  RegistroTDC
//
//  Created by angel hernandez on 16/06/26.
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


struct InfoTarjetaView: View {
    
    let tarjeta: Tarjeta
    
    var body: some View {
            Text(String(tarjeta.nip.reversed()))
                .navigationTitle("Info")
        
    }
}

