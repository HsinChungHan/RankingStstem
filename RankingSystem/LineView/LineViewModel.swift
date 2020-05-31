//
//  LineViewModel.swift
//  ScrollViewTest
//
//  Created by Chung Han Hsin on 2020/5/16.
//  Copyright © 2020 Chung Han Hsin. All rights reserved.
//

import UIKit

class LineViewModel {
  
  private(set) var lineModel: LineModel
  
  var value: Float {
    return lineModel.value
  }
  
  var id: String {
    return lineModel.id
  }
  
  var icon: UIImage {
    return lineModel.icon
  }
  
  var rank: Int {
    return lineModel.rank
  }
  
  private(set) var rankingViewMaxValue: Float
  private(set) var lineViewHeight: CGFloat
  private(set) var lineViewMaxY: CGFloat

  private(set) var transationFromValue: CGFloat = 500
  private(set) var drawLineFromValue: CGFloat = 0.0
  
  var drawLineToValue: CGFloat {
    return calculateDrawLineToValue()
  }
  
  var shouldEraseLine: Bool {
    return drawLineToValue > drawLineFromValue
  }
    
  init(lineModel model: LineModel, rankingViewMaxValue: Float, lineViewHeight: CGFloat, maxY: CGFloat) {
    self.lineModel = model
    self.rankingViewMaxValue = rankingViewMaxValue
    self.lineViewHeight = lineViewHeight
    drawLineFromValue = maxY
    lineViewMaxY = maxY
  }
  
  func setNextRoundTransationFromValue(_ value: CGFloat) {
    self.transationFromValue = value
  }
  
  func setLineModel(lineModel model: LineModel) {
    self.lineModel = model
  }
  
  //FIXME: - 因為畫 BeizerPath 的時候，若 toValue 不為整數時，下次要以此 toValue 當 fromeValue 的時候，便會多一條細線，所以這邊才會先轉型為 Int，確保是整數後，再傳出 CGFLoat
  func calculateDrawLineToValue() -> CGFloat {
    let valueheight = lineViewHeight * CGFloat(value / rankingViewMaxValue)
    return CGFloat(Int(lineViewMaxY - valueheight))
  }

  func updateDrawLineToValue() {
    drawLineFromValue = drawLineToValue
  }
}

