//
//  PokemonListCell.swift
//  PokemonSwift01
//
//  Created by Stefano Cardia Dev on 16/09/2020.
//  Copyright © 2020 Stefano Cardia. All rights reserved.
//


protocol PokemonListCellDelegate: class {
    //    func didTapButtonInCell(withName: String)
}

import UIKit

class PokemonListCell: UITableViewCell {
    
    @IBOutlet weak var pokemonNameLabel: UILabel!
    
    weak var delegate: PokemonListCellDelegate?
    private var model: PokemonCellRowObject?
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func configCell(_ model: PokemonCellRowObject) {
        
        self.model = model
        delegate = model.delegate
        
        self.pokemonNameLabel.text = "\(model.pokemonName ?? "N/A")"
        
    }
    
    //    @IBAction func myButtonTapped(_ sender: Any) {
    //        let string = " \(self.model?.identity ?? "no identity") \(self.model?.personName ?? "no person name") "
    //        delegate?.didTapButtonInCell(withName:  string )
    //    }
    
}



//MARK: - object for tableView
class PokemonCellRowObject:  TableViewCellProtocol {
    
    var identity: String
    var cellClass: UITableViewCell.Type = PokemonListCell.self
    var delegate: PokemonListCellDelegate?
    
    var pokemonName: String?
    var url: String?
    
    
    init(delegate: PokemonListCellDelegate? = nil, identity: String, pokemonName: String?, url: String?) {
        
        self.delegate = delegate
        self.identity = identity
        
        self.pokemonName = pokemonName
        
        
    }
    
    func config(cell: UITableViewCell) {
        (cell as? PokemonListCell)?.configCell(self)
    }
}





