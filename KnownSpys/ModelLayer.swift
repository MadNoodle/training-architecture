//
//  ModelLayer.swift
//  KnownSpys
//
//  Created by Mathieu Janneau on 31/01/2022.
//  Copyright © 2022 JonBott.com. All rights reserved.
//

import Foundation

typealias SpiesAndSourceBlock = (Source, [SpyDTO]) -> Void

protocol ModelLayer {
    func loadData(resultsLoaded: @escaping SpiesAndSourceBlock)
}

class ModelLayerImpl: ModelLayer {
    fileprivate var networkLayer: NetworkLayer!
    fileprivate var databaseLayer: DatabaseLayer!
    fileprivate var translationLayer: TranslationLayer!
    
    init(networkLayer: NetworkLayer,
         databaseLayer: DatabaseLayer,
         translationLayer: TranslationLayer) {
        self.networkLayer = networkLayer
        self.databaseLayer = databaseLayer
        self.translationLayer = translationLayer
    }
    
    func loadData(resultsLoaded: @escaping SpiesAndSourceBlock) {
        func mainWork() {
            
            loadFromDB(from: .local)
            
            networkLayer.loadFromServer { data in
                let dtos = self.translationLayer.createSpyDTOsFromJsonData(data)
                self.databaseLayer.save(dtos: dtos, translationLayer: self.translationLayer) {
                    loadFromDB(from: .network)
                }
            }
        }
        
        func loadFromDB(from source: Source) {
            databaseLayer.loadFromDB { spies in
                let dtos = translationLayer.toSpyDTOs(from: spies)
                resultsLoaded(source, dtos)
            }
        }
        
        mainWork()
    }
}

