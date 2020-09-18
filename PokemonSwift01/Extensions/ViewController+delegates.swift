//
//  UIViewController+delegates.swift
//  PokemonSwift01
//
//  Created by Stefano Cardia Dev on 18/09/2020.
//  Copyright © 2020 Stefano Cardia. All rights reserved.
//

import Foundation



extension ViewController: PokemonListCellDelegate {
    
    //    func didTapButtonInCell(withName: String) {
    //        print(withName)
    //    }
    
}


extension ViewController: ViewControllerViewModelDelegate {
    
    func DidFinishinItialSetup(rows: [TableViewCellProtocol]) {
        self.rows = rows
    }
    
    func updateView() {
        DispatchQueue.main.async {
            self.removeLoading(uponView: self.view)
            self.pokemonListTableView.reloadData()
        }
    }
    
    func updatePokemonAbility(pokemonsCollection: [Pokemon]) {
        self.pokemonsCollection = pokemonsCollection
    }
}
