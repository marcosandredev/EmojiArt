//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Marcos André Novaes de Lara on 16/04/22.
//
//  ViewModel

import SwiftUI
import Combine

class EmojiArtDocument: ObservableObject {
  @Published private(set) var emojiArt: EmojiArtModel {
    didSet {
      scheduleAutosave()
      if emojiArt.background != oldValue.background {
        fetchBackgroundImageDataIfNecessary()
      }
    }
  }
  
  private var autosaveTimer: Timer?
  
  private func scheduleAutosave() {
    autosaveTimer?.invalidate()
    autosaveTimer = Timer.scheduledTimer(withTimeInterval: Autosave.coalescingInterval, repeats: false) {
      _ in self.autosave()
    }
  }
  
  private struct Autosave {
    static let filename = "Autosaved.emojiart"
    static var url: URL? {
      let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first // First pq no Mac pode ter mais de um possível
      return documentDirectory?.appendingPathComponent(filename)
    }
    static let coalescingInterval = 5.0
  }
  
  private func autosave() {
    if let url = Autosave.url {
      save(to: url)
    }
  }
  
  private func save(to url: URL) {
    let thisfunction = "\(String(describing: self)).\(#function)"
    do {
      let data: Data = try emojiArt.json()
      print("\(thisfunction) json = \(String(data: data, encoding: .utf8) ?? "nil")")
      try data.write(to: url)
    } catch let encodingError where encodingError is EncodingError {
      print("\(thisfunction) couldn`t encode EmojiArt as JSON because \(encodingError.localizedDescription)")
    } catch {
      print("\(thisfunction) error = \(error)")
    }
  }
  
  init() {
    if let url = Autosave.url, let autosavedEmojiArt = try? EmojiArtModel(url: url) {
      emojiArt = autosavedEmojiArt
      fetchBackgroundImageDataIfNecessary()
    } else {
      emojiArt = EmojiArtModel()
        //emojiArt.addEmoji("😄", at: (-200, -100), size: 80)
        //emojiArt.addEmoji("😷", at: (50, 100), size: 40)
    }
  }
  
  var emojis: [EmojiArtModel.Emoji] {
    emojiArt.emojis
  }
  
  var background: EmojiArtModel.Background {
    emojiArt.background
  }
  
  // MARK: - Background
  
  @Published var backgroundImage: UIImage?
  @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
  
  enum BackgroundImageFetchStatus: Equatable {
    case idle
    case fetching
    case failed(URL)
  }
  
  private var backgroundImageFetchCancellable: AnyCancellable? // Importar Combine
  
  private func fetchBackgroundImageDataIfNecessary() {
    backgroundImage = nil
    switch emojiArt.background {
      case .url(let url):
        // fetch the url
        backgroundImageFetchStatus = .fetching
        backgroundImageFetchCancellable?.cancel()
        let session = URLSession.shared
        let publisher = session.dataTaskPublisher(for: url) // Pegar o editor de teste de dados para esta url
          .map{(data, urlResponse) in UIImage(data: data)} // Mapeando a URL para ser uma imagem
          .replaceError(with: nil) // Substituir quaisquer erros que receber por uma imagem de nil
          .receive(on: DispatchQueue.main) // Fazer tudo na fila principal
        
        backgroundImageFetchCancellable = publisher
          .sink { [weak self] image in
            self?.backgroundImage = image
            self?.backgroundImageFetchStatus = (image != nil) ? .idle : .failed(url)
          }
        
          //  .assign(to: \EmojiArtDocument.backgroundImage, on: self)
//        DispatchQueue.global(qos: .userInitiated).async { // Multithreading, ser executado em uma thread de segundo plano e não na principal, para ser mais rápido o processo de download da imagem
//          let imageData = try? Data(contentsOf: url) // try? significa tente ou retorne nil, assim não ocasiona erro
//          DispatchQueue.main.async {[weak self] in // Published só pode ser feito na thread principal, mudanças na view, weak = redefinir qualquer variavel para ter uma nova versão dela, apenas dentro desse trecho de código, transformando o self em optional, não se mantém na memória
//            if self?.emojiArt.background == EmojiArtModel.Background.url(url) {
//              self?.backgroundImageFetchStatus = .idle
//              if imageData != nil {
//                self?.backgroundImage = UIImage(data: imageData!)
//              }
//              if self?.backgroundImage == nil {
//                self?.backgroundImageFetchStatus = .failed(url)
//              }
//            }
//          }
//        }
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
