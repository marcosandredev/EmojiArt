//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Marcos André Novaes de Lara on 16/04/22.
//

import SwiftUI

@main
struct EmojiArtApp: App {
  let document = EmojiArtDocument()
  
  var body: some Scene {
      WindowGroup {
          EmojiArtDocumentView(document: document)
      }
  }
}
