//
//  TranslationLayer.swift
//  KnownSpys
//
//  Created by Mathieu Janneau on 31/01/2022.
//  Copyright © 2022 JonBott.com. All rights reserved.
//

import Foundation
import Outlaw
import CoreData

protocol TranslationLayer {
    func createSpyDTOsFromJsonData(_ data: Data) -> [SpyDTO]
    func toUnsavedCoreData(from dtos: [SpyDTO], with context: NSManagedObjectContext) -> [Spy]
    func toSpyDTOs(from spies:[Spy]) -> [SpyDTO]
}

class TranslationLayerImpl: TranslationLayer {
    
    fileprivate var spyTranslater: SpyTranslater!
    
    init(spyTranslater: SpyTranslater) {
        self.spyTranslater = spyTranslater
    }
    
    func createSpyDTOsFromJsonData(_ data: Data) -> [SpyDTO] {
        print("converting json to DTOs")
        let json:[String: Any] = try! JSON.value(from: data)
        let spies: [SpyDTO] = try! json.value(for: "spies")
        return spies
    }
    
    func toUnsavedCoreData(from dtos: [SpyDTO], with context: NSManagedObjectContext) -> [Spy] {
        print("convering DTOs to Core Data Objects")
        let spies = dtos.compactMap{ dto in spyTranslater.translate(from: dto, with: context) } // keeping it simple by keeping things single threaded
        
        return spies
    }
    
    func toSpyDTOs(from spies:[Spy]) -> [SpyDTO] {
        let dtos = spies.compactMap { spyTranslater.translate(from: $0) }
        
        return dtos
    }
}



