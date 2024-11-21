import RxSwift
import RxCocoa

protocol ChoiceTableViewModelType {
  init(model: ChoiceCellModel)
  
  var id: Observable<String> { get }
  var text: Observable<String> { get }
  var emoji: Observable<String> { get }
  var isSelected: Observable<Bool> { get }

  var idRelay: BehaviorRelay<String> { get set }
  var textRelay: BehaviorRelay<String> { get set }
  var emojiRelay: BehaviorRelay<String> { get set }
  var isSelectedRelay: BehaviorRelay<Bool> { get set }
}

class ChoiceTableViewModel: ChoiceTableViewModelType {
  var id: Observable<String> { idRelay.asObservable() }
  var text: Observable<String> { textRelay.asObservable() }
  var emoji: Observable<String> { emojiRelay.asObservable() }
  var isSelected: Observable<Bool> { isSelectedRelay.asObservable() }
  
  var idRelay = BehaviorRelay<String>(value: "")
  var textRelay = BehaviorRelay<String>(value: "")
  var emojiRelay = BehaviorRelay<String>(value: "")
  var isSelectedRelay = BehaviorRelay<Bool>(value: false)
  
  private var model: ChoiceCellModel
  
  required init(model: ChoiceCellModel) {
    self.model = model
    
    idRelay.accept(model.id)
    textRelay.accept(model.text)
    emojiRelay.accept(model.emoji)
    isSelectedRelay.accept(model.isSelected)
  }
}
