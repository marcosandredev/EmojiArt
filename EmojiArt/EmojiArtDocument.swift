//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Marcos André Novaes de Lara on 16/04/22.
//
//  ViewModel

import SwiftUI

class EmojiArtDocument: ObservableObject {
  @Published private(set) var emojiArt: EmojiArtModel {
    didSet {
      if emojiArt.background != oldValue.background {
        fetchBackgroundImageDataIfNecessary()
      }
    }
  }
  
  init() {
    emojiArt = EmojiArtModel()
    emojiArt.addEmoji("😄", at: (-200, -100), size: 80)
    emojiArt.addEmoji("😷", at: (50, 100), size: 40)
  }
  
  var emojis: [EmojiArtModel.Emoji] {
    emojiArt.emojis
  }
  
  var background: EmojiArtModel.Background {
    emojiArt.background
  }
  
  @Published var backgroundImage: UIImage?
  @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
  
  enum BackgroundImageFetchStatus {
    case idle
    case fetching
  }
  
  private func fetchBackgroundImageDataIfNecessary() {
    backgroundImage = nil
    switch emojiArt.background {
      case .url(let url):
        // fetch the url
        backgroundImageFetchStatus = .fetching
        DispatchQueue.global(qos: .userInitiated).async { // Multithreading, ser executado em uma thread de segundo plano e não na principal, para ser mais rápido o processo de download da imagem
          let imageData = try? Data(contentsOf: url) // try? significa tente ou retorne nil, assim não ocasiona erro
          DispatchQueue.main.async {[weak self] in // Published só pode ser feito na thread principal, mudanças na view, weak = redefinir qualquer variavel para ter uma nova versão dela, apenas dentro desse trecho de código, transformando o self em optional, não se mantém na memória
            if self?.emojiArt.background == EmojiArtModel.Background.url(url) {
              self?.backgroundImageFetchStatus = .idle
              if imageData != nil {
                self?.backgroundImage = UIImage(data: imageData!)
              }
            }
          }
        }
      case .imageData(let data):
        backgroundImage = UIImage(data: data)
      case .blank:
        break
    }
  }
  
  // MARK: - Intent(s)
  
  func setBackground(_ background: EmojiArtModel.Background) {
    emojiArt.background = background
  }
  
  func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat) {
    emojiArt.addEmoji(emoji, at: location, size: Int(size))
  }
  
  func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
    if let index = emojiArt.emojis.index(matching: emoji) {
      emojiArt.emojis[index].x += Int(offset.width)
      emojiArt.emojis[index].y += Int(offset.height)
    }
  }
  
  func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
    if let index = emojiArt.emojis.index(matching: emoji) {
      emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
    }
  }
}
