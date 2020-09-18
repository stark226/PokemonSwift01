//
//  UiViewController+loadingView.swift
//  PokemonSwift01
//
//  Created by Stefano Cardia Dev on 18/09/2020.
//  Copyright © 2020 Stefano Cardia. All rights reserved.
//

import UIKit

extension UIViewController {
    
    static let loadingContainerTag = 66
    
    func showLoadingView(uponView: UIView) {
        
        let containerForLoading = UIView(frame: uponView.bounds)
        uponView.addSubview(containerForLoading)
        containerForLoading.backgroundColor = .white
        containerForLoading.alpha = 0
        
        
        containerForLoading.tag = UIViewController.loadingContainerTag
        
        
        UIView.animate(withDuration: 0.24) { containerForLoading.alpha = 0.8 }
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
        uponView.viewWithTag(UIViewController.loadingContainerTag)?.removeFromSuperview()
    }
}
