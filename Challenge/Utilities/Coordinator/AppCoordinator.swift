import UIKit

class AppCoordinator: BaseCoordinator {
  var window: UIWindow
  var challengeCoordinator: ChallengeCoordinator!
  
  init(window: UIWindow){
    self.window = window
  }
  
  override func start() {    
    challengeCoordinator = ChallengeCoordinator(window: self.window)
    challengeCoordinator.parentCoordinator = self
    self.store(coordinator: challengeCoordinator)
    
    challengeCoordinator.isCompleted = { [weak self] (id) in
      guard let self = self else { return }
      if id == nil {
        
      }
      
      self.challengeCoordinator.deInitializeObject()
      self.free(coordinator: self.challengeCoordinator)
      self.challengeCoordinator = nil
    }
    
    challengeCoordinator.start()
  }
}
