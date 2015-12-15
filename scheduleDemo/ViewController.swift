//
//  ViewController.swift
//  scheduleDemo
//
//  Created by wuhua on 15/12/15.
//  Copyright © 2015年 Talkpal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let canvasView = CanvasView()
        view.addSubview(canvasView)

        canvasView.translatesAutoresizingMaskIntoConstraints = false
        var constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[v]-0-|", options: [], metrics: nil, views: ["v":canvasView])
        view.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[v]-0-|", options: [], metrics: nil, views: ["v":canvasView])
        view.addConstraints(constraints)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

