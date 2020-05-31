//
//  Line.swift
//  RankingSystem
//
//  Created by Chung Han Hsin on 2020/5/14.
//  Copyright © 2020 Chung Han Hsin. All rights reserved.
//

import UIKit
import CANumberTextLayer
import HsinUtils


//MARK: - LineViewDataSource

protocol LineViewDataSource: AnyObject {
  
  func lineViewMaxValueOfRankingView(_ lineView: LineView) -> Float
  
  func lineViewDrawLineDuration(_ lineView: LineView) -> TimeInterval
  func lineViewIconTransationDuration(_ lineView: LineView) -> TimeInterval
  
  func lineViewErasedColor(_ lineView: LineView) -> UIColor
  func lineViewStrokeColor(_ lineView: LineView) -> UIColor
  
  func lineViewWidth(_ lineView: LineView) -> CGFloat
  func lineViewHeight(_ lineView: LineView) -> CGFloat
  func lineViewImageLayerHeight(_ lineView: LineView) -> CGFloat
  func lineViewTextLayerHeight(_ lineView: LineView) -> CGFloat
  func lineViewMaxY(_ lineView: LineView) -> CGFloat
  
  func lineViewLineModel(_ lineView: LineView) -> LineModel
  
  func lineViewTextLayerTextColor(_ lineView: LineView) -> UIColor
  func lineViewTextLayerBackgroundColor(_ lineView: LineView) -> UIColor
  func lineViewTextLayerFontSize(_ lineView: LineView) -> CGFloat
}


//MARK: - LineViewDelegate

protocol LineViewDelegate: AnyObject {
  func lineViewDidAnimationStop(_ lineView: LineView, anim: CAAnimation, finished flag: Bool, id: String)
}

class LineView: UIView {
  //MARK: - Properties
  
  weak var dataSource: LineViewDataSource?
  weak var delegate: LineViewDelegate?
  lazy var viewModel = makeViewModel()
  lazy var idLabel = makeLabel(id: viewModel.id)
  lazy var imageLayer = makeImageLayer(image: viewModel.icon)
  lazy var textLayer = makeTextLayer()
  lazy var overallLayer = makeOverallLayer()
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    setupLayout()
    layer.addSublayer(overallLayer)
  }
}


//MARK: - Internal functions

extension LineView {
  func drawLine() {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set max num for LineView's dataSource")
    }
    let midX = dataSource.lineViewWidth(self) / 2
    setupOverallLayer()
    let lineLayer = makeLineLayer()
    layer.addSublayer(lineLayer)
    setPathForLineLayer(lineLayer: lineLayer, startedX: midX)
    let drawLineAnimation = makeDrawLineAnimation(lineLayer: lineLayer)
    let overallLayerTransation = makeOverallLayerTransationAnimation()
    lineLayer.add(drawLineAnimation, forKey: "drawLineAnimation")
    overallLayer.add(overallLayerTransation, forKey: "overallLayerTransation")
  }
}


//MARK: - Lazy initialization

extension LineView {
  
  fileprivate func makeLabel(id: String) -> UILabel {
    let label = UILabel()
    label.backgroundColor = .black
    label.textColor = .white
    label.font = .boldSystemFont(ofSize: 20)
    label.text = id
    label.textAlignment = .center
    return label
  }
  
  fileprivate func makeViewModel() -> LineViewModel {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set max num for LineView's dataSource")
    }
    let lineModel = dataSource.lineViewLineModel(self)
    let maxValue = dataSource.lineViewMaxValueOfRankingView(self)
    let height = dataSource.lineViewHeight(self)
    let maxY = dataSource.lineViewMaxY(self)
    return LineViewModel(lineModel: lineModel, rankingViewMaxValue: maxValue, lineViewHeight: height, maxY: maxY)
  }
  
  fileprivate func setupLayout() {
    addSubview(idLabel)
    idLabel.anchor(top: topAnchor, bottom: nil, leading: leadingAnchor, trailing: trailingAnchor, padding: .zero, size: .init(width: 0, height: 50))
  }
}

//MARK: - Private function

extension LineView {
  
  fileprivate func makeLineLayer() -> CAShapeLayer {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set max num for LineView's dataSource")
    }
    let width = CGFloat(Int(dataSource.lineViewWidth(self)))
    let strokeColor = dataSource.lineViewStrokeColor(self)
    let erasedColor = dataSource.lineViewErasedColor(self)
    let lineLayer = CAShapeLayer()
    lineLayer.lineWidth = width
    if viewModel.shouldEraseLine {
      lineLayer.strokeColor = erasedColor.cgColor
    } else {
      lineLayer.strokeColor = strokeColor.cgColor
    }
    return lineLayer
  }
  
  fileprivate func makeImageLayer(image: UIImage) -> CALayer {
    let layer = CALayer()
    layer.contents = image.cgImage
    layoutIfNeeded()
    layer.contentsGravity = .resizeAspect
    layer.backgroundColor = UIColor.red.cgColor
    layer.isGeometryFlipped = true
    return layer
  }
  
  fileprivate func makeTextLayer() -> CANumberTextlayer {
    let layer = CANumberTextlayer()
    layer.dataSource = self
    layer.setLayerProperties()
    return layer
  }
  
  fileprivate func makeOverallLayer() -> CALayer {
    let layer = CALayer()
    layer.addSublayer(imageLayer)
    layer.addSublayer(textLayer)
    layer.isHidden = true
    return layer
  }
  
  fileprivate func setupOverallLayer() {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set max num for LineView's dataSource")
    }
    let imageLayerHeight = dataSource.lineViewImageLayerHeight(self)
    let textLayerHeight = dataSource.lineViewTextLayerHeight(self)
    let lineViewWidth = dataSource.lineViewWidth(self)
    let overallLayerHeight = imageLayerHeight + textLayerHeight
    let overallLayerOriginY = viewModel.drawLineToValue - overallLayerHeight
    overallLayer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
    overallLayer.frame = CGRect(x: 0, y: overallLayerOriginY, width: lineViewWidth, height: overallLayerHeight)
    imageLayer.frame = CGRect(x: 0, y: 0, width: lineViewWidth, height: imageLayerHeight)
    textLayer.frame = CGRect(x: 0, y: imageLayer.frame.maxY, width: lineViewWidth, height: textLayerHeight)
    textLayer.launchDisplayLink()
  }
  
  fileprivate func setPathForLineLayer(lineLayer: CAShapeLayer, startedX: CGFloat) {
    let path = makeLinePath(startedX: startedX, viewModel: viewModel)
    lineLayer.path = path.cgPath
  }
  
  fileprivate func makeLinePath(startedX: CGFloat, viewModel: LineViewModel) -> UIBezierPath {
    let path = UIBezierPath()
    path.move(to: CGPoint.init(x: startedX, y: viewModel.drawLineFromValue))
    path.addLine(to: CGPoint.init(x: startedX, y: viewModel.drawLineToValue))
    return path
  }
  
  fileprivate func makeDrawLineAnimation(lineLayer: CAShapeLayer) -> CABasicAnimation {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set max num for LineView's dataSource")
    }
    let duration = dataSource.lineViewDrawLineDuration(self)
    let animation = CABasicAnimation(keyPath: "strokeEnd")
    animation.fromValue = 0
    animation.duration = duration
    animation.delegate = self
    animation.setValue("drawLineAnimation", forKey: "animation")
    animation.setValue(lineLayer, forKey: "layer")
    return animation
  }
  
  fileprivate func makeOverallLayerTransationAnimation() -> CAAnimation {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set max num for LineView's dataSource")
    }
    let duration = dataSource.lineViewIconTransationDuration(self)
    let imageLayerHeight = dataSource.lineViewImageLayerHeight(self)
    let textLayerHeight = dataSource.lineViewTextLayerHeight(self)
    let overallLayerHeight = imageLayerHeight + textLayerHeight
    
    let animation = CABasicAnimation(keyPath: "position.y")
    animation.fromValue = viewModel.drawLineFromValue - overallLayerHeight / 2
    animation.toValue = viewModel.drawLineToValue - overallLayerHeight / 2
    animation.duration = duration
    animation.fillMode = .forwards
    animation.isRemovedOnCompletion = false
    animation.delegate = self
    animation.setValue("overallLayerTransation", forKey: "animation")
    animation.setValue(overallLayer, forKey: "layer")
    return animation
  }
}

//MARK: - CAAnimationDelegate
extension LineView: CAAnimationDelegate {
  
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    viewModel.updateDrawLineToValue()
    let animationId = anim.value(forKey: "animation") as! String
    if animationId == "overallLayerTransation" {
      overallLayer.isHidden = false
    }
    delegate?.lineViewDidAnimationStop(self, anim: anim, finished: flag, id: viewModel.id)
  }
}


//MARK: - CANumberTextLayerDataSource

extension LineView: CANumberTextLayerDataSource {
  
  func animationNumberTextLayerStartValue(_ animationNumberLabel: CANumberTextlayer) -> Int {
    var value = Int(viewModel.value)
    for _ in 0 ... (String(value).count - 2) {
      value = value % 10
    }
    return value
  }
  
  func animationNumberTextLayerEndValue(_ animationNumberLabel: CANumberTextlayer) -> Int {
    let value = Int(viewModel.value)
    return value
  }
  
  func animationNumberTextLayerDuration(_ animationNumberLabel: CANumberTextlayer) -> TimeInterval {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set max num for LineView's dataSource")
    }
    return dataSource.lineViewDrawLineDuration(self)
  }
  
  func animationNumberTextLayerBackgroundColor(_ animationNumberLabel: CANumberTextlayer) -> UIColor {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set max num for LineView's dataSource")
    }
    return dataSource.lineViewTextLayerBackgroundColor(self)
  }
  
  func animationNumberTextLayerTextColor(_ animationNumberLabel: CANumberTextlayer) -> UIColor {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set max num for LineView's dataSource")
    }
    return dataSource.lineViewTextLayerTextColor(self)
  }
  
  func animationNumberTextLayerLabelFont(_ animationNumberLabel: CANumberTextlayer) -> UIFont {
    return UIFont.systemFont(ofSize: 0.0, weight: .light)
  }
  
  func animationNumberTextLayerLabelFontSize(_ animationNumberLabel: CANumberTextlayer) -> CGFloat {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set max num for LineView's dataSource")
    }
    return dataSource.lineViewTextLayerFontSize(self)
  }
  
  func animationNumberTextLayerTextAlignment(_ animationNumberLabel: CANumberTextlayer) -> CATextLayerAlignmentMode {
    return .center
  }
}
