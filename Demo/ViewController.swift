//
//  ViewController.swift
//  Demo
//
//  Created by Todd on 2018/11/21.
//  Copyright © 2018 TStrawberry. All rights reserved.
//

import UIKit
import Uncover

class ViewController: UIViewController {

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initialUncover()
        
        
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}


extension ViewController : FocusItemUncoverProtocol {

    func uncoverItem(for responder: UIResponder) -> FocusItem {
        return responder as! UIView
    }
    
    func move(_ item: FocusItem, by suggestion: Movement) {
        bottomConstraint.constant = bottomConstraint.constant - suggestion.numerical
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
}


