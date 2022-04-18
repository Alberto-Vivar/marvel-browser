//
//  CharacterListViewModel.swift
//  Marvel Browser
//
//  Created by Alberto Vivar Arribas on 18/4/22.
//

import UIKit
import Combine

class CharacterListViewModel: ObservableObject {
    @Published var initialTrigger: Void = ()

    var diffableDataSource: MoviesTableViewDiffableDataSource!

    private var snapshot: NSDiffableDataSourceSnapshot<Section, CharacterListResponse.CharacterList.Character> = .init()

    private let weatherFetcher: CharacterFetcher

    private var disposables = Set<AnyCancellable>()

    init(weatherFetcher: CharacterFetcher) {
        self.weatherFetcher = weatherFetcher

        self.$initialTrigger
            .sink(receiveValue: self.fetchCharacters)
            .store(in: &self.disposables)
    }

    func fetchCharacters() {
        self.weatherFetcher.characterList()
            .map {
                response in
                response.data.results
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self = self,
                      let diffableDataSource = self.diffableDataSource
                else {return}
                switch value {
                case .failure:
                    self.snapshot.deleteAllItems()
                case .finished:
                    break
                }
                diffableDataSource.apply(self.snapshot, animatingDifferences: true)
            } receiveValue: { [weak self] characters in
                guard let self = self else {return}
                if !self.snapshot.sectionIdentifiers.contains(.firstSection) {
                    self.snapshot.appendSections([.firstSection])
                }
                if self.snapshot.numberOfItems > 0 {
                    self.snapshot.deleteAllItems()
                }
                self.snapshot.appendItems(characters, toSection: .firstSection)
            }
            .store(in: &self.disposables)
    }
}

class MoviesTableViewDiffableDataSource: UITableViewDiffableDataSource<Section, CharacterListResponse.CharacterList.Character> {}
