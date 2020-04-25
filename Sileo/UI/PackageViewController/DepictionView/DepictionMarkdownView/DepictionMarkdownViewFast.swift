//
//  DepictionMarkdownViewFast.swift
//  Sileo
//
//  Created by CoolStar on 11/18/19.
//  Copyright © 2019 CoolStar. All rights reserved.
//

import Down

@objc(DepictionMarkdownView)
class DepictionMarkdownView: DepictionBaseView, CSTextViewActionHandler {
    var attributedString: NSAttributedString?
    var htmlString: String = ""

    let useSpacing: Bool
    let useMargins: Bool

    let heightRequested: Bool

    let textView: CSTextView

    required init?(dictionary: [String: Any], viewController: UIViewController, tintColor: UIColor) {
        guard let markdown = dictionary["markdown"] as? String else {
            return nil
        }
        
        if let packageViewController = viewController as? PackageViewController,
            let repo = packageViewController.package?.sourceRepo,
            let host = repo.url?.host?.lowercased(),
            host.contains("nepeta.me") {
            let lowerMarkdown = markdown.lowercased()
            let search1 = ["package", "apt", "repo"]
            let search2 = ["manager", "browser", "downloader", "installer"]
            guard search1.filter({ lowerMarkdown.contains($0) }).isEmpty || search2.filter({ lowerMarkdown.contains($0) }).isEmpty else {
                return nil
            }
            
            let search4 = ["link", "get", "download", "install", "view", "preview", "try"]
            let search5 = ["zebra", "installer", "cydia", "manager"]
            guard search4.filter({ lowerMarkdown.contains($0) }).isEmpty || search5.filter({ lowerMarkdown.contains($0) }).isEmpty else {
                return nil
            }
        }
        
        useSpacing = (dictionary["useSpacing"] as? Bool) ?? true
        useMargins = (dictionary["useMargins"] as? Bool) ?? true

        heightRequested = false

        textView = CSTextView(frame: .zero)
        super.init(dictionary: dictionary, viewController: viewController, tintColor: tintColor)

        textView.backgroundColor = .clear
        addSubview(textView)

        htmlString = markdown

        reloadMarkdown()
        guard attributedString != nil else {
            return nil
        }

        textView.translatesAutoresizingMaskIntoConstraints = false

        let margins: CGFloat = useMargins ? 16 : 0
        let spacing: CGFloat = useSpacing ? 13 : 0
        let bottomSpacing: CGFloat = useSpacing ? 13 : 0
        NSLayoutConstraint.activate([
            textView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: margins),
            textView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -margins),
            textView.topAnchor.constraint(equalTo: self.topAnchor, constant: spacing),
            textView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -bottomSpacing)
        ])
        
        weak var weakSelf: DepictionMarkdownView? = self
        if UIColor.useSileoColors {
            NotificationCenter.default.addObserver(weakSelf as Any,
                                                   selector: #selector(DepictionMarkdownView.reloadMarkdown),
                                                   name: UIColor.sileoDarkModeNotification,
                                                   object: nil)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13, *) {
            self.reloadMarkdown()
        }
    }
    
    @objc func reloadMarkdown() {
        var red = CGFloat(0)
        var green = CGFloat(0)
        var blue = CGFloat(0)
        var alpha = CGFloat(0)
        tintColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        red *= 255
        green *= 255
        blue *= 255
        
        let down = Down(markdownString: htmlString)
        var config = DownStylerConfiguration()
        var colors = DepictionColorCollection()
        colors.link = tintColor
        config.colors = colors
        config.fonts = DepictionFontCollection()
        let styler = DownStyler(configuration: config)
        if let attributedString = try? down.toAttributedString(.default, styler: styler) {
            textView.attributedText = attributedString
            self.attributedString = attributedString
            textView.setNeedsDisplay()
        }
    }

    override func depictionHeight(width: CGFloat) -> CGFloat {
        let margins: CGFloat = useMargins ? 32 : 0
        let spacing: CGFloat = useSpacing ? 33 : 0

        guard let attributedString = attributedString else {
            return 0
        }

        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        let targetSize = CGSize(width: width - margins, height: CGFloat.greatestFiniteMagnitude)
        let fitSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, attributedString.length), nil, targetSize, nil)
        return fitSize.height + spacing
    }
    
    func process(action: String) -> Bool {
        DepictionButton.processAction(action, parentViewController: self.parentViewController, openExternal: false)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textView.updateConstraintsIfNeeded()
    }
}
