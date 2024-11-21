import Foundation
import RxSwift
import RxCocoa

class MultipleChoiceViewModel: ChallengeBaseViewModelType {
  struct Input {
    let didSelectItem: AnyObserver<MultipleChoiceSectionItemModel>
  }
  
  struct Output {
    let showScreen: Driver<ChallengeScreenFlow?>
    let question: Driver<String>
    let hideSelectMessage: Driver<Bool>
    let sectionModels: Driver<[MultipleChoiceSectionModel]>
  }
  
  fileprivate struct Subject {
    let showScreen: PublishSubject<ChallengeScreenFlow?>
    let question: BehaviorSubject<String>
    let hideSelectMessage: BehaviorSubject<Bool>
    let sectionModels: BehaviorSubject<[MultipleChoiceSectionModel]>
    let didSelectItem: PublishSubject<MultipleChoiceSectionItemModel>
    let pageIndexRelay: BehaviorRelay<Int>
    let choicesRelay: BehaviorRelay<[Choice]>
    let multipleAllowedRelay: BehaviorRelay<Bool>
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
    
    subject.pageIndexRelay.accept(pageIndex)
    subject.question.onNext(screen.question ?? "")
    subject.hideSelectMessage.onNext(!(screen.multipleChoicesAllowed ?? false))
    subject.multipleAllowedRelay.accept(screen.multipleChoicesAllowed ?? false)
    
    updateSectionModel(choices: screen.choices ?? [])
    setupBindings()
  }
  
  private func setupBindings() {
    subject
      .didSelectItem
      .bind(onNext: { [weak self] selectedItem in
        guard let self = self else { return }
        let pageIndex = subject.pageIndexRelay.value
        
        switch selectedItem {
          case let .choice(viewModel):
            let choices = subject.choicesRelay.value
            let multipleAllowed = subject.multipleAllowedRelay.value
            let isSelectedItem = choices.first(where: { $0.id == viewModel.idRelay.value })
            
            if multipleAllowed {
              if isSelectedItem?.isSelected == true {
                isSelectedItem?.isSelected?.toggle()
              } else {
                isSelectedItem?.isSelected = true
              }
            } else {
              let isOtherSelectedItem = choices.first(where: { $0.isSelected == true })
              isOtherSelectedItem?.isSelected = false
              
              isSelectedItem?.isSelected = true
            }
            
            updateSectionModel(choices: choices)
            
            if !multipleAllowed {
              subject.showScreen.onNext(.nextScreen(pageIndex: pageIndex))
            }
          case let .continueButton(viewModel):
            let isEnabled = viewModel.isEnabledRelay.value
            
            if isEnabled {
              subject.showScreen.onNext(.nextScreen(pageIndex: pageIndex))
            }
          default:
            break
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func updateSectionModel(choices: [Choice]) {
    let multipleAllowed = subject.multipleAllowedRelay.value
    var sectionItemModel = [MultipleChoiceSectionItemModel]()
    var selectedChoicesCount = 0
    
    subject.choicesRelay.accept(choices)
    
    choices.forEach {
      let model = ChoiceCellModel(id: $0.id,
                                  text: $0.text,
                                  emoji: $0.emoji,
                                  isSelected: $0.isSelected ?? false)
      
      if model.isSelected == true {
        selectedChoicesCount += 1
      }
      
      let choiceViewModel = ChoiceTableViewModel(model: model)
      sectionItemModel.append(.choice(viewModel: choiceViewModel))
      let separatorViewModel = SeparatorTableViewModel()
      sectionItemModel.append(.separator(viewModel: separatorViewModel))
    }
    
    if multipleAllowed {
      let model = ContinueCellModel(isEnabled: selectedChoicesCount > 0)
      let continueViewModel = ContinueTableViewModel(model: model)
      sectionItemModel.append(.continueButton(viewModel: continueViewModel))
    }
    
    subject.sectionModels.onNext([MultipleChoiceSectionModel(items: sectionItemModel)])
  }
}

fileprivate func createSubject() -> MultipleChoiceViewModel.Subject {
  return MultipleChoiceViewModel.Subject(showScreen: PublishSubject<ChallengeScreenFlow?>(), 
                                         question: BehaviorSubject<String>(value: ""),
                                         hideSelectMessage: BehaviorSubject<Bool>(value: false),
                                         sectionModels: BehaviorSubject<[MultipleChoiceSectionModel]>(value: []),
                                         didSelectItem: PublishSubject<MultipleChoiceSectionItemModel>(), 
                                         pageIndexRelay: BehaviorRelay<Int>(value: 0),
                                         choicesRelay: BehaviorRelay<[Choice]>(value: []),
                                         multipleAllowedRelay: BehaviorRelay<Bool>(value: false))
}

fileprivate func createInput(subject: MultipleChoiceViewModel.Subject) -> MultipleChoiceViewModel.Input {
  return MultipleChoiceViewModel.Input(didSelectItem: subject.didSelectItem.asObserver())
}

fileprivate func createOutput(subject: MultipleChoiceViewModel.Subject) -> MultipleChoiceViewModel.Output {
  return MultipleChoiceViewModel.Output(showScreen: subject.showScreen.asDriver(onErrorJustReturn: nil), 
                                        question: subject.question.asDriver(onErrorJustReturn: ""),
                                        hideSelectMessage: subject.hideSelectMessage.asDriver(onErrorJustReturn: false),
                                        sectionModels: subject.sectionModels.asDriver(onErrorJustReturn: []))
}
