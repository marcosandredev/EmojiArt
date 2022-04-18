//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Marcos André Novaes de Lara on 16/04/22.
//

import SwiftUI

@main
struct EmojiArtApp: App {
  @StateObject var document = EmojiArtDocument()
  @StateObject var paletteStore = PaletteStore(named: "Default")
  
  var body: some Scene {
      WindowGroup {
          EmojiArtDocumentView(document: document)
          .environmentObject(paletteStore) // Usar em todas as telas
      }
  }
}
