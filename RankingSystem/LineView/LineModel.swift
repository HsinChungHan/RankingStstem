//
//  DataModel.swift
//  ScrollViewTest
//
//  Created by Chung Han Hsin on 2020/5/16.
//  Copyright © 2020 Chung Han Hsin. All rights reserved.
//

import UIKit

class LineModel {
  
  private(set) var id: String
  private(set) var value: Float
  private(set) var rank: Int
  private(set) var icon: UIImage
  
  init(id: String, value: Float, rank: Int, icon: UIImage) {
    self.id = id
    self.value = value
    self.rank = rank
    self.icon = icon
  }
}

extension LineModel: Comparable {
  static func == (lhs: LineModel, rhs: LineModel) -> Bool {
    if lhs.value == rhs.value {
      return true
    }
    return false
  }
  
  static func < (lhs: LineModel, rhs: LineModel) -> Bool {
    if lhs.value < rhs.value {
      return true
    }
    return false
  }
}

