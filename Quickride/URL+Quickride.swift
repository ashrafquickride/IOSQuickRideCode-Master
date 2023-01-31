//
//  URL+Quickride.swift
//  Quickride
//
//  Created by Admin on 22/03/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

extension URL {
    func expandURLWithCompletionHandler(completionHandler: @escaping (URL?) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: self, completionHandler: {
            _, response, _ in
            completionHandler(response?.url)
        })
        dataTask.resume()
    }
}
