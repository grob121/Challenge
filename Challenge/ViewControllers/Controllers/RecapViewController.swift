import Foundation
import RxSwift
import RxCocoa
import Lottie

class RecapViewController: UIViewController {
  @IBOutlet private weak var eyebrowLabel: UILabel!
  @IBOutlet private weak var bodyLabel: UILabel!
  @IBOutlet private weak var firstAnswerButton: UIButton!
  @IBOutlet private weak var secondAnswerButton: UIButton!
  @IBOutlet private weak var thirdAnswerButton: UIButton!
  @IBOutlet private weak var firstAnswerContainerView: UIView!
  @IBOutlet private weak var secondAnswerContainerView: UIView!
  @IBOutlet private weak var thirdAnswerContainerView: UIView!
  @IBOutlet private weak var slideActionView: UIView!
  @IBOutlet private weak var topBorderView: UIView!
  @IBOutlet private weak var feedbackView: UIView!
  @IBOutlet private weak var feedbackLabel: UILabel!
  @IBOutlet private weak var actionButton: UIButton!
  @IBOutlet private weak var slideBottomConstraint: NSLayoutConstraint!
  @IBOutlet private weak var confettiContainerView: UIView!
  @IBOutlet private weak var confettiAnimationView: LottieAnimationView!
  @IBOutlet private weak var blockerView: UIView!
  
  private var filledAnswerButton: UIButton!
  
  var viewModel: RecapViewModel!
  
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupViews()
    bindViewModel()
    setupBindings()
  }
  
  private func setupViews() {
    addBorder(firstAnswerButton)
    addBorder(secondAnswerButton)
    addBorder(thirdAnswerButton)
    
    addBorder(firstAnswerContainerView)
    addBorder(secondAnswerContainerView)
    addBorder(thirdAnswerContainerView)
    
    actionButton.layer.cornerRadius = 8.0
    
    filledAnswerButton = UIButton()
  }
  
  private func addBorder(_ view: UIView) {
    view.layer.borderWidth = 1.0
    view.layer.cornerRadius = 8.0
    view.clipsToBounds = true
    view.layer.borderColor =  UIColor.black.withAlphaComponent(0.06).cgColor
  }
  
  func bindViewModel() {
    viewModel
      .output
      .eyebrow
      .asObservable()
      .bind(to: eyebrowLabel.rx.text)
      .disposed(by: disposeBag)
    
    viewModel
      .output
      .body
      .asObservable()
      .bind(to: bodyLabel.rx.text)
      .disposed(by: disposeBag)
    
    viewModel?
      .output
      .body
      .asObservable()
      .bind(onNext: { [weak self] body in
        guard let self = self,
              let bodyRange = body.range(of: "________ -") else {
          return
        }
        
        self.bodyLabel.attributedText = NSAttributedString(string: body,
                                                           attributes: [NSAttributedString.Key.font: UIFont(name: "EuclidCircularB-Regular",
                                                                                                            size: 22.0) ?? UIFont()])
        self.filledAnswerButton.frame = self.bodyLabel.boundingRect(forCharacterRange: NSRange(bodyRange,
                                                                                               in: body)) ?? .zero
        self.addBorder(self.filledAnswerButton)
        
        self.filledAnswerButton.backgroundColor = .white
        self.firstAnswerButton.titleLabel?.font = UIFont(name: "EuclidCircularB-Mdium", size: 16)
        self.filledAnswerButton.setTitleColor(UIColor("#212121"), for: .normal)
        self.filledAnswerButton.isUserInteractionEnabled = true
        
        self.bodyLabel.addSubview(self.filledAnswerButton)
        self.bodyLabel.isUserInteractionEnabled = true
      })
      .disposed(by: disposeBag)
    
    viewModel
      .output
      .firstAnswer
      .asObservable()
      .bind(to: firstAnswerButton.rx.title())
      .disposed(by: disposeBag)
    
    viewModel
      .output
      .secondAnswer
      .asObservable()
      .bind(to: secondAnswerButton.rx.title())
      .disposed(by: disposeBag)
    
    viewModel
      .output
      .thirdAnswer
      .asObservable()
      .bind(to: thirdAnswerButton.rx.title())
      .disposed(by: disposeBag)
    
    viewModel
      .output
      .filledAnswer
      .asObservable()
      .bind(to: filledAnswerButton.rx.title())
      .disposed(by: disposeBag)
    
    viewModel
      .output
      .hideFirstAnswer
      .asObservable()
      .bind(to: firstAnswerButton.rx.isHidden)
      .disposed(by: disposeBag)
    
    viewModel
      .output
      .hideSecondAnswer
      .asObservable()
      .bind(to: secondAnswerButton.rx.isHidden)
      .disposed(by: disposeBag)
    
    viewModel
      .output
      .hideThirdAnswer
      .asObservable()
      .bind(to: thirdAnswerButton.rx.isHidden)
      .disposed(by: disposeBag)
    
    viewModel
      .output
      .hideFilledAnswer
      .asObservable()
      .bind(to: filledAnswerButton.rx.isHidden)
      .disposed(by: disposeBag)
    
    viewModel
      .output
      .hideTopBorder
      .asObservable()
      .bind(to: topBorderView.rx.isHidden)
      .disposed(by: disposeBag)
    
    viewModel
      .output
      .hideFeedbackView
      .asObservable()
      .bind(to: feedbackView.rx.isHidden)
      .disposed(by: disposeBag)
    
    viewModel
      .output
      .feedback
      .asObservable()
      .bind(to: feedbackLabel.rx.text)
      .disposed(by: disposeBag)
    
    viewModel
      .output
      .isActionEnabled
      .asObservable()
      .bind(onNext: { [weak self] isEnabled in
        guard let self = self else { return }
        self.actionButton.backgroundColor = UIColor(isEnabled ? "#6442EF" : "#DDD5FB")
      })
      .disposed(by: disposeBag)
    
    viewModel
      .output
      .actionTitle
      .asObservable()
      .bind(to: actionButton.rx.title())
      .disposed(by: disposeBag)
    
    viewModel
      .output
      .showSlideView
      .drive(onNext: { [weak self] in
        guard let self = self else { return }
        
        DispatchQueue.main.async {
          self.slideBottomConstraint.constant = -UIScreen.main.bounds.height
          self.view.layoutIfNeeded()
          
          self.slideBottomConstraint.constant = 112.0
          UIView.animate(withDuration: 0.5,
                         delay: 0,
                         options: .curveEaseOut) {
            self.view.layoutIfNeeded()
          }
        }
      })
      .disposed(by: disposeBag)
    
    viewModel
      .output
      .dismissSlideView
      .drive(onNext: { [weak self] in
        guard let self = self else { return }
        
        self.slideBottomConstraint.constant = -UIScreen.main.bounds.height
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: { [weak self] in
                         guard let self = self else { return }
                        
                         self.view.layoutIfNeeded()
                       },
                       completion: nil)
      })
      .disposed(by: disposeBag)
    
    viewModel
      .output
      .showConfettiView
      .drive(onNext: { [weak self] showConfettiView in
        guard let self = self else { return }
        
        if showConfettiView {
          confettiAnimationView.contentMode = .scaleAspectFill
          confettiAnimationView.loopMode = .loop
          confettiAnimationView.play()
          confettiContainerView.isHidden = false
        } else {
          confettiAnimationView.stop()
          confettiContainerView.isHidden = true
        }
      })
      .disposed(by: disposeBag)
    
    viewModel
      .output
      .isCorrectAnswer
      .asObservable()
      .bind(onNext: { [weak self] isCorrect in
        guard let self = self else { return }
        
        self.topBorderView.backgroundColor = UIColor(isCorrect ? "#3AB27D" : "#FC3021")
        self.feedbackLabel.text = isCorrect ? "You’re correct!" : "Try again"
      })
      .disposed(by: disposeBag)
    
    viewModel
      .output
      .hideBlockerView
      .asObservable()
      .bind(to: blockerView.rx.isHidden)
      .disposed(by: disposeBag)
  }
  
  private func setupBindings() {
    firstAnswerButton
      .rx
      .tap
      .bind(to: viewModel.input.didTapFirstAnswer)
      .disposed(by: disposeBag)
    
    secondAnswerButton
      .rx
      .tap
      .bind(to: viewModel.input.didTapSecondAnswer)
      .disposed(by: disposeBag)
    
    thirdAnswerButton
      .rx
      .tap
      .bind(to: viewModel.input.didTapThirdAnswer)
      .disposed(by: disposeBag)
    
    filledAnswerButton
      .rx
      .tap
      .bind(to: viewModel.input.didTapFilledAnswer)
      .disposed(by: disposeBag)
    
    actionButton
      .rx
      .tap
      .bind(to: viewModel.input.didTapAction)
      .disposed(by: disposeBag)
  }
}
