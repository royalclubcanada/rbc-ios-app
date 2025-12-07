import SwiftUI
import Combine

struct LoginView: View {
    @StateObject private var network = NetworkManager.shared
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        ZStack {
            // Background
            Color.backgroundLight.ignoresSafeArea()
            
            // Liquid Orbs
            Circle()
                .fill(LinearGradient.royalLiquid)
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: -100, y: -200)
            
            Circle()
                .fill(Color.purple.opacity(0.4))
                .frame(width: 250, height: 250)
                .blur(radius: 50)
                .offset(x: 120, y: 150)
            
            VStack(spacing: 30) {
                // Header
                Text("Royal Badminton")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Sign in to book your court")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Form Card
                VStack(spacing: 20) {
                    CustomTextField(icon: "envelope.fill", placeholder: "Email", text: $email)
                    CustomTextField(icon: "lock.fill", placeholder: "Password", text: $password, isSecure: true)
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 5)
                            .transition(.opacity)
                    }
                    
                    Button(action: handleLogin) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign In")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient.royalLiquid)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: .royalGradientStart.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .buttonStyle(BouncyButton())
                    .disabled(isLoading)
                }
                .padding(30)
                .liquidGlass() // Our custom modifier
                .padding(.horizontal)
            }
        }
    }
    
    func handleLogin() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Simulating login bypass for demo purposes
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false
            NetworkManager.shared.authToken = "demo_bypass_token_123"
        }
        
        /* 
        // Real API Call (Commented out for Demo)
        network.login(email: email, password: password)
            .sink(receiveCompletion: { completion in
                isLoading = false
                switch completion {
                case .failure(let error):
                    errorMessage = error.localizedDescription
                case .finished:
                    break
                }
            }, receiveValue: { _ in
                // Success is handled by NetworkManager isAuthenticated publisher
            })
            .store(in: &cancellables)
        */
    }
}

// Helper Component
struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .font(.system(size: 18))
            
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                .keyboardType(icon == "envelope.fill" ? .emailAddress : .default)
                .autocapitalization(.none)
            }
        }
        .padding()
        .background(Color.white.opacity(0.5))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white, lineWidth: 1)
        )
    }
}

#Preview {
    LoginView()
}
