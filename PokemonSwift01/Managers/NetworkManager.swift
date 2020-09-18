//
//  NetworkManager.swift
//  PokemonSwift01
//
//  Created by Stefano Cardia Dev on 18/09/2020.
//  Copyright © 2020 Stefano Cardia. All rights reserved.
//

import Foundation


class NetworkManager {
    
    
    static let shared = NetworkManager()
    
    let endPoint = "https://pokeapi.co/api/v2/pokemon/"

    
    private init() {
        
    }
    
    
    
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
