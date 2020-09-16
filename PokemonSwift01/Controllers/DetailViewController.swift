//
//  DetailViewController.swift
//  PokemonSwift01
//
//  Created by Stefano Cardia Dev on 16/09/2020.
//  Copyright © 2020 Stefano Cardia. All rights reserved.
//

enum SectionDetail: String, CaseIterable {
    case CustomHeaderCell
    case name = "Nome"
    case naturalGift = "Natural gift power"
    case stats = "Stats"
}


import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailVCTable: UITableView!
    
    var foundPokemon: Pokemon?
    
    var rows: [TableViewCellProtocol] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailVCTable.delegate = self
        detailVCTable.dataSource = self
        detailVCTable.allowsSelection = false

        
        for section in SectionDetail.allCases {
            
            
            switch section {
            case .CustomHeaderCell:
    //                self.rows.append(CustomHeaderForCellModelRowObject(delegate: self, identity: section.rawValue, headerTitle: "sono l'header"))
                break
            case .name :
                rows.append((DetailCellRowObject(delegate: self, identity: SectionDetail.name.rawValue.uppercased(), valueName: SectionDetail.name.rawValue , valueData: foundPokemon?.name ?? "NA")))
            case .naturalGift:
                rows.append((DetailCellRowObject(delegate: self, identity: SectionDetail.naturalGift.rawValue, valueName: SectionDetail.naturalGift.rawValue.uppercased() , valueData: foundPokemon?.types?.first?.type?.name ?? "NA")))
            case .stats :
                guard let stats = foundPokemon?.stats else {return}
                for singleStat in stats {
                    let baseStat  = singleStat.baseStat?.description ?? "NA"
                    let effort  = singleStat.effort?.description ?? "NA"
                    let stat  = singleStat.stat?.name ?? "NA"

                    rows.append((DetailCellRowObject(delegate: self,
                                                     identity: SectionDetail.stats.rawValue,
                                                     valueName: "",
                                                     valueData: " \(stat.uppercased()): base: \(baseStat) effort: \(effort) "
                    )))
                }
                
               
                
            }
            
            
        }
        
        
        
    }


    
    
    
    
    
}







extension DetailViewController: UITableViewDelegate {
    
    
}

extension DetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = rows[indexPath.row]
        
        let cell = self.detailVCTable.dequeueReusableCell(withIdentifier: model.cellClass.identifier_GivenByExtension, for: indexPath)
        model.config(cell: cell)
        
        return cell
    }

}


extension DetailViewController : DetailCellDelegate {
    
}
