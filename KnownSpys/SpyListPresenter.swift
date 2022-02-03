//
//  SpyListPresenter.swift
//  KnownSpys
//
//  Created by Mathieu Janneau on 31/01/2022.
//  Copyright © 2022 JonBott.com. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

typealias BlockWithSource = (Source) -> Void

struct SpySection {
    var header: String
    var items: [Item]
}

extension SpySection: SectionModelType {
    typealias Item = SpyDTO
    
    init(original: SpySection, items: [Item]) {
        self = original
        self.items = items
    }
}

protocol SpyListPresenter {
    var sections: BehaviorSubject<[SpySection]> { get }
    func loadData(finished: @escaping BlockWithSource)
    func transform()
}

class SpyListPresenterImpl: SpyListPresenter {
    
    private var modelLayer: ModelLayer!
    
    // MARK: RXStuff
    var sections = BehaviorSubject<[SpySection]>.init(value: [])
    private var disposeBag = DisposeBag()
    private var spies = BehaviorSubject<[SpyDTO]>.init(value: [])
    
    init(modelLayer: ModelLayer) {
        self.modelLayer = modelLayer
        setupObservers()
    }

}

// MARK: RX
extension SpyListPresenterImpl {
    
    func setupObservers() {
        spies.asObservable()
            .subscribe(onNext: { [weak self] spies in
                guard let self = self else { return}
                self.updateSections(with: spies)
            })
            .disposed(by: disposeBag)
    }
    
    func updateSections(with newSpies: [SpyDTO]) {
        func mainMork() {
            sections.onNext(filter(spies: newSpies))
        }
            
            func filter(spies: [SpyDTO]) -> [SpySection] {
                let incognito = spies.filter { $0.isIncognito}
                let everdaySpies = spies.filter {!$0.isIncognito}
                
                return [
                    SpySection(header: "SneakySpies", items: incognito),
                    SpySection(header: "RegularSpies", items: everdaySpies)
                ]
            }
        mainMork()
    }
}

//MARK: - Data Methods
extension SpyListPresenterImpl {
    
    func transform() {
        let newSpy = SpyDTO(age: 21, name: "MAthieu", gender: .male, password: "Papoum", imageName: "AdamSmith", isIncognito: true)
        
        if var value = try? spies.value() {
            value.append(newSpy)
            spies.on(.next(value))
        }
    }
    
    func loadData(finished: @escaping BlockWithSource) {
        modelLayer.loadData { [weak self] source, spies in
            guard let self = self else { return }
            self.spies.onNext(spies)
            finished(source)
        }
    }
}
