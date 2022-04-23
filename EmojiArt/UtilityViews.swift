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

// um botão que desfaz (preferido) ou refaz
// também tem um menu de contexto que será exibido
// a descrição de desfazer ou refazer fornecida para cada

struct UndoButton: View {
  let undo: String?
  let redo: String?
  
  @Environment(\.undoManager) var undoManager
  
  var body: some View {
    let canUndo = undoManager?.canUndo ?? false
    let canRedo = undoManager?.canRedo ?? false
    if canUndo || canRedo {
      Button {
        if canUndo {
          undoManager?.undo()
        } else {
          undoManager?.redo()
        }
      } label: {
        if canUndo {
          Image(systemName: "arrow.uturn.backward.circle")
        } else {
          Image(systemName: "arrow.uturn.forward.circle")
        }
      }
      .contextMenu {
        if canUndo {
          Button {
            undoManager?.undo()
          } label: {
            Label(undo ?? "Undo", systemImage: "arrow.uturn.backward")
          }
        }
        if canRedo {
          Button {
            undoManager?.redo()
          } label: {
            Label(redo ?? "Redo", systemImage: "arrow.uturn.forward")
          }
        }
      }
    }
  }
}

extension UndoManager {
  var optionalUndoMenuItemTitle: String? {
    canUndo ? undoMenuItemTitle : nil
  }
  var optionalRedoMenuItemTitle: String? {
    canRedo ? redoMenuItemTitle : nil
  }
}
