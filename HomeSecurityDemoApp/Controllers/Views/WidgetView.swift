//
//  WidgetView.swift
//  HomeSecurityDemoApp
//
//  Created by Ilya Myakotin on 12/09/16.
//  Copyright © 2016 Ilya Myakotin. All rights reserved.
//

import Foundation
import UIKit

final class WidgetView: UIView {

    enum Alignment {
        case Center
        case Leading
        case Trailing

        init(stackAlignment: UIStackViewAlignment) {
            switch stackAlignment {
            case .Center:
                self = Alignment.Center
            case .Leading:
                self = Alignment.Leading
            case .Trailing:
                self = Alignment.Trailing
            default:
                self = Alignment.Leading
            }
        }
    }

    @IBOutlet private weak var bodyContainer: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!

    var maximimSpacing: CGFloat = 40.0 {
        didSet {
            populateWidget()
        }
    }
    var minimimSpacing: CGFloat = 10.0 {
        didSet {
            populateWidget()
        }
    }
    var multiline = false {
        didSet {
            populateWidget()
        }
    }

    var rowsSpacing: CGFloat = 10.0 {
        didSet {
            bodyContainer.spacing = rowsSpacing
            populateWidget()
        }
    }

    var items: [UIView] = [] {
        willSet {
            items.forEach { $0.removeFromSuperview() }
        }
        didSet {
            populateWidget()
        }
    }

    var itemsAlignment: Alignment = .Leading {
        didSet {
            bodyContainer.alignment = UIStackViewAlignment(widgetAlignment: itemsAlignment)
            populateWidget()
        }
    }

    private var stacks: [UIStackView] = []

    private func populateWidget() {
        stacks.forEach { $0.removeFromSuperview() }
        stacks = []
        var itemsToLayout = items
        while true {
            let stack = createStackView()
            let leftovers = fill(stack: stack, with: itemsToLayout)
            if (!multiline && stacks.count > 0) || leftovers.count == itemsToLayout.count {
                break
            }
            bodyContainer.addArrangedSubview(stack)
            stacks.append(stack)
            itemsToLayout = leftovers
        }
        if let spacing = stacks.map({ $0.spacing }).sort().first {
            stacks.forEach { $0.spacing = spacing }
        }
    }

    private func fill(stack stackView: UIStackView, with items: [UIView]) -> [UIView] {
        stackView.spacing = minimimSpacing
        for viewsCount in (0..<items.count).reverse() {
            let slice = items.prefix(viewsCount + 1)
            let totalExpectedWidth: CGFloat = slice.reduce(0.0) { $0.0 + $0.1.frame.width } + ((slice.count > 0) ? CGFloat(slice.count - 1) * minimimSpacing : 0.0)
            if totalExpectedWidth <= bodyContainer.frame.width {
                let extectedSpacing = (bodyContainer.frame.width - slice.reduce(0.0) { $0.0 + $0.1.frame.width }) / ((slice.count > 1) ? CGFloat(slice.count - 1) : 1.0)
                stackView.spacing = extectedSpacing >= maximimSpacing ? maximimSpacing : extectedSpacing
                slice.forEach { view in
                    view.translatesAutoresizingMaskIntoConstraints = false
                    stackView.addArrangedSubview(view)
                }
                return Array(items.suffixFrom(viewsCount + 1))
            }
        }
        return items
    }

    private func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .Horizontal
        stackView.alignment = .Center
        return stackView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        bodyContainer.alignment = UIStackViewAlignment(widgetAlignment: itemsAlignment)
        bodyContainer.spacing = rowsSpacing
        layer.cornerRadius = 6.0
        layer.masksToBounds = true
    }
}

extension UIStackViewAlignment {
    init(widgetAlignment: WidgetView.Alignment) {
        switch widgetAlignment {
        case .Center:
            self = UIStackViewAlignment.Center
        case .Leading:
            self = UIStackViewAlignment.Leading
        case .Trailing:
            self = UIStackViewAlignment.Trailing
        }
    }
}