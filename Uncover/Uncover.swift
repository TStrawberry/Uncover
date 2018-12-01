//
//  Uncover.swift
//  Uncover
//
//  Created by Todd on 2018/11/21.
//  Copyright © 2018 TStrawberry. All rights reserved.
//

import UIKit

public enum Movement {
    case up(CGFloat)
    case down(CGFloat)
    case none
    
    public var numerical: CGFloat {
        switch self {
        case let .up(value) where value != 0: return -value
        case let .down(value) where value != 0: return value
        default: return 0
        }
    }
    
}

public protocol FocusItem : UICoordinateSpace {
    var frame: CGRect { get }
}

extension UIView : FocusItem { }

public protocol FocusItemUncoverProtocol : NSObjectProtocol {
    
    func uncoverItem(for responder: UIResponder) -> FocusItem
    
    func move(_ item: FocusItem, by suggestion: Movement)
    
}

public extension FocusItemUncoverProtocol {
    
    func initialUncover() {
        
        NotificationCenter.default
            .addObserver(
                forName: UIResponder.keyboardWillChangeFrameNotification,
                object: nil,
                queue: nil) { [weak self] (notification) in
            if let userInfo = notification.userInfo {
                self?.keyBoardFrameWillChange(userInfo: userInfo)
            }
        }
        
        NotificationCenter.default
            .addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: nil) { [weak self] (notification) in
                    if let userInfo = notification.userInfo {
                        self?.keyboardWillShow(userInfo: userInfo)
                    }
        }
        
        NotificationCenter.default
            .addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: nil) { [weak self] (notification) in
                    if let userInfo = notification.userInfo {
                        self?.keyboardWillHide(userInfo: userInfo)
                    }
        }
        
    }
    
    func disposeUncover() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
}

struct KeyBoardUserInfo {
    
    /*
     [AnyHashable("UIKeyboardCenterBeginUserInfoKey"): NSPoint: {207, 871.5},
     AnyHashable("UIKeyboardBoundsUserInfoKey"): NSRect: {{0, 0}, {414, 271}},
     AnyHashable("UIKeyboardFrameEndUserInfoKey"): NSRect: {{0, 465}, {414, 271}},
     AnyHashable("UIKeyboardCenterEndUserInfoKey"): NSPoint: {207, 600.5},
     AnyHashable("UIKeyboardIsLocalUserInfoKey"): 1,
     AnyHashable("UIKeyboardAnimationDurationUserInfoKey"): 0.25,
     AnyHashable("UIKeyboardAnimationCurveUserInfoKey"): 7,
     AnyHashable("UIKeyboardFrameBeginUserInfoKey"): NSRect: {{0, 736}, {414, 271}}]
     */
    
    var endFrame: CGRect { return userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect }
    
    private let userInfo: [AnyHashable: Any]
    
    init(_ userInfo: [AnyHashable: Any]) {
        self.userInfo = userInfo
    }

}

var contexts: [Int: CGRect] = [:]


extension FocusItemUncoverProtocol {
    
    func keyBoardFrameWillChange(userInfo: [AnyHashable: Any]) {
        print(#function)
        guard let currentResponder = UIResponder.currentFirstResponder() else { return }
        
        let keyBoardUserInfo = KeyBoardUserInfo(userInfo)
        let endFrame = keyBoardUserInfo.endFrame
        
        let focusItem = uncoverItem(for: currentResponder)
        
        let screenOrientedFrame = focusItem.convert(CGRect(origin: .zero, size: focusItem.frame.size), to: UIScreen.main.coordinateSpace)
        
        let distance = screenOrientedFrame.maxY - endFrame.minY
        let movement: Movement = distance > 0 ? .up(distance) : {
            if let origin = contexts[focusItem.hash] {
                let originOrientedDistance = screenOrientedFrame.maxY - origin.maxY
                return originOrientedDistance > 0 ? Movement.up(originOrientedDistance) : Movement.down(-originOrientedDistance)
            }
            return Movement.none
            }()
        
        move(focusItem, by: movement)
        
        if contexts.keys.contains(focusItem.hash) == false {
            contexts[focusItem.hash] = screenOrientedFrame
        }
        
    }
    
    func keyboardWillShow(userInfo: [AnyHashable: Any]) {
        print(#function)
    }
    
    func keyboardWillHide(userInfo: [AnyHashable: Any]) {
        print(#function)
    }
    
}



extension UIResponder {
    
    private weak static var _currentFirstResponder: UIResponder? = nil
    
    fileprivate class func currentFirstResponder() -> UIResponder? {
        UIResponder._currentFirstResponder = nil
        let selector = #selector(UIResponder.findFirstResponder(sender:))
        UIApplication.shared
            .sendAction(selector, to: nil, from: nil, for: nil)
        return UIResponder._currentFirstResponder
    }
    
    @objc internal func findFirstResponder(sender: AnyObject) {
        UIResponder._currentFirstResponder = self
    }
    
}

