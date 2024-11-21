import RxSwift
import RxCocoa

protocol ContinueTableViewModelType {
  init(model: ContinueCellModel)
  
  var isEnabled: Observable<Bool> { get }
  
  var isEnabledRelay: BehaviorRelay<Bool> { get set }
}

class ContinueTableViewModel: ContinueTableViewModelType {
  var isEnabled: Observable<Bool> { isEnabledRelay.asObservable() }
  
  var isEnabledRelay = BehaviorRelay<Bool>(value: false)
  
  private var model: ContinueCellModel
  
  required init(model: ContinueCellModel) {
    self.model = model
    
    isEnabledRelay.accept(model.isEnabled)
  }
}

