//
//  BlogTableViewCell.swift
//  Quickride
//
//  Created by Quick Ride on 8/2/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class BlogTableViewCell: UITableViewCell {
    
    @IBOutlet weak var blogImage: UIImageView!
    
    @IBOutlet weak var blogTitle: UILabel!
        
    var blog : Blog?
    var viewController : UIViewController?
    
    func initializeViews(blog : Blog?, viewController : UIViewController){
        self.blog = blog
        self.viewController = viewController
        if let imageURI = blog?.blogImageUri{
            ImageCache.getInstance().getImageFromCache(imageUrl: imageURI, imageSize: ImageCache.ORIGINAL_IMAGE, handler: {(image, imageURI) in
                self.blogImage.image = image?.roundedCornerImage
            })
        }
        blogTitle.text = blog?.blogTitle
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showBlog(_:))))
    }
    @objc func showBlog(_ gesture : UITapGestureRecognizer){
        if blog?.linkUrl != nil {
            let queryItems = URLQueryItem(name: "&isMobile", value: "true")
            var urlcomps = URLComponents(string :  blog?.linkUrl ?? "")
            urlcomps?.queryItems = [queryItems]
            if urlcomps?.url != nil {
                let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                webViewController.initializeDataBeforePresenting(titleString: "Blog", url: urlcomps?.url, actionComplitionHandler: nil)
                viewController?.navigationController?.pushViewController(webViewController, animated: false)
            } else {
                UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
            }
        }
    }
}
