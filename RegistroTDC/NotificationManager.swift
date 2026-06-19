//
//  NotificationManager.swift
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

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // Solicitar permisos de notificación al usuario
    func solicitarPermiso() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { concedido, error in
            if concedido {
                print("Permisos de notificaciones locales concedidos.")
            } else if let error = error {
                print("Error al solicitar permisos de notificación: \(error.localizedDescription)")
            }
        }
    }
    
    // Programar una notificación mensual para el día de corte de una tarjeta
    func programarNotificacionCorte(para tarjeta: Tarjeta) {
        let center = UNUserNotificationCenter.current()
        
        let contenido = UNMutableNotificationContent()
        contenido.title = String(localized: "Día de corte: \(tarjeta.banco)")
        contenido.body = String(localized: "Hoy es el día de corte de tu tarjeta que termina en \(tarjeta.ultimosDigitos).")
        contenido.sound = .default
        
        // Configurar los componentes de la fecha para que se dispare mensualmente en el diaDeCorte a las 9:00 AM
        var componentes = DateComponents()
        componentes.day = tarjeta.diaDeCorte
        componentes.hour = 9
        componentes.minute = 0
        
        let disparador = UNCalendarNotificationTrigger(dateMatching: componentes, repeats: true)
        
        // El identificador único basado en el UUID de la tarjeta previene duplicados
        let identificador = "corte-\(tarjeta.id.uuidString)"
        let peticion = UNNotificationRequest(identifier: identificador, content: contenido, trigger: disparador)
        
        // Removemos cualquier notificación vieja programada con este ID antes de agregar la nueva
        center.removePendingNotificationRequests(withIdentifiers: [identificador])
        
        center.add(peticion) { error in
            if let error = error {
                print("Error al programar la notificación de corte para \(tarjeta.banco): \(error.localizedDescription)")
            } else {
                print("Notificación de corte programada para \(tarjeta.banco) el día \(tarjeta.diaDeCorte) del mes.")
            }
        }
    }
    
    // Sincronizar todas las notificaciones para asegurarse de que todas las tarjetas tengan su alerta programada
    func sincronizarNotificaciones(con tarjetas: [Tarjeta]) {
        for tarjeta in tarjetas {
            programarNotificacionCorte(para: tarjeta)
        }
    }
    
    // Cancelar la notificación asociada a una tarjeta específica (ej. al borrarla)
    func cancelarNotificacionCorte(para tarjeta: Tarjeta) {
        let center = UNUserNotificationCenter.current()
        let identificador = "corte-\(tarjeta.id.uuidString)"
        center.removePendingNotificationRequests(withIdentifiers: [identificador])
        print("Notificación de corte cancelada para \(tarjeta.banco).")
    }
}
