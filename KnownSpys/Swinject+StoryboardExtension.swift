//
//  Swinject+StoryboardExtension.swift
//  KnownSpys
//
//  Created by Mathieu Janneau on 01/02/2022.
//  Copyright © 2022 JonBott.com. All rights reserved.
//

import Foundation
import Swinject
import SwinjectStoryboard

extension SwinjectStoryboard {
    
    public class func setup() {
        if AppDelegate.dependencyRegistry == nil {
            AppDelegate.dependencyRegistry = DependencyRegistryImpl(container: defaultContainer)
        }
        
        let dependencyRegistry: DependencyRegistry = AppDelegate.dependencyRegistry
        
        func main() {
            dependencyRegistry.container.storyboardInitCompleted(SpyListViewController.self) { dependencies, vc in
                
                let coordinator = dependencyRegistry.makeRootNavigationCoordinator(rootViewcontroller: vc)
                
                setupData(resolver: dependencies, navigationCoordinator: coordinator)
                
                let presenter = dependencies.resolve(SpyListPresenter.self)!
                vc.configure(with: presenter,
                             navigationCoordinator: coordinator,
                             spyCellMaker: dependencyRegistry.makeSpyCell
                )
                
            }
        }
        
        func setupData(resolver: Resolver, navigationCoordinator: NavigationCoordinator) {
            MockedWebServer.sharedInstance.start()
            AppDelegate.navigationCoordinator = navigationCoordinator
        }
        
        main()
    }
}
