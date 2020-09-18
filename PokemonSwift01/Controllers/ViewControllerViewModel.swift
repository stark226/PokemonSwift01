//
//  ViewControllerViewModel.swift
//  PokemonSwift01
//
//  Created by Stefano Cardia Dev on 18/09/2020.
//  Copyright © 2020 Stefano Cardia. All rights reserved.
//

protocol ViewControllerViewModelDelegate: class {
    func DidFinishinItialSetup(rows: [TableViewCellProtocol])
    func updateView()
    func updatePokemonAbility(pokemonsCollection: [Pokemon])
}

import Foundation
import RealmSwift

class ViewControllerViewModel {
    
    weak var viewControllerViewModelDelegate: ViewControllerViewModelDelegate?
    
    var PokemonResults: [PokemonResult] = [] //array filled with some data from JSON or other source
    var rows: [TableViewCellProtocol] = []
    var pokemonsCollection: [Pokemon] = [] //full data for each pokemon
    
    let realm = try! Realm()
    
    var localPokemonResults: Results<PokemonResultLocal>!
    var localPokemonsCollection: Results<PokemonLocal>!
    
    init(delegate: ViewControllerViewModelDelegate) {
        
        self.viewControllerViewModelDelegate = delegate
        
        localPokemonResults = self.realm.objects(PokemonResultLocal.self)
        localPokemonsCollection = self.realm.objects(PokemonLocal.self) //filled with local pokemon if present
    }
    
    
    
    func initialSetup(vc: ViewController) {
        
        NetworkManager.shared.fetchPokemons { [weak self] (pokemons, message) in
            guard let self = self else {return}
            guard let pokemons = pokemons else {
                return
            }
            self.PokemonResults = pokemons.results
            
            for singlePokemon in self.PokemonResults {
                self.rows.append(PokemonCellRowObject(delegate: vc, identity: SectionsForTable.pokemonCell.rawValue, pokemonName: singlePokemon.name, url: singlePokemon.url))
                
                self.viewControllerViewModelDelegate?.DidFinishinItialSetup(rows: self.rows)
                self.viewControllerViewModelDelegate?.updateView()
                
                self.GetPokemonAbility(singlePokemonUrl: singlePokemon.url)
            }
            
            DispatchQueue.main.async {
                for single in pokemons.results {
                    self.fillLocalArrayOfresults(webQueryResult: single)
                }
            }
            
        }
    }
    
    
    
    
    func initialSetupVaRealm(vc: ViewController) {
        
        print("sono \(localPokemonResults.count)")
        for singlePokemon in self.localPokemonResults {
            self.rows.append(PokemonCellRowObject(delegate: vc, identity: SectionsForTable.pokemonCell.rawValue, pokemonName: singlePokemon.name, url: singlePokemon.url))
            
            self.GetPokemonAbility(singlePokemonUrl: singlePokemon.url)
        }
        
        self.viewControllerViewModelDelegate?.updateView()
        
        //                   DispatchQueue.main.async {
        //                       self.removeLoading(uponView: self.view)
        //                       self.pokemonListTableView.reloadData()
        //                   }
        
    }
    
    
    func GetPokemonAbility(singlePokemonUrl: String) {
        
        //per ogni pokemon faccio la ricerca di tuti i dati contenuti e li metto in un array separato, che userò sia per inviare i dati al VC di dettaglio, che per il salvataggio offline
        
        NetworkManager.shared.fetchPokemonsAbilities(singleUrl: singlePokemonUrl) { [weak self] (singlePokemon, message) in
            guard let self = self else {return}
            guard let singlePokemon = singlePokemon else {
                return
            }
            
            self.pokemonsCollection.append(singlePokemon)
            self.viewControllerViewModelDelegate?.updatePokemonAbility(pokemonsCollection: self.pokemonsCollection)
            
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
        guard let localPokemonsCollection = localPokemonsCollection else {
            print("error in fillLocalArrayOfPokemons")
            return}
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
    
    
    
    
    
    
    
    
}
