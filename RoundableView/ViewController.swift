//
//  ViewController.swift
//  RoundableView
//
//  Created by xiaoyuan on 2020/6/18.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var buttonWidth: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        button.roundMethod = .complete()
        button.border = UIView.Border(width: 1, color: .red)
        
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] timer in
            guard let `self` = self else {
                return
            }
            let minSize = min(self.view.frame.size.width, self.view.frame.size.height)
            self.buttonWidth.constant = max(50.0, CGFloat(arc4random_uniform(UInt32(minSize) - 30)))
        }
        
        RunLoop.current.add(timer, forMode: .default)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        toggleRound()
    }
    
    func toggleRound() {
        
    }
}

