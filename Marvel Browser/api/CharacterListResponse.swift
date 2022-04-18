//
//  CharacterListResponse.swift
//  Marvel Browser
//
//  Created by Alberto Vivar Arribas on 18/4/22.
//

import Foundation

struct CharacterListResponse: Decodable {
    let code: Int
    let status: String
    let copyright: String
    let attributionText: String
    let attributionHTML: String
    let data: CharacterList
    let etag: String

    struct CharacterList: Decodable {
        let offset: Int
        let limit: Int
        let total: Int
        let count: Int
        let results: [Character]

        struct Character: Decodable, Hashable {
            let id: Int
            let name: String
            let description: String
            let modified: Date
            let resourceURI: String
            let urls: [URLType]
            let thumbnail: Thumbnail
            let comics: CollectionData
            let stories: CollectionData
            let events: CollectionData
            let series: CollectionData

            static func == (lhs: CharacterListResponse.CharacterList.Character, rhs: CharacterListResponse.CharacterList.Character) -> Bool {
                lhs.id == rhs.id
            }

            func hash(into hasher: inout Hasher) {
                hasher.combine(id)
            }
        }
    }

    struct URLType: Decodable {
        let type: String
        let url: String
    }

    struct Thumbnail: Decodable {
        let path: String
        let `extension`: String
        var url: URL? {
            guard var components: URLComponents = .init(string: self.path) else {return nil}
            components.scheme = "https"
            return components.url?.appendingPathExtension(self.extension)
        }
    }

    struct CollectionData: Decodable {
        let available: Int
        let returned: Int
        let collectionURI: String
        let items: [ResourceData]

        struct ResourceData: Decodable {
            let resourceURI: String
            let name: String
        }
    }
}
