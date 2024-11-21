import Foundation
import RxSwift

enum ChallengeScreenFlow {
  case recap(viewModel: RecapViewModel)
  case multipleChoice(viewModel: MultipleChoiceViewModel)
  case nextScreen(pageIndex: Int)
  case previousScreen(pageIndex: Int)
}

class ChallengeCoordinator: BaseCoordinator {
  let window: UIWindow
  var viewModel: ChallengeContainerViewModel?
  var challengeViewController: ChallengeContainerViewController?
  private let disposeBag = DisposeBag()
  
  deinit {
    print("Deinit - ChallengeCoordinator")
  }
  
  init(window: UIWindow,
       viewModel: ChallengeContainerViewModel? = ChallengeContainerViewModel()) {
    self.window = window
    self.viewModel = viewModel
    
    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
    challengeViewController = mainStoryboard.instantiateViewController(withIdentifier: "ChallengeContainerViewController") as? ChallengeContainerViewController
    challengeViewController?.viewModel = viewModel
    self.window.rootViewController = challengeViewController
  }
  
  override func start() {
    viewModel?
      .output
      .showScreen
      .drive(onNext: { [weak self] screen in
        guard let self = self else { return }
        self.showNextScreen(screen: screen)
      })
      .disposed(by: disposeBag)
  }
  
  func deInitializeObject() {
    challengeViewController?.viewModel = nil
    challengeViewController = nil
    viewModel = nil
  }
  
  private func showNextScreen(screen: ChallengeScreenFlow?) {
    guard let screen = screen else { return }
    switch screen {
      case let .recap(viewModel):
        let recapViewController = RecapViewController()
        recapViewController.viewModel = viewModel
        challengeViewController?.add(recapViewController,
                                     frame: challengeViewController?.containerView.frame)
      case let .multipleChoice(viewModel):
        let multipleChoiceViewController = MultipleChoiceViewController()
        multipleChoiceViewController.viewModel = viewModel
        challengeViewController?.add(multipleChoiceViewController,
                                     frame: challengeViewController?.containerView.frame)
      case let .nextScreen(pageIndex):
        challengeViewController?.children[pageIndex].view.isHidden = true
      case let .previousScreen(pageIndex):
        challengeViewController?.children[pageIndex].view.isHidden = false
    }
  }
}
