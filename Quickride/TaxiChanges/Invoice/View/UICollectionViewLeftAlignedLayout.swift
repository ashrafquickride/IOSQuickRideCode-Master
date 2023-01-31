//
//  UICollectionViewLeftAlignedLayout.swift
//  Quickride
//
//  Created by Quick Ride on 4/15/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
final class UICollectionViewLeftAlignedLayout: UICollectionViewFlowLayout {

  private var layouts: [IndexPath: UICollectionViewLayoutAttributes] = [:]

  override func prepare() {
    super.prepare()
    layouts = [:]
  }

  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var newAttributesArray = [UICollectionViewLayoutAttributes]()
    let superAttributesArray = super.layoutAttributesForElements(in: rect)!
    for (index, attributes) in superAttributesArray.enumerated() {
      if index == 0 || superAttributesArray[index - 1].frame.origin.y != attributes.frame.origin.y {
        attributes.frame.origin.x = sectionInset.left
      } else {
        let previousAttributes = superAttributesArray[index - 1]
        let previousFrameRight = previousAttributes.frame.origin.x + previousAttributes.frame.width
        attributes.frame.origin.x = previousFrameRight + minimumInteritemSpacing
      }
      newAttributesArray.append(attributes)
    }
    newAttributesArray.forEach { layouts[$0.indexPath] = $0 }
    return newAttributesArray
  }

  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    layouts[indexPath]
  }
}
