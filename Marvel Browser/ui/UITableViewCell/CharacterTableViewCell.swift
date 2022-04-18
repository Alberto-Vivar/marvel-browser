//
//  CharacterTableViewCell.swift
//  Marvel Browser
//
//  Created by Alberto Vivar Arribas on 18/4/22.
//

import UIKit
import SDWebImage

class CharacterTableViewCell: UITableViewCell {
    static var reuseIdentifier: String {
        return "CharacterTableViewCell"
    }

    var characterObject: CharacterListResponse.CharacterList.Character! {
        didSet {
            self.setupData()
        }
    }

    private func setupData() {
        self.textLabel?.text = characterObject.name

        self.imageView?.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.imageView?.sd_setImage(with: self.characterObject.thumbnail.url, placeholderImage: .init(named: "placeholder-image"))
    }
}
