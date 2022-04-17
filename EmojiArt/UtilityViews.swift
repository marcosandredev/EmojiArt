//
//  UtilityViews.swift
//  EmojiArt
//
//  Created by CS193p Instructor on 4/26/21.
//  Copyright © 2021 Stanford University. All rights reserved.
//

import SwiftUI

// syntactic com certeza será capaz de passar uma UIImage opcional para a Imagem
// (normalmente, levaria apenas uma UIImage não opcional)

struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        if uiImage != nil {
            Image(uiImage: uiImage!)
        }
    }
}

// açúcar sintático
// muitas vezes queremos um botão simples
// com apenas texto ou um rótulo ou um systemImage
// mas queremos que a ação que ele executa seja animada
// (ou seja, com Animação)
// isso só facilita a criação de tal botão
// e assim limpa nosso código

struct AnimatedActionButton: View {
    var title: String? = nil
    var systemImage: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button {
            withAnimation {
                action()
            }
        } label: {
            if title != nil && systemImage != nil {
                Label(title!, systemImage: systemImage!)
            } else if title != nil {
                Text(title!)
            } else if systemImage != nil {
                Image(systemName: systemImage!)
            }
        }
    }
}

// estrutura simples para facilitar a exibição de alertas configuráveis
// apenas uma estrutura identificável que pode criar um Alerta sob demanda
// use .alert(item: $alertToShow) { theIdentifiableAlert em ... }
// onde alertToShow é uma Vinculação<IdentifiableAlert>?
// então sempre que você quiser mostrar um alerta
// basta definir alertToShow = IdentifiableAlert(id: "meu alerta") { Alert(title: ...) }
// é claro, o identificador de string tem que ser exclusivo para todos os seus diferentes tipos de alertas

struct IdentifiableAlert: Identifiable {
    var id: String
    var alert: () -> Alert
}
