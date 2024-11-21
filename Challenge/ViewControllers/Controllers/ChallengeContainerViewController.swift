import Foundation
import RxSwift

class ChallengeContainerViewController: UIViewController {
  @IBOutlet private weak var progressView: UIProgressView!
  @IBOutlet private weak var backButton: UIButton!
  @IBOutlet private weak var closeButton: UIButton!
  
  var viewModel: ChallengeContainerViewModel!
  var containerView: UIView!
  
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupViews()
    bindViewModel()
    setupBindings()
  }
  
  private func setupViews() {    
    containerView = UIView(frame: CGRect(origin: CGPoint(x: view.bounds.origin.x,
                                                         y: view.bounds.origin.y + 136),
                                         size: CGSize(width: view.bounds.width,
                                                      height: view.bounds.height)))
    containerView.backgroundColor = .white
    
    self.view.addSubview(containerView)
  }
  
  func bindViewModel() {
    viewModel
      .output
      .progress
      .asObservable()
      .bind(to: progressView.rx.progress)
      .disposed(by: disposeBag)
    
    viewModel
      .output
      .shouldHideBack
      .asObservable()
      .bind(to: backButton.rx.isHidden)
      .disposed(by: disposeBag)
    
    viewModel
      .output
      .shouldHideClose
      .asObservable()
      .bind(to: closeButton.rx.isHidden)
      .disposed(by: disposeBag)
  }
  
  private func setupBindings() {
    rx
      .viewWillAppear
      .bind(to: viewModel.input.viewWillAppear)
      .disposed(by: disposeBag)
    
    backButton
      .rx
      .tap
      .bind(to: viewModel.input.didTapBack)
      .disposed(by: disposeBag)
    
    closeButton
      .rx
      .tap
      .bind(to: viewModel.input.didTapClose)
      .disposed(by: disposeBag)
  }
}
