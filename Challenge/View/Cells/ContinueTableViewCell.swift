import RxSwift
import RxCocoa

class ContinueTableViewCell: UITableViewCell,
                             BindableType,
                             MultipleChoiceBindableType {
  var viewModel: ContinueTableViewModelType!
  
  private let disposeBag = DisposeBag()
  
  func bindViewModel() {
    viewModel
      .isEnabled
      .bind(onNext: { [weak self] isEnabled in
        guard let self = self else { return }

        self.contentView.layer.cornerRadius = 12.0
        self.contentView.backgroundColor = UIColor(isEnabled ? "#6442EF" : "#DDD5FB")
      })
      .disposed(by: disposeBag)
  }
}
