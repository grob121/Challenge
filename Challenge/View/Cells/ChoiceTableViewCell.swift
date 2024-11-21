import RxSwift
import RxCocoa
import UIColor_Hex_Swift

class ChoiceTableViewCell: UITableViewCell,
                           BindableType,
                           MultipleChoiceBindableType {
  @IBOutlet private weak var emojiLabel: UILabel!
  @IBOutlet private weak var choiceLabel: UILabel!
  
  var viewModel: ChoiceTableViewModelType!
  
  private let disposeBag = DisposeBag()
  
  func bindViewModel() {
    viewModel
      .text
      .bind(to: choiceLabel.rx.text)
      .disposed(by: disposeBag)
    
    viewModel
      .emoji
      .bind(to: emojiLabel.rx.text)
      .disposed(by: disposeBag)
    
    viewModel
      .isSelected
      .bind(onNext: { [weak self] isSelected in
        guard let self = self else { return }
        
        contentView.layer.borderWidth = isSelected ? 2.0 : 1.0
        contentView.layer.cornerRadius = 12.0
        contentView.clipsToBounds = clipsToBounds
        contentView.layer.borderColor = isSelected ? UIColor("#6442EF").cgColor : UIColor.black.withAlphaComponent(0.12).cgColor
      })
      .disposed(by: disposeBag)
  }
}
