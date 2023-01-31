//
//  FileUtils.swift
//  Quickride
//
//  Created by Admin on 06/08/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class FileUtils{
   
    static func downloadFileFromUrl(urlString:String, fileName:String,viewController : UIViewController) {
        
        // Create destination URL
        if let documentsUrl:URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            let destinationFileUrl = documentsUrl.appendingPathComponent(fileName)
            //Create URL to the source file you want to download
            let fileURL = URL(string: urlString)
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig)
            let request = URLRequest(url:fileURL!)
            QuickRideProgressSpinner.startSpinner()
            let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                QuickRideProgressSpinner.stopSpinner()
                if let tempLocalUrl = tempLocalUrl, error == nil {
                    // Success
                    
                    try? FileManager.default.removeItem(at: destinationFileUrl)
                    do {
                        try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                        do {
                            //Show UIActivityViewController to save the downloaded file
                            let contents  = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                            for index in 0..<contents.count {
                                if contents[index].lastPathComponent == destinationFileUrl.lastPathComponent {
                                    let activityViewController = UIActivityViewController(activityItems: [contents[index]], applicationActivities: nil)
                                    DispatchQueue.main.async(execute: {
                                        viewController.present(activityViewController, animated: true, completion: nil)
                                    })
                                }
                            }
                        }
                        catch (let err) {
                            DispatchQueue.main.async(execute: {
                                UIApplication.shared.keyWindow?.makeToast( err.localizedDescription)
                            })
                        }
                    } catch (let writeError) {
                        DispatchQueue.main.async(execute: {
                            UIApplication.shared.keyWindow?.makeToast( "Error creating a file :- \(writeError.localizedDescription)")
                        })
                    }
                } else {
                    DispatchQueue.main.async(execute: {
                        UIApplication.shared.keyWindow?.makeToast( "Error downloading the file")
                    })
                }
            }
            task.resume()
        }
    }
}
