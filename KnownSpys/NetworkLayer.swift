//
//  NetworkLayer.swift
//  KnownSpys
//
//  Created by Mathieu Janneau on 31/01/2022.
//  Copyright © 2022 JonBott.com. All rights reserved.
//

import Foundation
import Alamofire

protocol NetworkLayer {
    func loadFromServer(finished: @escaping (Data) -> Void)
}

class NetworkLayerImpl: NetworkLayer {
    func loadFromServer(finished: @escaping (Data) -> Void) {
        print("loading data from server")
        
        AF.request("http://localhost:8080/spies")
            .responseJSON
            { response in
                guard let data = response.data else { return }
                
                finished(data)
        }
    }

}
