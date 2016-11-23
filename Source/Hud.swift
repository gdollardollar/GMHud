//
//  HudManager.swift
//  Pods
//
//  Created by Guillaume on 11/9/16.
//
//

import UIKit

open class Hud: UIViewController {
    
    public enum ContentType {
        case loader
        case text
        case buttons
        case custom(Int)
    }
    
    public typealias Action = (Hud, UIView) -> (Bool)
    
    fileprivate var coverAction: Action?
    
    public static var coverColor: UIColor?
    
    @IBInspectable
    public var coverColor: UIColor? = Hud.coverColor {
        didSet {
            effectView.backgroundColor = coverColor
        }
    }
    
    public static var tintColor: UIColor?
    
    @IBInspectable
    public var tintColor: UIColor? = Hud.tintColor {
        didSet {
            view?.tintColor = tintColor
            content?.tintColor = tintColor
            
            guard contentType != nil else {
                return
            }
            
            switch contentType! {
            case .loader:
                (content as? UIActivityIndicatorView)?.color = tintColor
            case .text:
                (content as? UILabel)?.textColor = tintColor
            default:
                break
            }
            
        }
    }
    
    public static var blurStyle: Int?

    @IBInspectable
    public var blurStyle: Int? = Hud.blurStyle {
        didSet {
            guard blurStyle != nil else {
                effectView.effect = nil
                return
            }
            effectView?.effect = UIBlurEffect(style: UIBlurEffectStyle(rawValue: self.blurStyle!)!)
        }
    }
    
    public static var font: UIFont?
    
    public var font: UIFont? = Hud.font {
        didSet {
            (content as? UILabel)?.font = font
        }
    }
    
    
    @IBOutlet weak var content: UIView?
    
    var contentType: ContentType?
    
    @IBOutlet
    fileprivate weak var effectView: UIVisualEffectView!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if effectView == nil {
            let v = UIVisualEffectView(frame: view.bounds)
            view.insertSubview(v, at: 0)
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(0)-[v]-(0)-|", options: [],
                                                               metrics: nil, views: ["v": v]))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[v]-(0)-|", options: [],
                                                               metrics: nil, views: ["v": v]))
            view.translatesAutoresizingMaskIntoConstraints = false
            effectView = v
            
            effectView.backgroundColor = coverColor
            blurStyle = Hud.blurStyle
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(Hud.tapRecognized(sender:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
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
    
    public func setContent(view: UIView, animated: Bool, type: ContentType? = nil) {
        
        let oldContent = content
        content = view
        let oldContentType = contentType
        contentType = type
        
        let completion: (Bool) -> () = { _ in
            oldContent?.removeFromSuperview()
        }
        effectView.contentView.addSubview(view)
        self.view.addConstraints([
            NSLayoutConstraint(item: self.view, attribute: .centerX,
                               relatedBy: .equal,
                               toItem: view, attribute: .centerX,
                               multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.view, attribute: .centerY,
                               relatedBy: .equal,
                               toItem: view, attribute: .centerY,
                               multiplier: 1, constant: 0)
            ])
        
        if animated && oldContent != nil {
            animateContent(from: (oldContent!, oldContentType), to: (content!, contentType), completion: completion)
        } else {
            completion(true)
        }
    }
}

extension Hud {
    
    public static func loading() -> Hud {
        let hud = Hud()
        Manager.instance.display(hud: hud)
        hud.setContent(view: hud.instantiateLoader(), animated: false, type: .loader)
        return hud
    }
    
    @discardableResult
    public static func display(text: String) -> Hud {
        let hud = Hud()
        hud.setContent(view: hud.instantiateLabel(text: text), animated: false, type: .text)
        Manager.instance.display(hud: hud)
        return hud
    }
    
    public func set(text: String, animated: Bool = true) {
        setContent(view: instantiateLabel(text: text), animated: animated, type: .text)
    }
    
    public func dismiss() {
        Manager.instance.dismiss(hud: self)
    }
    
    @discardableResult
    public func onCover(action action: Action?) -> Hud {
        coverAction = action
        return self
    }
    
}

//MARK: - Content

extension Hud {
    
    open func instantiateLoader() -> UIView {
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
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
        return label
    }
    
}


//MARK: - Animations
extension Hud {
    
    open func animateDisplay() {
        
        if blurStyle == nil {
            self.view.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.view.alpha = 1
            }
        } else {
            effectView.effect = nil
            content?.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.content?.alpha = 1
                self.effectView.effect = UIBlurEffect(style: UIBlurEffectStyle(rawValue: self.blurStyle!)!)
            }
        }
    }
    
    open func animateDismiss(completion: @escaping (Bool) -> ()) {
        
        if blurStyle == nil {
            
            UIView.animate(withDuration: 0.3, animations: {
                self.view.alpha = 0
            }, completion: completion)
            
            
        } else {
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.effectView.effect = nil
                self.content?.alpha = 0
//                self.alpha = 0
                
            }, completion: completion)
        }
    }
    
    open func animateContent(from: (view: UIView?, type: ContentType?),
                             to: (view: UIView?, type: ContentType?),
                             completion: @escaping (Bool) -> ()) {
        let key = "animateContent"
        
        to.view?.isHidden = true
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.3)
        CATransaction.setCompletionBlock { () -> Void in
            
            self.effectView.contentView.layer.removeAnimation(forKey: key)
            completion(true)
        }
        
        let transition = CATransition()
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        effectView.contentView.layer.add(transition, forKey: key)
        
        from.view?.isHidden = true
        to.view?.isHidden = false
        
        CATransaction.commit()
    }
    
}

extension Hud: UIGestureRecognizerDelegate {
    
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        switch contentType {
        case .some(.text):
            return true
        default:
            return false
        }
    }
    
    open func tapRecognized(sender: UITapGestureRecognizer) {
        if coverAction?(self, sender.view!) ?? true {
            dismiss()
        }
    }
    
}
