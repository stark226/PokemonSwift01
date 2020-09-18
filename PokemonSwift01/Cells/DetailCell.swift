//
//  DetailCell.swift
//  PokemonSwift01
//
//  Created by Stefano Cardia Dev on 16/09/2020.
//  Copyright © 2020 Stefano Cardia. All rights reserved.
//

import UIKit

class DetailCell: UITableViewCell {

    @IBOutlet weak var DetailCellLabel: UILabel!

    
       weak var delegate: DetailCellDelegate?
       private var model: DetailCellRowObject?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func configCell(_ model: DetailCellRowObject) {
        
        self.model = model
        delegate = model.delegate
        
        self.DetailCellLabel.text = "\(model.valueName ?? "N/A") \(model.valueData ?? "N/A")"
    
    }

}




//MARK: - object for tableView
class DetailCellRowObject:  TableViewCellProtocol {
    
    var identity: String
    var cellClass: UITableViewCell.Type = DetailCell.self
    var delegate: DetailCellDelegate?
        
    var valueName: String?
    var valueData: String?
    
    
    init(delegate: DetailCellDelegate? = nil, identity: String, valueName: String?, valueData: String?) {
        
        self.delegate = delegate
        self.identity = identity
        
        self.valueName = valueName
        self.valueData = valueData

    }
    
    func config(cell: UITableViewCell) {
        (cell as? DetailCell)?.configCell(self)
    }
}
