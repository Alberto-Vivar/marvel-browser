//
//  CharacterListViewController.swift
//  Marvel Browser
//
//  Created by Alberto Vivar Arribas on 18/4/22.
//

import UIKit

class CharacterListViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView: UITableView = .init()
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
        ])
        return tableView
    }()

    private lazy var viewModel: CharacterListViewModel = {
        .init(weatherFetcher: CharacterFetcher())
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerCell()
        self.setupObservers()
    }

    func registerCell() {
        let movieCell = UINib(nibName: CharacterTableViewCell.reuseIdentifier, bundle: nil)
        self.tableView.register(movieCell, forCellReuseIdentifier: CharacterTableViewCell.reuseIdentifier)
    }

    func setupObservers() {
        self.viewModel.diffableDataSource = .init(tableView: self.tableView) { (tableView, indexPath, model) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CharacterTableViewCell.reuseIdentifier, for: indexPath) as? CharacterTableViewCell
            else { return UITableViewCell() }
            cell.characterObject = model
            return cell
        }
    }
}

extension CharacterListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let _ = self.viewModel.diffableDataSource.itemIdentifier(for: indexPath)
        // TODO: push the character to the detail view.
    }
}
