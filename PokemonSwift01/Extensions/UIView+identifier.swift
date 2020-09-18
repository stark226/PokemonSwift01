//
//  UIView+identifier.swift
//  PokemonSwift01
//
//  Created by Stefano Cardia Dev on 18/09/2020.
//  Copyright © 2020 Stefano Cardia. All rights reserved.
//

import UIKit

extension UIView {
    static var identifier: String {
        return String(describing: self)
    }
}
