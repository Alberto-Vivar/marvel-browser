//
//  NetworkManager.swift
//  Marvel Browser
//
//  Created by Alberto Vivar Arribas on 18/4/22.
//

import Foundation
import Alamofire
import Combine
import CryptoKit

class NetworkManager {

    public static var instance: NetworkManager = .init()

    private var sessionManager: Alamofire.Session

    private init() {
        self.sessionManager = .init()
    }

    // MARK: - Auxiliary methods.

    /// Generic call to an Alamofire request method. Avoid multiple boilerplate code.
    ///
    /// - Parameters:
    ///   - url: Description of the
    ///   - method: HTTP method used for the request.
    ///   - encoding: Encoding used for the parameters.
    ///   - parameters: Used parameters for the request (if any).
    private func request <T: Decodable> (url: URLEnum,
                         method: HTTPMethod,
                         encoding: ParameterEncoding = URLEncoding.default,
                          parameters: Parameters? = nil) -> DataResponsePublisher<T> {
        self.sessionManager
            .request(url.get(),
                     method: method,
                     parameters: parameters,
                     encoding: encoding,
                     interceptor: nil,
                     requestModifier: nil)
            .publishDecodable(
                type: T.self,
                queue: .global(qos: .background))
    }

    private enum URLEnum: String {
        case characters = "/v1/public/characters"
        func get() -> URL {
            return .init(string: self.rawValue, relativeTo: .init(string: "https://gateway.marvel.com")!)!
        }
    }
}

extension JSONDecoder {
    static var `default`: JSONDecoder {
        let decoder = JSONDecoder.init()
        decoder.dateDecodingStrategy = .formatted(.init())
        return decoder
    }
}

extension NetworkManager {
    public func getCharacterList() -> DataResponsePublisher<CharacterListResponse> {
        self.request(url: .characters,
                     method: .get,
                     encoding: JSONEncoding.default,
                     parameters: nil)
    }
}

protocol CharacterFetchable {
    func characterList() -> AnyPublisher<CharacterListResponse, CharacterError>
}

class CharacterFetcher {
  private let session: URLSession

  init(session: URLSession = .shared) {
    self.session = session
  }
}

// MARK: - ChatacterFetchable

extension CharacterFetcher: CharacterFetchable {
    func characterList() -> AnyPublisher<CharacterListResponse, CharacterError> {
        return self.publicRequest(with: self.makeCharacterComponents())
    }

  private func publicRequest<T>(with components: URLComponents) -> AnyPublisher<T, CharacterError> where T: Decodable {
    guard let url = components.url else {
      let error = CharacterError.network(description: "Couldn't create URL")
      return Fail(error: error).eraseToAnyPublisher()
    }
      return self.session.dataTaskPublisher(for: URLRequest(url: url))
      .mapError { error in
        .network(description: error.localizedDescription)
      }
      .flatMap(maxPublishers: .max(1)) { pair in
        decode(pair.data)
      }
      .eraseToAnyPublisher()
  }
}

// MARK: - OpenWeatherMap API
private extension CharacterFetcher {
    struct OpenWeatherAPI {
        static let scheme = "https"
        static let host = "gateway.marvel.com"
        static let path = "/v1/public"
        static let privateAPIKey = "your_private_key"
        static let publicAPIKey = "your_public_key"
    }

    func makeCharacterComponents() -> URLComponents {
        var components: URLComponents = .init()
        components.scheme = OpenWeatherAPI.scheme
        components.host = OpenWeatherAPI.host
        components.path = OpenWeatherAPI.path + "/characters"

        let timestamp = "1"
        let hash = Insecure.MD5.hash(data: "\(timestamp)\(OpenWeatherAPI.privateAPIKey)\(OpenWeatherAPI.publicAPIKey)".data(using: .utf8)!)

        components.queryItems = [
            .init(name: "ts", value: timestamp),
            .init(name: "apikey", value: OpenWeatherAPI.publicAPIKey),
            .init(name: "hash", value: hash
                .map {String.init(format: "%02hhx", $0)}
                .joined()
            ),
        ]

        return components
    }
}

enum CharacterError: Error {
  case parsing(description: String)
  case network(description: String)
}

func decode<T: Decodable>(_ data: Data) -> AnyPublisher<T, CharacterError> {
  let decoder = JSONDecoder()
  decoder.dateDecodingStrategy = .iso8601

  return Just(data)
    .decode(type: T.self, decoder: decoder)
    .mapError { error in
      .parsing(description: error.localizedDescription)
    }
    .eraseToAnyPublisher()
}

struct CharacterRowViewModel {
    private let item: CharacterListResponse.CharacterList.Character

    var image: URL? {
        return URL.init(string: item.thumbnail.path + item.thumbnail.extension)
    }

    init(item: CharacterListResponse.CharacterList.Character) {
        self.item = item
    }
}
