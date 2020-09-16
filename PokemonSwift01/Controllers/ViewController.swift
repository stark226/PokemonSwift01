//
//  ViewController.swift
//  PokemonSwift01
//
//  Created by Stefano Cardia Dev on 16/09/2020.
//  Copyright © 2020 Stefano Cardia. All rights reserved.
//

///used to comunicate events between custom cells with an identity. the class used to send the "content" to the cells needs to conform to it, and to have the delegate property. di fatto viene usato come tipo nell'array chiamato rows, che contiene gli oggetti da mostrare nelle varie celle.
protocol TableViewCellProtocol {
    var identity: String { get set }
    var cellClass: UITableViewCell.Type { get set }
    func config(cell: UITableViewCell)
}


enum SectionsForTable: String, CaseIterable {
    case pokemonCell
}




import UIKit


class ViewController: UIViewController {
    
    @IBOutlet weak var pokemonListTableView: UITableView!
    let endPoint = "https://pokeapi.co/api/v2/pokemon/"
    let pokemonDetailSegue = "pokemonDetailSegue"
        
    var containerForLoading = UIView()

    
    var PokemonResults: [PokemonResult] = [] //array filled with some data from JASON or other source
    var rows: [TableViewCellProtocol] = []
    var pokemonsCollection: [Pokemon] = [] //full data for each pokemon
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        pokemonListTableView.delegate = self
        pokemonListTableView.dataSource = self
        
        self.showLoadingView(uponView: self.view)

        fetchPokemons { (pokemons, message) in
            
            
            
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
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        guard let index = self.pokemonListTableView.indexPathForSelectedRow else {return}
        let myPath = index.row
        if segue.identifier == pokemonDetailSegue {
            let vc = segue.destination as! DetailViewController
            let pokemonName = self.PokemonResults[myPath].name.lowercased()
            vc.foundPokemon = self.pokemonsCollection.filter({$0.name?.lowercased() == pokemonName}).first
        }
    }
    
    
    
    func GetPokemonAbility(singlePokemonUrl: String) {
        
        //per ogni pokemon faccio la ricerca di tuti i dati contenuti e li metto in un array separato, che userò sia per inviare i dati al VC di dettaglio, che per il salvataggio offline
        
        self.fetchPokemonsAbilities(singleUrl: singlePokemonUrl) { (singlePokemon, message) in
            
            guard let singlePokemon = singlePokemon else {
                return
            }
            
            self.pokemonsCollection.append(singlePokemon)
        }
        

    }
    
    
    
}



//MARK: EXTENSIONS

extension ViewController {
    
    func fetchPokemons(completed: @escaping (GetMainResult?, String?) -> Void) {
        
        guard let url = URL(string: endPoint) else {
            completed(nil, "error 0")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let _ = error {
                completed(nil, "error 1")
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(nil, "error 2")
                return
            }
            
            guard let data = data else {
                completed(nil, "error 3")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let allResults = try decoder.decode(GetMainResult.self, from: data)
                completed(allResults, nil)
            } catch {
                completed(nil, "error 4")
            }
            
        }
        
        
        task.resume()
        
        
    }
    
    
    func fetchPokemonsAbilities(singleUrl: String, completed: @escaping (Pokemon?, String?) -> Void) {
        
        guard let url = URL(string: singleUrl) else {
            completed(nil, "error 0")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let _ = error {
                completed(nil, "error 1")
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(nil, "error 2")
                return
            }
            
            guard let data = data else {
                completed(nil, "error 3")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let followers = try decoder.decode(Pokemon.self, from: data)
                completed(followers, nil)
            } catch {
                completed(nil, "error 4")
            }
            
        }
        
        
        task.resume()
        
        
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
        
        let cell = self.pokemonListTableView.dequeueReusableCell(withIdentifier: model.cellClass.identifier_GivenByExtension, for: indexPath)
        model.config(cell: cell)
        
        return cell
        
    }
    
    
    
}


extension UIView {
    //    static var identifier: String { //usa questa nel mondo reale
    
    static var identifier_GivenByExtension: String {
        return String(describing: self)
    }
}



extension ViewController: PokemonListCellDelegate {
    
    //    func didTapButtonInCell(withName: String) {
    //        print(withName)
    //    }
    
}



extension ViewController {
    
    func showLoadingView(uponView: UIView) {
        containerForLoading = UIView(frame: uponView.bounds)
        uponView.addSubview(containerForLoading)
        
        containerForLoading.backgroundColor = .white
        containerForLoading.alpha = 0
        UIView.animate(withDuration: 0.24) { self.containerForLoading.alpha = 0.8 }
        let activivityIndicator = UIActivityIndicatorView()
        containerForLoading.addSubview(activivityIndicator)
        
        activivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
        
            activivityIndicator.centerYAnchor.constraint(equalTo: uponView.centerYAnchor),
            activivityIndicator.centerXAnchor.constraint(equalTo: uponView.centerXAnchor)

        ])
        
        activivityIndicator.startAnimating()
    }
    
    func removeLoading(uponView: UIView) {
        
        containerForLoading.removeFromSuperview()
        
    }
    
    
}
