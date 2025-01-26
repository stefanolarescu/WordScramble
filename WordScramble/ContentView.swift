//
//  ContentView.swift
//  WordScramble
//
//  Created by Stefan Olarescu on 26.01.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = String.empty
    @State private var newWord = String.empty
    
    @State private var score = Int.zero
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField(
                        "Enter your word",
                        text: $newWord
                    )
                    .textInputAutocapitalization(.never)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
                
                Section("Score") {
                    Text("\(score)")
                }
            }
            .onAppear(perform: startGame)
            .navigationTitle(rootWord)
            .toolbar {
                Button(
                    "Reset",
                    action: startGame
                )
            }
            .onSubmit(addNewWord)
            .alert(
                errorTitle,
                isPresented: $showingError,
                actions: {},
                message: {
                    Text(errorMessage)
                }
            )
        }
    }
    
    private func startGame() {
        guard let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") else {
            fatalError("Could not load start.exe from bundle.")
        }
        
        if let startWords = try? String(contentsOf: startWordsURL, encoding: .utf8) {
            let allWords = startWords.components(separatedBy: .newlines)
            
            rootWord = allWords.randomElement() ?? "silkworm"
            
            usedWords.removeAll()
            
            score = .zero
        }
    }
    
    private func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    private func isPossible(word: String) -> Bool {
        var rootWord = rootWord
        
        for letter in word {
            if let positionOfLetter = rootWord.firstIndex(of: letter) {
                rootWord.remove(at: positionOfLetter)
            } else {
                return false
            }
        }
        
        return true
    }
    
    private func isReal(word: String) -> Bool {
        let textChecker = UITextChecker()
        let range = NSRange(location: .zero, length: word.utf16.count)
        let rangeOfMisspelledWord = textChecker.rangeOfMisspelledWord(
            in: word,
            range: range,
            startingAt: .zero,
            wrap: false,
            language: "en"
        )
        
        return rangeOfMisspelledWord.location == NSNotFound
    }
    
    private func isNotTooEasy(word: String) -> Bool {
        word.count > 3 && word != rootWord
    }
    
    private func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    private func addNewWord() {
        let answer = newWord
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > .zero else { return }
        
        guard isOriginal(word: answer) else {
            wordError(
                title: "Word used already!",
                message: "Be more original."
            )
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(
                title: "Word not possible!",
                message: "You can't spell that word from '\(rootWord)'!"
            )
            return
        }
        
        guard isReal(word: answer) else {
            wordError(
                title: "Word not recognized!",
                message: "You can't just make them up, you know!"
            )
            return
        }
        
        guard isNotTooEasy(word: answer) else {
            wordError(
                title: "Word too easy!",
                message: "Words should be longer than 3 characters and not the starting word."
            )
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: .zero)
        }
        
        score += 1
        score += answer.count
        
        newWord.clear()
    }
}

#Preview {
    ContentView()
}
