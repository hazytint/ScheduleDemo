//
//  CanvasView.swift
//  scheduleDemo
//
//  Created by wuhua on 15/12/15.
//  Copyright © 2015年 Talkpal. All rights reserved.
//

import UIKit

let leftPadding: CGFloat = 40
let topPadding: CGFloat = 40

class CanvasView: UIView {

    var enableArray: [Bool] = [Bool].init(count: 7*12, repeatedValue: false)
    var fillMode: Bool = true

    var tapGesture: UITapGestureRecognizer!
    var panGesture: UIPanGestureRecognizer!
    var startIndex: (x: Int, y: Int)?
    var toIndex: (x:Int, y:Int)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.whiteColor()
        panGesture = UIPanGestureRecognizer(target: self, action: "didPan:")
        self.addGestureRecognizer(panGesture)
        tapGesture = UITapGestureRecognizer(target: self, action: "didTap:")
        self.addGestureRecognizer(tapGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let cellWidth = (rect.width - leftPadding) / 7 - 4
        let cellHeight = (rect.height - topPadding) / 12 - 4

        for i in 0..<7 {
            for j in 0..<12 {
                var bool = enableArray[(i * 12) + j]
                if startIndex != nil && i == startIndex!.x {
                    let jq = min(startIndex!.y, toIndex!.y)
                    let je = max(startIndex!.y, toIndex!.y)
                    if jq <= j && j <= je {
                        bool = fillMode
                    }
                }

                if bool {
                    CGContextSetFillColorWithColor(context, UIColor.blueColor().CGColor)
                } else {
                    CGContextSetFillColorWithColor(context, UIColor(white: 0.95, alpha: 1).CGColor)
                }

                let r = CGRectMake(40 + (cellWidth + 4)*CGFloat(i), topPadding + (cellHeight + 4)*CGFloat(j), cellWidth, cellHeight)
                let b = UIBezierPath(roundedRect: r, cornerRadius: 4)
                b.fill()
//                CGContextFillPath(context)
            }
        }
    }


    @objc private func didTap(gesture: UITapGestureRecognizer) {
        let point = gesture.locationInView(self)
        let i = Int((point.x - leftPadding) / (bounds.width - leftPadding) * 7)
        let j = Int((point.y - topPadding) / (bounds.height - topPadding) * 12)
        enableArray[(i * 12) + j] = !enableArray[(i * 12) + j]
        setNeedsDisplay()
    }

    @objc private func didPan(gesture: UIPanGestureRecognizer) {
        let point = gesture.locationInView(self)
        let i = Int((point.x - leftPadding) / (bounds.width - leftPadding) * 7)
        let j = Int((point.y - topPadding) / (bounds.height - topPadding) * 12)
        if !(0 <= i && i < 7 && 0 <= j && j < 12) {
            return
        }
        switch gesture.state {
        case .Began:
            fillMode = !enableArray[(i * 12) + j]
            startIndex = (i,j)
            toIndex = (i,j)
        case .Changed:
            if startIndex != nil && abs(i - startIndex!.x) <= 1 {
                toIndex = (startIndex!.x,j)
                setNeedsDisplay()
            }
        case .Ended:
            let i = startIndex!.x
            let j = min(startIndex!.y, toIndex!.y)
            let je = max(startIndex!.y, toIndex!.y)
            for jj in j...je {
                enableArray[(i * 12) + jj] = fillMode
            }
            startIndex = nil
            toIndex = nil
        default:
            break
        }
    }


}

