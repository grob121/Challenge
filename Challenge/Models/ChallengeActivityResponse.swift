import Foundation

struct ChallengeActivityResponse: Codable {
  var id: String
  var state: String
  var stateChangedAt: String?
  var title: String
  var description: String
  var duration: String
  var activity: Activity
}

struct Activity: Codable {
  var screens: [Screen]
}

struct Screen: Codable {  
  var id: String
  var type: String
  var question: String?
  var multipleChoicesAllowed: Bool?
  var choices: [Choice]?
  var eyebrow: String?
  var body: String?
  var answers: [Answer]?
  var correctAnswer: String?
}

class Choice: Codable {
  var id: String
  var text: String
  var emoji: String
  var isSelected: Bool?
}

struct Answer: Codable {
  var id: String
  var text: String
}

struct ChallengeActivityErrorResponse: Error, Codable {
  var version: String?
}
