import Foundation
import RxSwift
import RxCocoa

class RecapViewModel: ChallengeBaseViewModelType {
  struct Input {
    let didTapFirstAnswer: AnyObserver<Void>
    let didTapSecondAnswer: AnyObserver<Void>
    let didTapThirdAnswer: AnyObserver<Void>
    let didTapFilledAnswer: AnyObserver<Void>
    let didTapAction: AnyObserver<Void>
    let isActionEnabled: AnyObserver<Bool>
  }
  
  struct Output {
    let showScreen: Driver<ChallengeScreenFlow?>
    let eyebrow: Driver<String>
    let body: Driver<String>
    let firstAnswer: Driver<String>
    let secondAnswer: Driver<String>
    let thirdAnswer: Driver<String>
    let filledAnswer: Driver<String>
    let hideFirstAnswer: Driver<Bool>
    let hideSecondAnswer: Driver<Bool>
    let hideThirdAnswer: Driver<Bool>
    let hideFilledAnswer: Driver<Bool>
    let hideTopBorder: Driver<Bool>
    let hideFeedbackView: Driver<Bool>
    let isActionEnabled: Driver<Bool>
    let feedback: Driver<String>
    let actionTitle: Driver<String>
    let showSlideView: Driver<Void>
    let dismissSlideView: Driver<Void>
    let showConfettiView: Driver<Bool>
    let isCorrectAnswer: Driver<Bool>
    let hideBlockerView: Driver<Bool>
  }
  
  fileprivate struct Subject {
    let showScreen: PublishSubject<ChallengeScreenFlow?>
    let eyebrow: BehaviorSubject<String>
    let body: BehaviorSubject<String>
    let firstAnswer: BehaviorSubject<String>
    let secondAnswer: BehaviorSubject<String>
    let thirdAnswer: BehaviorSubject<String>
    let filledAnswer: BehaviorSubject<String>
    let didTapFirstAnswer: PublishSubject<Void>
    let didTapSecondAnswer: PublishSubject<Void>
    let didTapThirdAnswer: PublishSubject<Void>
    let didTapFilledAnswer: PublishSubject<Void>
    let hideFirstAnswer: BehaviorSubject<Bool>
    let hideSecondAnswer: BehaviorSubject<Bool>
    let hideThirdAnswer: BehaviorSubject<Bool>
    let hideFilledAnswer: BehaviorSubject<Bool>
    let pageIndexRelay: BehaviorRelay<Int>
    let firstAnswerRelay: BehaviorRelay<Answer>
    let secondAnswerRelay: BehaviorRelay<Answer>
    let thirdAnswerRelay: BehaviorRelay<Answer>
    let filledAnswerRelay: BehaviorRelay<Answer>
    let correctAnswerRelay: BehaviorRelay<String>
    let actionTitleRelay: BehaviorRelay<String>
    let didTapAction: PublishSubject<Void>
    let hideTopBorder: BehaviorSubject<Bool>
    let hideFeedbackView: BehaviorSubject<Bool>
    let isActionEnabled: BehaviorSubject<Bool>
    let dismissViewController: BehaviorSubject<UIViewController>
    let feedback: BehaviorSubject<String>
    let actionTitle: BehaviorSubject<String>
    let showSlideView: PublishSubject<Void>
    let dismissSlideView: PublishSubject<Void>
    let showConfettiView: BehaviorSubject<Bool>
    let isCorrectAnswer: BehaviorSubject<Bool>
    let hideBlockerView: BehaviorSubject<Bool>
  }
  
  var input: Input
  var output: Output
  
  private let subject: Subject
  private let disposeBag = DisposeBag()
  
  init(pageIndex: Int,
       screen: Screen) {
    self.subject = createSubject()
    self.input = createInput(subject: subject)
    self.output = createOutput(subject: subject)
    
    subject.eyebrow.onNext(screen.eyebrow ?? "")
  
    let updatedBody = screen.body?.replacingOccurrences(of: "%  RECAP  %", with: "________ -") ?? ""
    subject.body.onNext(updatedBody)
    
    subject.firstAnswer.onNext(screen.answers?[0].text ?? "")
    subject.secondAnswer.onNext(screen.answers?[1].text ?? "")
    subject.thirdAnswer.onNext(screen.answers?[2].text ?? "")
    
    subject.firstAnswerRelay.accept(screen.answers?[0] ?? Answer(id: "", text: ""))
    subject.secondAnswerRelay.accept(screen.answers?[1] ?? Answer(id: "", text: ""))
    subject.thirdAnswerRelay.accept(screen.answers?[2] ?? Answer(id: "", text: ""))
    subject.correctAnswerRelay.accept(screen.correctAnswer ?? "")
    
    subject.pageIndexRelay.accept(pageIndex)
    
    setupBindings()
  }
  
  private func setupBindings() {
    subject
      .didTapFirstAnswer
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        
        subject.hideFirstAnswer.onNext(true)
        subject.hideSecondAnswer.onNext(false)
        subject.hideThirdAnswer.onNext(false)
        subject.hideFilledAnswer.onNext(false)
        
        showSlideAction(withActionTitle: "Check")
        
        let firstAnswer = subject.firstAnswerRelay.value
        fill(answer: firstAnswer)
      })
      .disposed(by: disposeBag)
    
    subject
      .didTapSecondAnswer
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        
        subject.hideFirstAnswer.onNext(false)
        subject.hideSecondAnswer.onNext(true)
        subject.hideThirdAnswer.onNext(false)
        subject.hideFilledAnswer.onNext(false)
        
        showSlideAction(withActionTitle: "Check")
        
        let secondAnswer = subject.secondAnswerRelay.value
        fill(answer: secondAnswer)
      })
      .disposed(by: disposeBag)
    
    subject
      .didTapThirdAnswer
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        
        subject.hideFirstAnswer.onNext(false)
        subject.hideSecondAnswer.onNext(false)
        subject.hideThirdAnswer.onNext(true)
        subject.hideFilledAnswer.onNext(false)
        
        showSlideAction(withActionTitle: "Check")
        
        let thirdAnswer = subject.thirdAnswerRelay.value
        fill(answer: thirdAnswer)
      })
      .disposed(by: disposeBag)
    
    subject
      .didTapFilledAnswer
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        
        reset()
      })
      .disposed(by: disposeBag)
    
    subject
      .didTapAction
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        
        let actionTitle = subject.actionTitleRelay.value
        
        if actionTitle == "Check" {
          subject.isActionEnabled.onNext(false)
          subject.showConfettiView.onNext(true)
          
          DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            self.subject.dismissSlideView.onNext(())
            self.subject.isActionEnabled.onNext(true)
            self.subject.showConfettiView.onNext(false)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              self.showSlideAction(withActionTitle: "Continue")
            }
          }
        } else {
          let correctAnswer = subject.correctAnswerRelay.value
          let filledAnswer = subject.filledAnswerRelay.value.id
          
          if correctAnswer == filledAnswer {
            let pageIndex = subject.pageIndexRelay.value
            
            subject.showScreen.onNext(.nextScreen(pageIndex: pageIndex))
          } else {
            reset()
          }
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func showSlideAction(withActionTitle title: String) {
    let filledAnswer = subject.filledAnswerRelay.value
    
    if filledAnswer.text.isEmpty || title == "Continue" {
      let correctAnswer = subject.correctAnswerRelay.value
      let filledAnswer = subject.filledAnswerRelay.value.id
      
      subject.isCorrectAnswer.onNext(correctAnswer == filledAnswer)
      subject.hideTopBorder.onNext(title != "Continue")
      subject.hideFeedbackView.onNext(title != "Continue")
      subject.hideBlockerView.onNext(title != "Continue")
      subject.actionTitle.onNext(title)
      subject.actionTitleRelay.accept(title)
      subject.showSlideView.onNext(())
    }
  }
  
  private func fill(answer: Answer) {
    subject.filledAnswer.onNext(answer.text)
    subject.filledAnswerRelay.accept(answer)
  }
  
  private func reset() {
    subject.hideFirstAnswer.onNext(false)
    subject.hideSecondAnswer.onNext(false)
    subject.hideThirdAnswer.onNext(false)
    subject.hideFilledAnswer.onNext(true)
    subject.hideBlockerView.onNext(true)
    
    subject.filledAnswerRelay.accept(Answer(id: "", text: ""))
    subject.dismissSlideView.onNext(())
    subject.isActionEnabled.onNext(true)
  }
}

fileprivate func createSubject() -> RecapViewModel.Subject {
  return RecapViewModel.Subject(showScreen: PublishSubject<ChallengeScreenFlow?>(),
                                eyebrow: BehaviorSubject<String>(value: ""),
                                body: BehaviorSubject<String>(value: ""),
                                firstAnswer: BehaviorSubject<String>(value: ""),
                                secondAnswer: BehaviorSubject<String>(value: ""),
                                thirdAnswer: BehaviorSubject<String>(value: ""), 
                                filledAnswer: BehaviorSubject<String>(value: ""),
                                didTapFirstAnswer: PublishSubject<Void>(),
                                didTapSecondAnswer: PublishSubject<Void>(),
                                didTapThirdAnswer: PublishSubject<Void>(),
                                didTapFilledAnswer: PublishSubject<Void>(),
                                hideFirstAnswer: BehaviorSubject<Bool>(value: false),
                                hideSecondAnswer: BehaviorSubject<Bool>(value: false),
                                hideThirdAnswer: BehaviorSubject<Bool>(value: false),
                                hideFilledAnswer: BehaviorSubject<Bool>(value: true),
                                pageIndexRelay: BehaviorRelay<Int>(value: 0),
                                firstAnswerRelay: BehaviorRelay<Answer>(value: Answer(id: "", text: "")),
                                secondAnswerRelay: BehaviorRelay<Answer>(value: Answer(id: "", text: "")),
                                thirdAnswerRelay: BehaviorRelay<Answer>(value: Answer(id: "", text: "")),
                                filledAnswerRelay: BehaviorRelay<Answer>(value: Answer(id: "", text: "")), 
                                correctAnswerRelay: BehaviorRelay<String>(value: ""),
                                actionTitleRelay: BehaviorRelay<String>(value: ""),
                                didTapAction: PublishSubject<Void>(),
                                hideTopBorder: BehaviorSubject<Bool>(value: true),
                                hideFeedbackView: BehaviorSubject<Bool>(value: true),
                                isActionEnabled: BehaviorSubject<Bool>(value: true),
                                dismissViewController: BehaviorSubject<UIViewController>(value: UIViewController()),
                                feedback: BehaviorSubject<String>(value: ""),
                                actionTitle: BehaviorSubject<String>(value: ""),
                                showSlideView: PublishSubject<Void>(),
                                dismissSlideView: PublishSubject<Void>(),
                                showConfettiView: BehaviorSubject<Bool>(value: false), 
                                isCorrectAnswer: BehaviorSubject<Bool>(value: false), 
                                hideBlockerView: BehaviorSubject<Bool>(value: true))
}

fileprivate func createInput(subject: RecapViewModel.Subject) -> RecapViewModel.Input {
  return RecapViewModel.Input(didTapFirstAnswer: subject.didTapFirstAnswer.asObserver(),
                              didTapSecondAnswer: subject.didTapSecondAnswer.asObserver(),
                              didTapThirdAnswer: subject.didTapThirdAnswer.asObserver(),
                              didTapFilledAnswer: subject.didTapFilledAnswer.asObserver(),
                              didTapAction: subject.didTapAction.asObserver(),
                              isActionEnabled: subject.isActionEnabled.asObserver())
}

fileprivate func createOutput(subject: RecapViewModel.Subject) -> RecapViewModel.Output {
  return RecapViewModel.Output(showScreen: subject.showScreen.asDriver(onErrorJustReturn: nil),
                               eyebrow: subject.eyebrow.asDriver(onErrorJustReturn: ""),
                               body: subject.body.asDriver(onErrorJustReturn: ""),
                               firstAnswer: subject.firstAnswer.asDriver(onErrorJustReturn: ""),
                               secondAnswer: subject.secondAnswer.asDriver(onErrorJustReturn: ""),
                               thirdAnswer: subject.thirdAnswer.asDriver(onErrorJustReturn: ""), 
                               filledAnswer: subject.filledAnswer.asDriver(onErrorJustReturn: ""),
                               hideFirstAnswer: subject.hideFirstAnswer.asDriver(onErrorJustReturn: false),
                               hideSecondAnswer: subject.hideSecondAnswer.asDriver(onErrorJustReturn: false),
                               hideThirdAnswer: subject.hideThirdAnswer.asDriver(onErrorJustReturn: false),
                               hideFilledAnswer: subject.hideFilledAnswer.asDriver(onErrorJustReturn: true),
                               hideTopBorder: subject.hideTopBorder.asDriver(onErrorJustReturn: true),
                               hideFeedbackView: subject.hideFeedbackView.asDriver(onErrorJustReturn: true),
                               isActionEnabled: subject.isActionEnabled.asDriver(onErrorJustReturn: true),
                               feedback: subject.feedback.asDriver(onErrorJustReturn: ""),
                               actionTitle: subject.actionTitle.asDriver(onErrorJustReturn: ""),
                               showSlideView: subject.showSlideView.asDriver(onErrorJustReturn: ()),
                               dismissSlideView: subject.dismissSlideView.asDriver(onErrorJustReturn: ()), 
                               showConfettiView: subject.showConfettiView.asDriver(onErrorJustReturn: false), 
                               isCorrectAnswer: subject.isCorrectAnswer.asDriver(onErrorJustReturn: false),
                               hideBlockerView: subject.hideBlockerView.asDriver(onErrorJustReturn: true))
}
