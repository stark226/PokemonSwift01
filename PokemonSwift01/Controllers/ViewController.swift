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
    
    
//    let endPoint = "https://pokeapi.co/api/v2/pokemon/"
    let pokemonDetailSegue = "pokemonDetailSegue"
    
    var containerForLoading = UIView()
    
    
    var PokemonResults: [PokemonResult] = [] //array filled with some data from JSON or other source
    var rows: [TableViewCellProtocol] = []
    var pokemonsCollection: [Pokemon] = [] //full data for each pokemon
    
    let realm = try! Realm()
    var localPokemonResults: Results<PokemonResultLocal>!
    var localPokemonsCollection: Results<PokemonLocal>!
    
    private var weAreOnline = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pokemonListTableView.delegate = self
        pokemonListTableView.dataSource = self
        
        localPokemonResults = realm.objects(PokemonResultLocal.self)
        localPokemonsCollection = realm.objects(PokemonLocal.self) //filled with local pokemon if present

        
        self.showLoadingView(uponView: self.view)
        if weAreOnline {
            
            NetworkManager.shared.fetchPokemons { (pokemons, message) in
                
                guard let pokemons = pokemons else {
                    return
                }
                self.PokemonResults = pokemons.results
                
                for singlePokemon in self.PokemonResults {
                    self.rows.append(PokemonCellRowObject(delegate: self, identity: SectionsForTable.pokemonCell.rawValue, pokemonName: singlePokemon.name, url: singlePokemon.url))
                    
                    self.GetPokemonAbility(singlePokemonUrl: singlePokemon.url)
                }
                
                DispatchQueue.main.async {
                    self.removeLoading(uponView: self.view)
                    self.pokemonListTableView.reloadData()
                }
                
                
                DispatchQueue.main.async {
                    for single in pokemons.results {
                        self.fillLocalArrayOfresults(webQueryResult: single)
                    }
                }
                
            }
        } else {
            print("sono \(localPokemonResults.count)")
            for singlePokemon in self.localPokemonResults {
                self.rows.append(PokemonCellRowObject(delegate: self, identity: SectionsForTable.pokemonCell.rawValue, pokemonName: singlePokemon.name, url: singlePokemon.url))
                
//                self.GetPokemonAbility(singlePokemonUrl: singlePokemon.url)
            }
            
            DispatchQueue.main.async {
                self.removeLoading(uponView: self.view)
                self.pokemonListTableView.reloadData()
            }
            
        }
        
        
        
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        guard let index = self.pokemonListTableView.indexPathForSelectedRow else {return}
        let myPath = index.row
        if segue.identifier == pokemonDetailSegue && weAreOnline {
            let vc = segue.destination as! DetailViewController
            let pokemonName = self.PokemonResults[myPath].name.lowercased()
            vc.foundPokemon = self.pokemonsCollection.filter({$0.name?.lowercased() == pokemonName}).first
        } else if segue.identifier == pokemonDetailSegue && !weAreOnline {
            let vc = segue.destination as! DetailViewController
            let pokemonName = self.localPokemonsCollection[myPath].name?.lowercased()
            vc.localPokemon = self.localPokemonsCollection.filter({$0.name?.lowercased() == pokemonName}).first
            vc.weAreOnline = self.weAreOnline
        }
    }
    
    
    
    func GetPokemonAbility(singlePokemonUrl: String) {
        
        //per ogni pokemon faccio la ricerca di tuti i dati contenuti e li metto in un array separato, che userò sia per inviare i dati al VC di dettaglio, che per il salvataggio offline
        
        NetworkManager.shared.fetchPokemonsAbilities(singleUrl: singlePokemonUrl) { (singlePokemon, message) in
            
            guard let singlePokemon = singlePokemon else {
                return
            }
            
            self.pokemonsCollection.append(singlePokemon)
            
            DispatchQueue.main.async {
                self.fillLocalArrayOfPokemons(webPokemon: singlePokemon)
            }
            
        }
        
        
    }
    
    func fillLocalArrayOfresults(webQueryResult: PokemonResult) {
        
        if !localPokemonResults.contains(where: {$0.name == webQueryResult.name}) {

        let localresult = PokemonResultLocal()
        localresult.name = webQueryResult.name
        localresult.url = webQueryResult.url
        
        try! realm.write {
            realm.add(localresult)
        }
        print("creato localresult \(localresult.name)")
        } else {
            print("presente tra tutti i results")

        }
        
    }
    
    func fillLocalArrayOfPokemons(webPokemon: Pokemon) {
        
        
        
        if !localPokemonsCollection.contains(where: {$0.name == webPokemon.name ?? "N/A"}) {
            
            let localPokemon = PokemonLocal()
            localPokemon.id = webPokemon.id ?? 00
            localPokemon.name = webPokemon.name
            
            //    let stats = List<StatLocal>()
            for stat in webPokemon.stats ?? [] {
                let localStat = StatLocal()
                localStat.baseStat = stat.baseStat ?? 0
                localStat.effort = stat.effort ?? 0
                
                
                let speciesLocal = SpeciesLocal()
                speciesLocal.name = stat.stat?.name ?? ""
                speciesLocal.url  = stat.stat?.url ?? ""
                localStat.stat = speciesLocal
                localPokemon.stats.append(localStat)
            }
            
            //    let types = List<TypeElementLocal>()
            for type in webPokemon.types ?? [] {
                let typeElementLocal = TypeElementLocal()
                typeElementLocal.slot = type.slot ?? 0
                
                let speciesLocal = SpeciesLocal()
                speciesLocal.name = type.type?.name ?? ""
                speciesLocal.url = type.type?.url ?? ""
                typeElementLocal.type = speciesLocal
                localPokemon.types.append(typeElementLocal)
            }
            
            try! realm.write {
                realm.add(localPokemon)
            }
            print("creato \(localPokemon.name ?? "N/A")")
            
        } else {
            print("presente tra tutti e \(localPokemonsCollection.count)")
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


extension ViewController: PokemonListCellDelegate {
    
    //    func didTapButtonInCell(withName: String) {
    //        print(withName)
    //    }
    
}

