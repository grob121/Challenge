import Foundation
import RxSwift
import RxCocoa

class ChallengeContainerViewModel: ChallengeBaseViewModelType {
  struct Input {
    let didTapBack: AnyObserver<Void>
    let didTapClose: AnyObserver<Void>
    let viewWillAppear: AnyObserver<Bool>
  }
  
  struct Output {
    let showScreen: Driver<ChallengeScreenFlow?>
    let progress: Driver<Float>
    let shouldHideBack: Driver<Bool>
    let shouldHideClose: Driver<Bool>
  }
  
  fileprivate struct Subject {
    let didTapBack: PublishSubject<Void>
    let didTapClose: PublishSubject<Void>
    let showScreen: PublishSubject<ChallengeScreenFlow?>
    let progress: BehaviorSubject<Float>
    let shouldHideBack: BehaviorSubject<Bool>
    let shouldHideClose: BehaviorSubject<Bool>
    let viewWillAppear: PublishSubject<Bool>
    let pageIndexRelay: BehaviorRelay<Int>
    let screensRelay: BehaviorRelay<[Screen]>
  }
  
  var input: Input
  var output: Output
  
  private var challengeAdapter: ChallengeAdapter!
  private let subject: Subject
  private let disposeBag = DisposeBag()
  
  init() {
    self.subject = createSubject()
    self.input = createInput(subject: subject)
    self.output = createOutput(subject: subject)
    
    setupBindings()
  }
  
  private func setupBindings() {
    subject
      .viewWillAppear
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        
        self.loadChallengeActivity()
      })
      .disposed(by: disposeBag)
    
    subject
      .didTapBack
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        
        let pageIndex = subject.pageIndexRelay.value
        let screens = subject.screensRelay.value
        
        subject.showScreen.onNext(.previousScreen(pageIndex: pageIndex))
        subject.shouldHideBack.onNext(pageIndex == screens.count - 1)
        subject.shouldHideClose.onNext(pageIndex == screens.count - 1)
        subject.pageIndexRelay.accept(pageIndex + 1)
        subject.progress.onNext(Float(screens.count - pageIndex - 1)/Float(screens.count))
      })
      .disposed(by: disposeBag)
    
    subject
      .didTapClose
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        
        let pageIndex = subject.pageIndexRelay.value
        let screens = subject.screensRelay.value
        
        subject.pageIndexRelay.accept(pageIndex)
        
        for index in pageIndex..<screens.count {
          subject.showScreen.onNext(.previousScreen(pageIndex: index))
          subject.shouldHideBack.onNext(true)
          subject.shouldHideClose.onNext(true)
          subject.progress.onNext(Float(0.0)/Float(screens.count))
        }
      })
      .disposed(by: disposeBag)
  }
  
  func loadChallengeActivity() {
    challengeAdapter = ChallengeAdapter()
    
    self.challengeAdapter
      .getActivity()
      .subscribe(onNext: { [weak self] result in
        guard let self = self else { return }
        
        switch result {
          case .success(let response):
            let screens = response.activity.screens
            let reversedScreens = screens.reversed()
            subject.screensRelay.accept(screens.reversed())
            
            for (index, screen) in reversedScreens.enumerated() {
              if index == reversedScreens.count - 1 {
                subject.pageIndexRelay.accept(index)
              }
              
              if screen.type == "recapModuleScreen" {
                let recapViewModel = RecapViewModel(pageIndex: index,
                                                    screen: screen)
                
                recapViewModel
                  .output
                  .showScreen
                  .drive(onNext: { [weak self] screen in
                    guard let self = self else { return }
                    
                    subject.shouldHideBack.onNext(index == reversedScreens.count)
                    subject.shouldHideClose.onNext(index == reversedScreens.count)
                    if index != 0 {
                      subject.showScreen.onNext(.nextScreen(pageIndex: index))
                    }
                    subject.pageIndexRelay.accept(index)
                  })
                  .disposed(by: disposeBag)

                subject.showScreen.onNext(.recap(viewModel: recapViewModel))
              } else if screen.type == "multipleChoiceModuleScreen" {
                let multipleChoiceViewModel = MultipleChoiceViewModel(pageIndex: index,
                                                                      screen: screen)
                
                multipleChoiceViewModel
                  .output
                  .showScreen
                  .drive(onNext: { [weak self] screen in
                    guard let self = self else { return }
                    
                    subject.shouldHideBack.onNext(index == reversedScreens.count)
                    subject.shouldHideClose.onNext(index == reversedScreens.count)
                    if index != 0 {
                      subject.showScreen.onNext(.nextScreen(pageIndex: index))
                    }
                    subject.pageIndexRelay.accept(index)
                    subject.progress.onNext(Float(reversedScreens.count - index)/Float(reversedScreens.count))
                  })
                  .disposed(by: disposeBag)
                
                subject.showScreen.onNext(.multipleChoice(viewModel: multipleChoiceViewModel))
              }
            }
            
            let pageIndex = subject.pageIndexRelay.value
            
            subject.shouldHideBack.onNext(pageIndex == reversedScreens.count - 1)
            subject.shouldHideClose.onNext(pageIndex == reversedScreens.count - 1)
            subject.pageIndexRelay.accept(pageIndex)
            subject.progress.onNext(Float(reversedScreens.count - pageIndex - 1)/Float(reversedScreens.count))
          default:
            break
        }
      }, onError: { error in
        print(error)
      })
      .disposed(by: self.disposeBag)
  }
}

fileprivate func createSubject() -> ChallengeContainerViewModel.Subject {
  return ChallengeContainerViewModel.Subject(didTapBack: PublishSubject<Void>(),
                                             didTapClose: PublishSubject<Void>(),
                                             showScreen: PublishSubject<ChallengeScreenFlow?>(), 
                                             progress: BehaviorSubject<Float>(value: 0.0),
                                             shouldHideBack: BehaviorSubject<Bool>(value: true),
                                             shouldHideClose: BehaviorSubject<Bool>(value: true),
                                             viewWillAppear: PublishSubject<Bool>(),
                                             pageIndexRelay: BehaviorRelay<Int>(value: 0),
                                             screensRelay: BehaviorRelay<[Screen]>(value: []))
}

fileprivate func createInput(subject: ChallengeContainerViewModel.Subject) -> ChallengeContainerViewModel.Input {
  return ChallengeContainerViewModel.Input(didTapBack: subject.didTapBack.asObserver(),
                                           didTapClose: subject.didTapClose.asObserver(),
                                           viewWillAppear: subject.viewWillAppear.asObserver())
}

fileprivate func createOutput(subject: ChallengeContainerViewModel.Subject) -> ChallengeContainerViewModel.Output {
  return ChallengeContainerViewModel.Output(showScreen: subject.showScreen.asDriver(onErrorJustReturn: nil), 
                                            progress: subject.progress.asDriver(onErrorJustReturn: 0.0),
                                            shouldHideBack: subject.shouldHideBack.asDriver(onErrorJustReturn: true),
                                            shouldHideClose: subject.shouldHideClose.asDriver(onErrorJustReturn: true))
}
