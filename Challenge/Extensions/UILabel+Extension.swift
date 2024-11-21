import UIKit

extension UILabel {
  func boundingRect(forCharacterRange range: NSRange) -> CGRect? {
    guard let attributedText = attributedText else { return nil }
    
    let textStorage = NSTextStorage(attributedString: attributedText)
    let layoutManager = NSLayoutManager()
    let textContainer = NSTextContainer(size: bounds.size)
    var glyphRange = NSRange()
    
    textStorage.addLayoutManager(layoutManager)
    textContainer.lineFragmentPadding = 0.0
    
    layoutManager.addTextContainer(textContainer)
    layoutManager.characterRange(forGlyphRange: range, actualGlyphRange: &glyphRange)
    
    return layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
  }
}
