//
//  SegmentedControl.swift
//  SmartChannel
//
//  Created by Marc Anderson on 3/11/16.
//  Copyright © 2016 Marc Adam. All rights reserved.
//

import UIKit

@IBDesignable class SegmentedControl: UIControl {

    private let controllerBackgroundColor = Theme.Colors.LightBackgroundColor.color
    private let buttonBackgroundColor = Theme.Colors.BackgroundColor.color
    private let offTextColor = Theme.Colors.HighlightLightColor.color
    private let onTextColor = Theme.Colors.HighlightColor.color

    private var labels = [UILabel]()
    var thumbView = UIView()

    @IBInspectable var fontSize: CGFloat = 14.0 {
        didSet {
            setupLabels()
        }
    }

    var items = ["First", "Second"] {
        didSet {
            setupLabels()
        }
    }

    var selectedSegmentIndex = 0 {
        didSet {
            displayNewSelectedSegmentIndex()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupView()
    }

    func setupView() {
        layer.cornerRadius = frame.height / 2
        layer.borderWidth = 2
        layer.borderColor = controllerBackgroundColor.CGColor
        backgroundColor = controllerBackgroundColor

        setupLabels()

        insertSubview(thumbView, atIndex: 0)
    }

    func setupLabels() {
        for label in labels {
            label.removeFromSuperview()
        }

        labels.removeAll(keepCapacity: true)

        for index in 0..<items.count {
            let label = UILabel(frame: CGRectZero)
            label.font = UIFont.systemFontOfSize(fontSize)
            label.text = items[index]
            label.textAlignment = .Center
            label.textColor = index == selectedSegmentIndex ? onTextColor : offTextColor
            self.addSubview(label)
            labels.append(label)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let inset: CGFloat = 2.0

        var selectedFrame = self.bounds
        let newWidth = CGRectGetWidth(selectedFrame) / CGFloat(items.count)
        selectedFrame.size.width = newWidth
        thumbView.frame = selectedFrame
        thumbView.frame = CGRectInset(selectedFrame, inset, inset)
        thumbView.backgroundColor = buttonBackgroundColor
        thumbView.layer.cornerRadius = thumbView.frame.height / 2.0
        thumbView.layer.borderWidth = 1
        thumbView.layer.borderColor = offTextColor.CGColor

        let labelWidth = self.bounds.width / CGFloat(labels.count)
        let labelHeight = self.bounds.height

        for index in 0..<labels.count {
            let label = labels[index]
            let xPosition = CGFloat(index) * labelWidth
            label.frame = CGRectMake(xPosition, 0, labelWidth, labelHeight)
            label.frame = CGRectInset(label.frame, inset, inset)
        }
    }

    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)

        var calculatedIndex: Int?

        for (index, item) in labels.enumerate() {
            if item.frame.contains(location) {
                calculatedIndex = index
            }
        }

        if calculatedIndex != nil {
            selectedSegmentIndex = calculatedIndex!
            sendActionsForControlEvents(.ValueChanged)
        }

        return false
    }

    func displayNewSelectedSegmentIndex() {
        for label in labels {
            label.textColor = offTextColor
        }
        let label = labels[selectedSegmentIndex]
        label.textColor = onTextColor
        self.thumbView.frame = label.frame
    }
}
