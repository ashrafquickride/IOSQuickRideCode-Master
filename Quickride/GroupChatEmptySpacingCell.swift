//
//  GroupChatEmptySpacingCell.swift
//
//
//  Created by Anki on 13/12/15.
//
//

import Foundation
class GroupChatEmptySpacingCell : UITableViewCell {
    
    
    override func awakeFromNib() {
      AppDelegate.getAppDelegate().log.debug("")
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
      AppDelegate.getAppDelegate().log.debug("")
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
