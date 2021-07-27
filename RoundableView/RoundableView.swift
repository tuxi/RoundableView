//
//  RoundableView.swift
//  RoundableView
//
//  Created by xiaoyuan on 2020/6/18.
//

import UIKit

extension UIView {
    /// 定义圆角的方法
    public enum RoundingMethod {
        /// 完整的圆
        /// 以横向或者竖向的轴心半径画圆角
        case complete(axis: NSLayoutConstraint.Axis = .horizontal)
        /// 部分圆，根据radius画圆
        case partial(radius: CGFloat)
        /// 无圆角
        case none
    }
    
    public struct Border {
        public var width: CGFloat
        public var color: UIColor
        public init(width: CGFloat, color: UIColor = .white) {
            self.width = width
            self.color = color
        }
    }

    private struct Keys {
        static var round = "com.objc.round"
    }
}

/// `UIView` 便捷添加圆角的协议
/// 解决在``view.frame`改变时圆角未改变的问题，以及使用系统方法设置圆角必须设置`layer.masksToBounds`导致无法添加阴影的问题
public protocol RoundableView where Self: UIView {
    
    /// 圆角方法，分为：完整圆角、部分圆角、无
    var roundMethod: RoundingMethod { get set }
    /// 圆角的角，分为：上、下、左、右、全部
    var roundedCorners: UIRectCorner { get set }
    /// 边框，由于圆角是设置了`view.mask`属性，会导致使用系统方法添加圆角无效，所以扩展了`border`属性
    var border: Border? { get set }
    
    /// 更新圆角和边框
    func applyRounding()
}

public extension RoundableView where Self: UIView {
    
    func applyRounding() {
        switch roundMethod {
        case .complete(let position):
            var radius: CGFloat = 0
            switch position {
            case .horizontal:
                radius = bounds.width / 2
            case .vertical:
                radius = bounds.height / 2
            @unknown default:
                break
            }
            self._round(corners: roundedCorners, radius: radius)
        case .partial(let radius):
            self._round(corners: roundedCorners, radius: radius)
        case .none:
            layer.mask = nil
            if let border = self.border {
                layer.borderWidth = border.width
                layer.borderColor = border.color.cgColor
            }
        }
    }
}

extension UIView: RoundableView {
    public var border: Border? {
        get {
            return self.round?.border
        }
        set {
            if self.round == nil {
                self.round = Round(target: self)
            }
            self.round?.border = newValue
            DispatchQueue.main.async {
                self.applyRounding()
            }
        }
    }
    
    
    public var roundMethod: RoundingMethod {
        get {
            return self.round?.method ?? .none
        }
        set {
            if self.round == nil {
                self.round = Round(target: self)
            }
            self.round?.method = newValue
            DispatchQueue.main.async {
                self.applyRounding()
            }
        }
    }
    
    public var roundedCorners: UIRectCorner {
        get {
            return self.round?.corners ?? .allCorners
        }
        set {
            if self.round == nil {
                self.round = Round(target: self)
            }
            self.round?.corners = newValue
            DispatchQueue.main.async {
                self.applyRounding()
            }
        }
    }
    
    
}

private class Round: NSObject {
    weak var target: UIView?
    var method: UIView.RoundingMethod = .none
    var corners: UIRectCorner = .allCorners
    var border: UIView.Border? = nil
    let keyPath = "bounds"
    init(target: UIView) {
        super.init()
        self.target = target
        target.addObserver(self, forKeyPath: keyPath, options: [.old, .new, .initial], context: nil)
    }
    
    deinit {
        target?.removeObserver(self, forKeyPath: keyPath)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let new = change?[.newKey] as? CGRect ?? .zero
        let old = change?[.oldKey] as? CGRect ?? .zero
        //        debugPrint(bounds)
        if keyPath == self.keyPath, !old.equalTo(new) {
            target?.applyRounding()
        }
    }
}

private extension UIView {
    var round: Round? {
        get {
            return objc_getAssociatedObject(self, &Keys.round) as? Round
        }
        set {
            objc_setAssociatedObject(self, &Keys.round, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @discardableResult
    func _round(corners: UIRectCorner, radius: CGFloat) -> CAShapeLayer {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        
        if let border = self.border {
            layer.sublayers?.removeAll(where: { $0 is BorderLayerShapeLayer })
            let borderLayer = BorderLayerShapeLayer()
            borderLayer.frame = bounds
            borderLayer.path = path.cgPath
            borderLayer.lineWidth = border.width
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.strokeColor = border.color.cgColor
            layer.addSublayer(borderLayer)
        }
        return mask
    }
}
private class BorderLayerShapeLayer: CAShapeLayer {}
