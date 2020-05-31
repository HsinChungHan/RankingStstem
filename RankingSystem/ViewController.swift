//
//  ViewController.swift
//  RankingSystem
//
//  Created by Chung Han Hsin on 2020/5/28.
//  Copyright © 2020 Chung Han Hsin. All rights reserved.
//

import UIKit
import HsinUtils

class ViewController: UIViewController {

  var currentTimerIndex = 0
  let lineModel = LineModel(id: "A", value: 8000, rank: 5, icon: UIImage(named: "g0")!)
  let lineView = LineView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
    view.addSubview(lineView)
    lineView.anchor(top: view.topAnchor, bottom: view.bottomAnchor, leading: view.leadingAnchor, trailing: nil, padding: .init(top: 44, left: 100, bottom: 44, right: 0), size: .init(width: 100, height: 0))
    lineView.dataSource = self
    TimerManager.shared.delegate = self
    TimerManager.shared.dataSource = self
    TimerManager.shared.setupTimer()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
}

let widthOfLineView: CGFloat = 100
let textLayerHeight: CGFloat = 60

extension ViewController: LineViewDataSource {
  func lineViewMaxValueOfRankingView(_ lineView: LineView) -> Float {
    return 10000
  }
  
  func lineViewDrawLineDuration(_ lineView: LineView) -> TimeInterval {
    return 2
  }
  
  func lineViewIconTransationDuration(_ lineView: LineView) -> TimeInterval {
    return 2
  }
  
  func lineViewErasedColor(_ lineView: LineView) -> UIColor {
    return #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
  }
  
  func lineViewStrokeColor(_ lineView: LineView) -> UIColor {
    return #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
  }
  
  func lineViewWidth(_ lineView: LineView) -> CGFloat {
    return widthOfLineView
  }
  
  func lineViewHeight(_ lineView: LineView) -> CGFloat {
    return lineView.bounds.height * 2 / 3
  }
  
  func lineViewImageLayerHeight(_ lineView: LineView) -> CGFloat {
    return widthOfLineView * 2 - textLayerHeight
  }
  
  func lineViewTextLayerHeight(_ lineView: LineView) -> CGFloat {
    return textLayerHeight
  }
  
  func lineViewMaxY(_ lineView: LineView) -> CGFloat {
    return lineView.bounds.maxY
  }
  
  func lineViewLineModel(_ lineView: LineView) -> LineModel {
    return lineModel
  }
  
  func lineViewTextLayerTextColor(_ lineView: LineView) -> UIColor {
    return UIColor.black
  }
  
  func lineViewTextLayerBackgroundColor(_ lineView: LineView) -> UIColor {
    return #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
  }
  
  func lineViewTextLayerFontSize(_ lineView: LineView) -> CGFloat {
    return 30
  }
}


extension ViewController: TimerManagerDataSource {
  func timerManagerTimeInterval(_ timerManager: TimerManager) -> TimeInterval {
    return 3
  }
}

extension ViewController: TimerManagerDelegate {
  func timerManagerFires(_ timerManager: TimerManager, timer: Timer) {
    
    if currentTimerIndex == 1 {
      updateLineModel()
    }
    lineView.drawLine()
    currentTimerIndex += 1
    if currentTimerIndex == 2 {
      TimerManager.shared.invalidateTimer()
    }
  }
  
  func timerManagerInvalidate(_ timerManager: TimerManager) {
    
  }
  
  fileprivate func updateLineModel() {
    lineView.viewModel.setLineModel(lineModel: LineModel(id: "A", value: 4000, rank: 5, icon: UIImage(named: "g0")!))
  }
}
