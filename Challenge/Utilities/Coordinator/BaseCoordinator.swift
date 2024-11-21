import UIKit

protocol Coordinator: AnyObject {
  var parentCoordinator: Coordinator? { get set }
  var childCoordinators : [Coordinator] { get set }
  func start()
  func didFinish()
}

extension Coordinator {
  func store(coordinator: Coordinator) {
    childCoordinators.append(coordinator)
  }
  
  func free(coordinator: Coordinator) {
    childCoordinators = childCoordinators.filter { $0 !== coordinator }
  }
}

class BaseCoordinator : NSObject, Coordinator {
  weak var parentCoordinator: Coordinator?
  
  var childCoordinators : [Coordinator] = []
  
  var isCompleted: ((_ identifier: String?) -> ())?
  
  func start() {
    fatalError("Children should implement `start`.")
  }
  
  func didFinish() {
    fatalError("Children should implement `did Finish`.")
  }
}
