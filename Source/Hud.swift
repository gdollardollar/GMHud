//
//  HudManager.swift
//  Pods
//
//  Created by Guillaume on 11/9/16.
//
//

import UIKit

open class Hud: UIViewController, UIGestureRecognizerDelegate {
    
    public enum ContentType {
        case loader
        case text
        case buttons
        case custom(Int)
    }

    public typealias Action = (Hud, UIView) -> (Bool)
    
    public static let coverTag = -1
    
    fileprivate var action: Action?
    
    // ---------------------------------------------------------------------------------
    // MARK: -
    
    //TODO: covercolor does nothing for now...
    public struct Appearance {
        public var coverColor: UIColor?
        public var tintColor: UIColor?
        public var blurStyle: UIBlurEffect.Style?
        public var font: UIFont?
        public var buttonFont: UIFont?
        public var horizontalSpacing: CGFloat = 40
        public var verticalSpacing: CGFloat = 10
        
        public var preferredStatusBarStyle: UIStatusBarStyle = .default
        
        fileprivate init() { }
    }
    
    public static var appearance = Appearance()
    
    @IBInspectable
    open var coverColor: UIColor? {
        return Hud.appearance.coverColor
    }
    
    open var tintColor: UIColor? {
        return Hud.appearance.tintColor
    }
    
    open var blurStyle: UIBlurEffect.Style? {
        return Hud.appearance.blurStyle
    }
    
    open var font: UIFont? {
        return Hud.appearance.font
    }
    
    open var buttonFont: UIFont? {
        return Hud.appearance.buttonFont
    }
    
    open var horizontalSpacing: CGFloat {
        return Hud.appearance.horizontalSpacing
    }
    
    open var verticalSpacing: CGFloat {
        return Hud.appearance.verticalSpacing
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return Hud.appearance.preferredStatusBarStyle
    }
    
    // ---------------------------------------------------------------------------------
    
    
    @IBOutlet public
    weak var content: UIView?
    
    public fileprivate(set) var contentType: ContentType?
    
    @IBOutlet
    fileprivate weak var effectView: UIVisualEffectView?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.storyboard == nil && self.nibName == nil {
            resetEffectView()
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(Hud.tapRecognized(sender:)))
            tap.delegate = self
            view.addGestureRecognizer(tap)
            
            view.tag = Hud.coverTag
            
            view.backgroundColor = coverColor
        }
    }
    
    private func resetEffectView() {
        effectView?.removeFromSuperview()
        
        guard let blur = blurStyle else {
            return
        }
        
        let v = UIVisualEffectView(frame: view.bounds)
        view.insertSubview(v, at: 0)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(0)-[v]-(0)-|", options: [],
                                                           metrics: nil, views: ["v": v]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[v]-(0)-|", options: [],
                                                           metrics: nil, views: ["v": v]))
        view.translatesAutoresizingMaskIntoConstraints = false
        effectView = v
        
        effectView!.effect = UIBlurEffect(style: blur)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.isHidden = true
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.view.isHidden = false
        self.animateDisplay()
    }
    
    public func set(content view: UIView, animated: Bool, contentMode: UIView.ContentMode = .center, type: ContentType? = nil, action: Action? = nil) {
        
        let oldContent = content
        content = view
        let oldContentType = contentType
        contentType = type
        
        let completion: (Bool) -> () = { _ in
            oldContent?.removeFromSuperview()
        }
        
        let container = effectView?.contentView ?? self.view!
        container.addSubview(view)
        
        switch contentMode {
        case .bottom:
            container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[view]-0-|", options: [], metrics: nil, views: ["view": view]))
            container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view]-0-|", options: [], metrics: nil, views: ["view": view]))
        case .center:
            container.addConstraints([
                NSLayoutConstraint(item: container, attribute: .centerX,
                                   relatedBy: .equal,
                                   toItem: view, attribute: .centerX,
                                   multiplier: 1, constant: 0),
                NSLayoutConstraint(item: container, attribute: .centerY,
                                   relatedBy: .equal,
                                   toItem: view, attribute: .centerY,
                                   multiplier: 1, constant: 0)
                ])
            
        default:
            container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[view]-0-|", options: [], metrics: nil, views: ["view": view]))
            container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": view]))
            
        }
        
        self.action = action

        if animated && oldContent != nil {
            animateContent(from: (oldContent!, oldContentType), to: (content!, contentType), completion: completion)
        } else {
            completion(true)
        }
    }
    
    public static func loading() -> Hud {
        let hud = Hud()
        Manager.instance.display(hud: hud)
        hud.set(content: hud.instantiateLoader(), animated: false, type: .loader)
        return hud
    }

    @discardableResult
    public static func display(text: String, buttons: [String] = [], action: Action? = nil) -> Hud {
        let hud = Hud()
        hud.set(text: text, buttons: buttons, animated: false, action: action)
        Manager.instance.display(hud: hud)
        return hud
    }
    
    open func display() {
        Manager.instance.display(hud: self)
    }
    
    @IBAction
    open func dismiss() {
        Manager.instance.dismiss(hud: self)
    }
    
    open func setLoading(animated: Bool = true) {
        set(content: instantiateLoader(), animated: animated, type: .loader)
    }
    
    open func set(text: String, buttons: [String] = [], animated: Bool = true, action: Action? = nil) {
        let vertical = UIStackView(arrangedSubviews: [instantiateLabel(text: text)])
        
        vertical.axis = .vertical
        vertical.alignment = .center
        vertical.distribution = .equalSpacing
        vertical.spacing = verticalSpacing
        vertical.translatesAutoresizingMaskIntoConstraints = false
        
        if !buttons.isEmpty {
            
            let horizontal = UIStackView(arrangedSubviews: buttons.enumerated().map({ i, title in
                let b = self.instantiateButton(title: title)
                b.tag = i
                return b
            }))
            
            horizontal.axis = .horizontal
            horizontal.alignment = .fill
            horizontal.distribution = .equalSpacing
            horizontal.spacing = horizontalSpacing
            vertical.addArrangedSubview(horizontal)
            
        }
        set(content: vertical, animated: animated, type: .text, action: action)
    }
    
    open func instantiateLoader() -> UIView {
        let activity = UIActivityIndicatorView(style: .whiteLarge)
        activity.color = self.tintColor
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.startAnimating()
        return activity
    }
    
    open func instantiateLabel(text: String) -> UIView {
        let label = UILabel()
        label.textColor = tintColor
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = view.bounds.width - 100
        label.textAlignment = .center
        label.font = font
        return label
    }
    
    open func instantiateButton(title: String) -> UIView {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(tintColor, for: .normal)
        button.titleLabel?.font = buttonFont ?? font
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(type(of: self).buttonAction(sender:)), for: .touchUpInside)
        return button
    }
    
    @IBAction public func buttonAction(sender: UIView) {
        if action?(self, sender) ?? true {
            dismiss()
        }
    }
    
    open func animateDisplay() {
        
        if effectView == nil {
            
            self.view.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.view.alpha = 1
            }
            
        } else {
            let effect = effectView!.effect
            
            effectView!.effect = nil
            content?.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.content?.alpha = 1
                self.effectView!.effect = effect
            }
        }
    }
    
    open func animateDismiss(completion: @escaping (Bool) -> ()) {
        
        if effectView == nil {
            
            UIView.animate(withDuration: 0.3, animations: {
                self.view.alpha = 0
            }, completion: completion)
            
            
        } else {
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.effectView?.effect = nil
                self.content?.alpha = 0
//                self.alpha = 0
                
            }, completion: completion)
        }
    }
    
    open func animateContent(from: (view: UIView?, type: ContentType?),
                             to: (view: UIView?, type: ContentType?),
                             completion: @escaping (Bool) -> ()) {
        let key = "animateContent"
        let container = from.view?.superview ?? to.view!.superview!
        
        to.view?.isHidden = true
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.3)
        CATransaction.setCompletionBlock { () -> Void in
            
            container.layer.removeAnimation(forKey: key)
            completion(true)
        }
        
        let transition = CATransition()
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        container.layer.add(transition, forKey: key)
        
        from.view?.isHidden = true
        to.view?.isHidden = false
        
        CATransaction.commit()
    }
    
    open func coverTapShouldBegin(tap: UITapGestureRecognizer) -> Bool {
        switch contentType {
        case .some(.text):
            return true
        default:
            return false
        }
    }
    
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let t = gestureRecognizer as? UITapGestureRecognizer,
            t.view == self.view {
            return coverTapShouldBegin(tap: t)
        }
        return true
    }

    @IBAction
    open func tapRecognized(sender: UITapGestureRecognizer) {
        if action?(self, sender.view!) ?? true {
            dismiss()
        }
    }
    
}
