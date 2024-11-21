import Foundation

protocol ChallengeBaseViewModelType {
  associatedtype Input
  associatedtype Output
  
  var input: Input { get }
  var output: Output { get }
}
