//
//  DependencyRegistry.swift
//  KnownSpys
//
//  Created by Mathieu Janneau on 01/02/2022.
//  Copyright © 2022 JonBott.com. All rights reserved.
//

import Foundation
import Swinject
import SwinjectStoryboard

protocol DependencyRegistry {
    var container: Container { get }
    var navigationCoordinator: NavigationCoordinator! { get}
    
    typealias RootCoordinatorMaker = (UIViewController) -> NavigationCoordinator
    func makeRootNavigationCoordinator(rootViewcontroller: UIViewController) -> NavigationCoordinator
    
    typealias SpyCellMaker = (UITableView, IndexPath, SpyDTO) -> SpyCell
    func makeSpyCell(for tableview: UITableView, at indexPath: IndexPath, with spy: SpyDTO) -> SpyCell
    
    typealias DetailViewControllerMaker = (SpyDTO) -> DetailViewController
    func makeDetailViewController(with spy: SpyDTO) -> DetailViewController
    typealias SecretDetailViewControllerMaker = (SpyDTO, NavigationCoordinator) -> SecretDetailsViewController
    func makeSecretDetailsViewController(with spy: SpyDTO) -> SecretDetailsViewController
    
}

class DependencyRegistryImpl: DependencyRegistry {
    
    var container: Container
    var navigationCoordinator: NavigationCoordinator!
    
    init(container: Container) {
        self.container = container
        
        registerDependencies()
        registerPresenters()
        registerViewControllers()
    }
    
    func registerDependencies() {
        
        container.register(NavigationCoordinator.self) {(dependencies, rootViewController: UIViewController) in
            RootNavigationCoordinatorImpl(with: rootViewController, registry: self)
            
        }.inObjectScope(.container)
        container.register( NetworkLayer.self) { _ in NetworkLayerImpl()}.inObjectScope(.container)
        container.register( DatabaseLayer.self) { _ in DatabaseLayerImpl()}.inObjectScope(.container)
        container.register( SpyTranslater.self) { _ in SpyTranslaterImpl()}.inObjectScope(.container)
        
        // second level Injection depends on first level
        container.register( TranslationLayer.self) { dependencies in
            TranslationLayerImpl(spyTranslater: dependencies.resolve(SpyTranslater.self)!)
        }.inObjectScope(.container)
        
        // third layer depends on the two firsts layers
        container.register( ModelLayer.self) { dependencies in ModelLayerImpl(
            networkLayer: dependencies.resolve(NetworkLayer.self)!,
            databaseLayer: dependencies.resolve(DatabaseLayer.self)!,
            translationLayer: dependencies.resolve(TranslationLayer.self)!)
        }.inObjectScope(.container)
    }
    
    func registerPresenters() {
        container.register(SpyCellPresenter.self) { (dependencies, spyDto: SpyDTO) in SpyCellPresenterImpl(with: spyDto)}
        container.register(SpyListPresenter.self) { dependencies in SpyListPresenterImpl( modelLayer: dependencies.resolve(ModelLayer.self)!)}
        container.register(DetailPresenter.self) { (dependencies, spyDto: SpyDTO) in DetailPresenterImpl(with: spyDto)}
        container.register(SecretDetailPresenter.self) { (dependencies, spyDto: SpyDTO) in SecretDetailPresenterImpl(with: spyDto)}
    }
    
    func registerViewControllers() {
        container.register(SecretDetailsViewController.self) { (dependencies: Resolver, spy: SpyDTO) -> SecretDetailsViewController in
            let presenter = dependencies.resolve(SecretDetailPresenter.self, argument: spy)!
            return SecretDetailsViewController(with: presenter, navigationCoordinator: self.navigationCoordinator)
        }
        
        container.register(DetailViewController.self) { (dependencies: Resolver, spy: SpyDTO) in
            let presenter = dependencies.resolve(DetailPresenter.self, argument: spy)!
            
            let vc = UIStoryboard.main.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            vc.configure(with: presenter, navigationCoordinator: self.navigationCoordinator)
            return vc
        }
        
    }
    
    // MARK: Maker methods
    func makeSpyCell(for tableview: UITableView, at indexPath: IndexPath, with spy: SpyDTO) -> SpyCell {
        let presenter = container.resolve(SpyCellPresenter.self, argument: spy)!
        let cell = SpyCell.dequeue(from: tableview, for: indexPath, with: presenter)
        return cell
    }
    
    func makeDetailViewController(with spy: SpyDTO) -> DetailViewController {
        return container.resolve(DetailViewController.self, argument: spy)!
    }
    
    func makeSecretDetailsViewController(with spy: SpyDTO) -> SecretDetailsViewController {
        return container.resolve(SecretDetailsViewController.self, argument: spy)!
    }
    
    func makeRootNavigationCoordinator(rootViewcontroller: UIViewController) -> NavigationCoordinator {
        navigationCoordinator = container.resolve(NavigationCoordinator.self, argument: rootViewcontroller)!
        return navigationCoordinator
    }
    
    
}
