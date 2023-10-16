//
//  ContentView.swift
//  uppgift4
//
//  Created by Anton Smedberg on 2023-10-16.
//

import SwiftUI

struct ContentView: View {
    @State private var classificationResult: String = ""
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false

    private let imageModel = ImageModel()

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Spacer()
                ClassifyImageView(imageName: "gorillaios", onClassify: classifyImage)
                ClassifyImageView(imageName: "flamingoios", onClassify: classifyImage)
                Spacer()

                if isLoading {
                    ProgressView("Klassificerar...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5, anchor: .center)
                } else {
                    Text(classificationResult)
                        .font(.largeTitle)
                        .padding(.all, 10)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                }

                if showError {
                    Text("Ett fel inträffade vid klassificeringen.")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding()
        }
    }

    func classifyImage(for imageName: String) {
        isLoading = true
        showError = false

        do {
            classificationResult = try imageModel.classifyImage(named: imageName)
        } catch {
            showError = true
            classificationResult = ""
        }

        isLoading = false
    }
}

struct ClassifyImageView: View {
    let imageName: String
    let onClassify: (String) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 10)
                .padding()

            Button(action: {
                withAnimation {
                    onClassify(imageName)
                }
            }) {
                Text("Vilket djur?")
                    .fontWeight(.bold)
                    .padding(.all, 10)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 10)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

