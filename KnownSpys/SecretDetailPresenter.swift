//
//  SecretDetailPresenter.swift
//  KnownSpys
//
//  Created by Mathieu Janneau on 31/01/2022.
//  Copyright © 2022 JonBott.com. All rights reserved.
//

import Foundation

protocol SecretDetailPresenter {
    var password: String { get }
}

class SecretDetailPresenterImpl: SecretDetailPresenter {
    var spy: SpyDTO
    
    var password: String { return spy.password}
    
    init(with spy: SpyDTO) {
        self.spy = spy
    }
}
