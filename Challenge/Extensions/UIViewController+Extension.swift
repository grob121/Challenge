import UIKit

extension UIViewController {  
  func add(_ child: UIViewController, frame: CGRect? = nil) {
    addChild(child)
    
    child.view.frame = frame ?? view.frame
    view.addSubview(child.view)
    
    child.didMove(toParent: self)
  }
  
  func remove() {
    guard parent != nil else {
      return
    }
    
    willMove(toParent: nil)
    remove()
    
    view.removeFromSuperview()
  }
}
