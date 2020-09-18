//
//  Protocols.swift
//  PokemonSwift01
//
//  Created by Stefano Cardia Dev on 16/09/2020.
//  Copyright © 2020 Stefano Cardia. All rights reserved.
//

import UIKit



///used to comunicate events between custom cells with an identity. the class used to send the "content" to the cells needs to conform to it, and to have the delegate property. di fatto viene usato come tipo nell'array chiamato rows, che contiene gli oggetti da mostrare nelle varie celle.
protocol TableViewCellProtocol {
    var identity: String { get set }
    var cellClass: UITableViewCell.Type { get set }
    func config(cell: UITableViewCell)
}




//MARK: protocols for cells

protocol DetailCellDelegate: class {
//    func didTapButtonInCell(withName: String)
}
