//
//  QuizViewModel.swift
//  QuizAppSwiftUI
//
//  Created by Rafet Can AKAY on 11.02.2025.
//

import Foundation
class QuizViewModel: ObservableObject {
    @Published private(set) var currentQuestionIndex = 0
    @Published private(set) var score = 0
    @Published private(set) var isGameOver = false
    @Published private(set) var questions: [Question] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var timeRemaining = 20
    private var timer: Timer?

    
    @Published var selectedCategory : String?
    @Published var selectedLevel : String?
    
    @Published var randomQuestionsReceived = false
    
    // Load AI API key
       private let aiKey = Bundle.main.infoDictionary?["AI_API_KEY"] as? String ?? ""
      
    init() {
        
    }
   
    func fetchQuestions(random : Bool) {
        //from api generate random easy question
        if random == true {
            selectedCategory = nil
            selectedLevel = nil
            
            getQuestionFromOpenTdb()
        }else {
            randomQuestionsReceived = false
            
            fetchAIQuestions()
        }
        
    }
    
    //ai ask to handle quiz generation
    func fetchAIQuestions() {
            isLoading = true
            errorMessage = nil
            
        if (selectedCategory == nil ||
            selectedLevel == nil){
            self.errorMessage = "Please select Category and History"
            
        }else {
            self.errorMessage = nil
            let prompt = prepareAIPrompt()  // Prepare the AI prompt to fetch quiz questions
            print("prompt \(prompt)")
            sendToAIModel(prompt: prompt)  // Send the request to the AI
        }
    }
    
    private func prepareAIPrompt() -> String {
            
            let category = selectedCategory
            let difficulty = selectedLevel
            
            // Create a prompt for the AI to generate quiz questions with multiple choice answers
            return """
            Generate 3 multiple choice questions related to general knowledge.
            Each question should have 4 possible answers.
            Questions difficulty should be \(category ?? "Mathematics").
            Questions catefory should be \(difficulty ?? "Easy").
            Provide the correct answer and list the incorrect answers.
            Only send these not anything else your reply should be in json format. Like this:
            [
                {
                    "question": "Who wrote the novel 'Pride and Prejudice'?",
                    "answers": ["Charles Dickens", "Jane Austen", "Mark Twain", "George Orwell"],
                    "correctAnswerIndex": 1
                },
                {
                    "question": "What is the capital city of Australia?",
                    "answers": ["Sydney", "Melbourne", "Canberra", "Brisbane"],
                    "correctAnswerIndex": 2
                }
            ]

            """
    }
    
    private func sendToAIModel(prompt: String) {
            print("AI Test sending to AI model for questions")

            let url = URL(string: "https://api.deepinfra.com/v1/openai/chat/completions")!
            let deepInfraKey = aiKey

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Bearer \(deepInfraKey)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let parameters: [String: Any] = [
                "model": "mistralai/Mistral-7B-Instruct-v0.1",
                "messages": [["role": "user", "content": prompt]],
                "temperature": 0.7,
                "response_format": ["type": "json_object"] // Response format as JSON object
            ]
            
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
                self.errorMessage = "Failed to prepare request"
                return
            }
            
            request.httpBody = httpBody
            
            URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        print("errorMessage \(error)")
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    
                    guard let data = data else {
                        self?.errorMessage = "No data received"
                        return
                    }
                    
                    do {
                        let response = try JSONDecoder().decode(AIResponse.self, from: data)
                        
                        // Assuming 'parseAIResponse' returns an optional array of 'Question'
                        
                        if let parsedQuestions = self?.parseAIResponse(response) {
                            
                            print("parsedQuestions \(parsedQuestions)")
                            self?.questions = parsedQuestions
                        } else {
                            // Handle the error if parsing failed (e.g., set an error message)
                            self?.errorMessage = "Failed to parse AI response into questions."
                        }

                    } catch {
                        self?.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                    }
                }
            }.resume()
        }
        
        private func parseAIResponse(_ response: AIResponse) -> [Question] {
         
            
            guard let content = response.choices.first?.message.content else { return [] }
            
            print("content \(content)")
            
            
            // Convert the cleaned JSON string to a Data object
            if let jsonData = content.data(using: .utf8) {
                do {
                    let aiQuestions = try JSONDecoder().decode([AIQuestion].self, from: jsonData)
                    
                    return aiQuestions.map { aiQuestion in
                        // Convert AI-generated question to your model
                        return Question(
                            text: aiQuestion.question,
                            answers: aiQuestion.answers,
                            correctAnswerIndex: aiQuestion.correctAnswerIndex
                        )
                    }
                } catch {
                    self.errorMessage = "Failed to parse AI response"
                    return []
                }
            }
            
            return []
        }
        
    //ai ask to handle quiz generation
    
    
    
    func getQuestionFromOpenTdb() {
        isLoading = true
        errorMessage = nil
        
        let urlString = "https://opentdb.com/api.php?amount=3&difficulty=easy&type=multiple"
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(QuizApiResponse.self, from: data)
                    
                    if response.results.count > 0 {
                        self!.randomQuestionsReceived = true
                    }
                    
                    // Convert API questions to our Question model
                    self?.questions = response.results.map { apiQuestion in
                        // Combine correct and incorrect answers and shuffle them
                        var answers = apiQuestion.incorrectAnswers
                        answers.append(apiQuestion.correctAnswer)
                        answers.shuffle()
                        
                        // Find the index of the correct answer in the shuffled array
                        let correctIndex = answers.firstIndex(of: apiQuestion.correctAnswer) ?? 0
                        
                        // Create our Question model
                        return Question(
                            text: apiQuestion.question.htmlDecoded(),
                            answers: answers.map { $0.htmlDecoded() },
                            correctAnswerIndex: correctIndex
                        )
                    }
                } catch {
                    self?.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    var currentQuestion: Question {
        questions[currentQuestionIndex]
    }
    
    func answerSelected(_ answerIndex: Int) {
        // Update the current question's selected answer
        questions[currentQuestionIndex].selectedAnswerIndex = answerIndex
        
        if answerIndex == currentQuestion.correctAnswerIndex {
            score += 1
        }
        
        // Wait 2 seconds before proceeding to next question
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.currentQuestionIndex + 1 < self.questions.count {
                self.currentQuestionIndex += 1
            } else {
                self.isGameOver = true
            }
        }
    }
    
    func resetQuiz() {
        errorMessage = nil
        currentQuestionIndex = 0
        score = 0
        isGameOver = false
        
        // Reset selections so the QuizSetupView is shown again
        selectedCategory = nil
        selectedLevel = nil
        randomQuestionsReceived = false
        
    }
    
    
    func timeUp() {
        
        // Mark the question as incorrect
        if questions[currentQuestionIndex].selectedAnswerIndex == nil {
            questions[currentQuestionIndex].selectedAnswerIndex = -1 // -1 to indicate timeout
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.currentQuestionIndex + 1 < self.questions.count {
                self.currentQuestionIndex += 1
            } else {
                self.isGameOver = true
            }
        }
    }

    
}

 
