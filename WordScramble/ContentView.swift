//
//  ContentView.swift
//  WordScramble
//
//  Created by Jacob on 10/19/20.
//  Copyright © 2020 Jacob. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var gameScore = 0
    
    //error alert properties
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        

        
        NavigationView {
            
            VStack {
                
                TextField("Please enter a selected word:", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
                
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                
            }
            .onAppear(perform: startGame)
            .navigationBarTitle(Text(rootWord), displayMode: .inline)
            .navigationBarItems(leading: (usedWords.isEmpty ? Button("New Game") { self.startGame() } : Button("New Word") { self.startGame() }),
                                trailing: Text("Score: \(gameScore)"))
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle),
                      message: Text(errorMessage),
                      dismissButton: .default(Text("Continue")))
            }
        }
        .padding()
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord.lowercased()
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        
        //any word entered must be >= 3
        if range.upperBound < 3 {
            return false
        }
        
        let misspelledRange = checker.rangeOfMisspelledWord(in: word,
                                                            range: range,
                                                            startingAt: 0,
                                                            wrap: false,
                                                            language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func addNewWord() {
        //lowercasing and trimming whitespace/new lines
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        //game mechanics
        guard answer != rootWord else {
            wordError(title: "Root word is not allowed.", message: "Use a unique word!")
            gameScore -= 2
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word was already used.", message: "Be more original!")
            gameScore -= 2
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word is not recognized.", message: "Use a valid word!")
            gameScore -= 2
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word is not possible.", message: "Use a real word!")
            gameScore -= 2
            return
        }
        
        gameScore += answer.count
        //add to newWords array, erase value of newWord
        usedWords.insert(answer, at: 0)
        newWord = ""    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func startGame() {
        //get start.txt URL from app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            //load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                //split string into array of strings, then pick a random word to start with
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                //if startGame is used with no found words, game score is reset.
                if usedWords.isEmpty {
                    gameScore = 0
                }
                usedWords.removeAll()
                return
            }
        }
        //this is only reached if there was an issue running code above
        fatalError("Could not load start.txt file from app bundle!")
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
