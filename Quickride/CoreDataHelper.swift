//
//  CoreDataHelper.swift
//  Quickride
//
//  Created by KNM Rao on 18/01/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CoreData

class CoreDataHelper {
    
 // TODO : implement dispatch in swift 3
  static let lockQueue = DispatchQueue(label: "com.disha.LockQueue", attributes: .concurrent)
  static func getNSMangedObjectContext() -> NSManagedObjectContext{
    let mangedObjectContext = AppDelegate.getAppDelegate().persistentContainer.viewContext
    return mangedObjectContext
  }
  static func saveWorkerContext(workerContext: NSManagedObjectContext)
  {
    lockQueue.sync(flags: .barrier, execute: {
      do {
        try getNSMangedObjectContext().save()
      } catch let saveError as NSError {
        print("save minion worker error: \(saveError.localizedDescription)")
      }
    })

  }
}
