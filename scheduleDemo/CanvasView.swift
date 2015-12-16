//
//  CanvasView.swift
//  scheduleDemo
//
//  Created by wuhua on 15/12/15.
//  Copyright © 2015年 Talkpal. All rights reserved.
//

import UIKit

let tableInset: UIEdgeInsets = UIEdgeInsetsMake(40, 40, 0, 0)
let minCellHeight: CGFloat = 36
let minCellWidth: CGFloat = 36
let maxCellHeight: CGFloat = 50
let maxCellWidth: CGFloat =  50
let numberOfColum: Int = 7
let numberOfRow: Int = 10
let startHour: Int = 9
let cellColor: UIColor = UIColor(white: 0.97, alpha: 1)
let cellHighLightColor: UIColor = UIColor.blueColor()

class CanvasView: UIView {

    var enableArray: [[Bool]] = [[Bool]](count: numberOfColum, repeatedValue: [Bool](count: numberOfRow, repeatedValue: false))
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

    func cellSizeForRect(rect: CGRect) -> CGSize {
        let tableWidth = (rect.width - tableInset.left - tableInset.right)
        var cellWidth = tableWidth / CGFloat(numberOfColum)
        cellWidth = max(cellWidth, minCellWidth)
        cellWidth = min(cellWidth, maxCellWidth)
        let tableHeight = (rect.height - tableInset.top - tableInset.bottom)
        var cellHeight = tableHeight / CGFloat(numberOfRow)
        cellHeight = max(cellHeight, minCellHeight)
        cellHeight = min(cellHeight, maxCellHeight)
        return CGSizeMake(cellWidth, cellHeight)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }


    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let cellSize = cellSizeForRect(rect)

        for i in 0..<numberOfColum {
            for j in 0..<numberOfRow {
                var bool = enableArray[i][j]

                //拖动时
                if startIndex != nil && i == startIndex!.x {
                    let minY = min(startIndex!.y, toIndex!.y)
                    let maxY = max(startIndex!.y, toIndex!.y)
                    if minY <= j && j <= maxY {
                        bool = fillMode
                    }
                }

                if bool {
                    CGContextSetFillColorWithColor(context, cellHighLightColor.CGColor)
                } else {
                    CGContextSetFillColorWithColor(context, cellColor.CGColor)
                }

                let r = CGRectMake(tableInset.top + (cellSize.width)*CGFloat(i) + 2, tableInset.top + (cellSize.height)*CGFloat(j) + 2, cellSize.width - 4, cellSize.height - 4)
                let b = UIBezierPath(roundedRect: r, cornerRadius: 4)
                b.fill()
            }
        }
    }

    @objc private func didTap(gesture: UITapGestureRecognizer) {
        let point = gesture.locationInView(self)
        let cellSize = cellSizeForRect(bounds)
        let i = Int((point.x - tableInset.left) / cellSize.width)
        let j = Int((point.y - tableInset.top) / cellSize.height)
        enableArray[i][j] = !enableArray[i][j]
        setNeedsDisplay()
    }

    @objc private func didPan(gesture: UIPanGestureRecognizer) {
        let point = gesture.locationInView(self)
        let cellSize = cellSizeForRect(bounds)
        let i = Int((point.x - tableInset.left) / cellSize.width)
        let j = Int((point.y - tableInset.top) / cellSize.height)
        if !(0 <= i && i < 7 && 0 <= j && j < 12) {
            return
        }
        switch gesture.state {
        case .Began:
            fillMode = !enableArray[i][j]
            startIndex = (i,j)
            toIndex = (i,j)
        case .Changed:
            if startIndex != nil && abs(i - startIndex!.x) <= 1 {
                toIndex = (startIndex!.x,j)
                setNeedsDisplay()
            }
        case .Failed:
            fallthrough
        case .Cancelled:
            fallthrough
        case .Ended:
            if startIndex == nil { break }
            let i = startIndex!.x
            let minY = min(startIndex!.y, toIndex!.y)
            let maxY = max(startIndex!.y, toIndex!.y)
            for j in minY...maxY {
                enableArray[i][j] = fillMode
            }
            startIndex = nil
            toIndex = nil
            print(scheduleJSON())
        default:
            break
        }
    }

    private func scheduleJSON() -> String {
        var json = "{"
        for i in 0..<numberOfColum {
            json += String(format: "\"%d\":[", i)
            var startY: Int?
            for j in 0..<numberOfRow {
                let b = enableArray[i][j]
                if startY == nil && b == true{
                    startY = j
                } else if startY != nil && (b == false || j == numberOfRow - 1) {
                    json += String(format: "[%d:00,", startY! + startHour)
                    json += String(format: "%d:00]", j + startHour)
                    startY = nil
                }
            }
            json += "],"
        }
        json += "}"
        return json
    }


}

