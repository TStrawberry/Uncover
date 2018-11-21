//
//  Uncover.swift
//  Uncover
//
//  Created by Todd on 2018/11/21.
//  Copyright © 2018 TStrawberry. All rights reserved.
//

import UIKit

public protocol FocusItem {
    var frame: CGRect { get }
}

extension UIResponder : FocusItem {
    public var frame: CGRect { return accessibilityFrame }
}


protocol ViewUncoverProtocol : NSObjectProtocol {
    
    func uncoverView(for responder: UIResponder) -> FocusItem
    
}

extension ViewUncoverProtocol {
    
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
    }
    
    func disposeUncover() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
}

extension ViewUncoverProtocol {
    
    func keyBoardFrameWillChange(userInfo: [AnyHashable: Any]?) {
        
        guard let `userInfo` = userInfo else { return }
        
        let keyboardEndFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        
    }
    
}








extension UIResponder {
    
    private weak static var _currentFirstResponder: UIResponder? = nil
    
    fileprivate class func currentFirstResponder() -> UIResponder? {
        UIResponder._currentFirstResponder = nil
        let selector = #selector(UIResponder.findFirstResponder(sender:))
        UIApplication.shared.sendAction(selector, to: nil, from: nil, for: nil)
        return UIResponder._currentFirstResponder
    }
    
    @objc internal func findFirstResponder(sender: AnyObject) {
        UIResponder._currentFirstResponder = self
    }
}

