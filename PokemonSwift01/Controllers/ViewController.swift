//
//  ViewController.swift
//  PokemonSwift01
//
//  Created by Stefano Cardia Dev on 16/09/2020.
//  Copyright © 2020 Stefano Cardia. All rights reserved.
//



enum SectionsForTable: String, CaseIterable {
    case pokemonCell
}


import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var pokemonListTableView: UITableView!
    @IBOutlet weak var onlineStatusButtonOut: UIBarButtonItem!
    
    private var viewModel: ViewControllerViewModel!
    private let pokemonDetailSegue = "pokemonDetailSegue"
    
    var rows: [TableViewCellProtocol] = []
    var pokemonsCollection: [Pokemon] = [] //full data for each pokemon
    
    var localPokemonResults: Results<PokemonResultLocal>!
    var localPokemonsCollection: Results<PokemonLocal>!
    
    private var weAreOnline = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel = ViewControllerViewModel(delegate: self)

        pokemonListTableView.delegate = self
        pokemonListTableView.dataSource = self
        
        localPokemonResults = viewModel.realm.objects(PokemonResultLocal.self)
        localPokemonsCollection = viewModel.realm.objects(PokemonLocal.self) //filled with local pokemon if present

        self.showLoadingView(uponView: self.view)
        
        if weAreOnline {
            self.viewModel.initialSetup(vc: self)
        } else {
            self.viewModel.initialSetupVaRealm(vc: self)
        }
        
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        guard let index = self.pokemonListTableView.indexPathForSelectedRow else {return}
        let myPath = index.row
        if segue.identifier == pokemonDetailSegue && weAreOnline {
            let vc = segue.destination as! DetailViewController
            let pokemonName = self.viewModel.PokemonResults[myPath].name.lowercased()
            vc.foundPokemon = self.pokemonsCollection.filter({$0.name?.lowercased() == pokemonName}).first
        } else if segue.identifier == pokemonDetailSegue && !weAreOnline {
            let vc = segue.destination as! DetailViewController
            let pokemonName = self.localPokemonsCollection[myPath].name?.lowercased()
            vc.localPokemon = self.localPokemonsCollection.filter({$0.name?.lowercased() == pokemonName}).first
            vc.weAreOnline = self.weAreOnline
        }
        
    }
    
    
    
    @IBAction func onlineStatusButtonChanged(_ sender: Any) {
        self.weAreOnline.toggle()
        print("weAreOnline is: \(weAreOnline)")
        let text = weAreOnline ? "online" : "offline"
        self.navigationItem.rightBarButtonItem?.title = text
    }
    
    
}



//MARK: TABLEVIEW EXTENSIONS

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: self.pokemonDetailSegue, sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //
        //        let cell = tableView.dequeueReusableCell(withIdentifier: kCellId, for: indexPath) as! CustomTestCell
        //        cell.testLabel.text = self.PokemonResults[indexPath.row]
        
        let model = rows[indexPath.row]
        
        let cell = self.pokemonListTableView.dequeueReusableCell(withIdentifier: model.cellClass.identifier, for: indexPath)
        model.config(cell: cell)
        
        return cell
        
    }
    
    
}

