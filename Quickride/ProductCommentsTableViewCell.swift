//
//  ProductCommentsTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 20/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ProductCommentsTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var topCommnetsCountView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    private var productComments = [ProductComment]()
    private var isFromPostedProduct = false
    
    override func awakeFromNib() {
        commentsTableView.register(UINib(nibName: "ReceivedCommentTableViewCell", bundle: nil), forCellReuseIdentifier: "ReceivedCommentTableViewCell")
        commentsTableView.register(UINib(nibName: "AnswerCommnetTableViewCell", bundle: nil), forCellReuseIdentifier: "AnswerCommnetTableViewCell")
        commentsTableView.estimatedRowHeight = 120
        commentsTableView.rowHeight = UITableView.automaticDimension
    }
    
    func initialiseAllCommentsOfProduct(productComments: [ProductComment],isFromPostedProduct: Bool){
        prepareProductComments(productComments: productComments)
        self.isFromPostedProduct = isFromPostedProduct
        if isFromPostedProduct{
            topCommnetsCountView.isHidden = false
            countLabel.text = String(format: Strings.no_of_comments, arguments: [String(productComments.count)])
            topViewHeightConstraint.constant = 45
        }else{
            topViewHeightConstraint.constant = 0
            topCommnetsCountView.isHidden = true
        }
        commentsTableView.reloadData()
        tableViewHeightConstraint.constant = commentsTableView.contentSize.height
    }
    
    private func prepareProductComments(productComments: [ProductComment]){
        var comments = [ProductComment]()
        for productComment in productComments{
            if productComment.parentId == nil{
                comments.append(productComment)
                for productComment2 in productComments{
                    if  productComment.id == productComment2.parentId{
                        comments.append(productComment2)
                    }
                }
            }
        }
        self.productComments = comments
    }
}

//MARK:UITableViewDataSource
extension ProductCommentsTableViewCell: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        productComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if productComments[indexPath.row].parentId != nil{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCommnetTableViewCell", for: indexPath) as! AnswerCommnetTableViewCell
            cell.initialiseAnswerComment(productComment: productComments[indexPath.row])
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReceivedCommentTableViewCell", for: indexPath) as! ReceivedCommentTableViewCell
            cell.initialiseComment(productComment: productComments[indexPath.row], isFromPostedProduct: isFromPostedProduct)
            return cell
        }
        
    }
}
