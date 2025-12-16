import SwiftUI
import Realm
import Combine

struct UserProfileView: View {
    @EnvironmentObject var network: NetworkManager
    @Environment(\.presentationMode) var presentationMode
    
    // Editable State
    @State private var email: String = "royal.player@example.com"
    @State private var phone: String = "+1 (555) 123-4567"
    @State private var isEditing = false
    
    // Alerts
    @State private var showSaveAlert = false
    @State private var showPasswordAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundLight.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // 1. Profile Header
                        VStack(spacing: 15) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.blue)
                                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            VStack(spacing: 5) {
                                Text(network.currentUser?.first_name ?? "Royal Player")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("Royal Member")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(LinearGradient.royalLiquid.opacity(0.8))
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.top, 30)
                        
                        // 2. Personal Information
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Personal Information")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 15) {
                                ProfileField(icon: "envelope.fill", title: "Email", text: .constant(network.currentUser?.email ?? ""))
                                ProfileField(icon: "phone.fill", title: "Phone", text: .constant(network.currentUser?.phone_number ?? ""))
                            }
                            
                            Button(action: {
                                showPasswordAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "lock.fill")
                                    Text("Change Password")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                }
                                .foregroundColor(.primary)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        
                        // 3. Legal
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Legal & Support")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 15) {
                                LinkButton(title: "Privacy Policy", url: "https://www.royalbadmintonclub.com/privacy-policy")
                                LinkButton(title: "Terms & Conditions", url: "https://www.royalbadmintonclub.com/terms-condition")
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 20)
                        
                            // 4. Logout
                        Button(action: {
                            Task {
                                network.logout()
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            Text("Log Out")
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 50)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                    }
                }
            }
            .alert(isPresented: $showPasswordAlert) {
                Alert(title: Text("Change Password"), message: Text("A password reset link has been sent to your email."), dismissButton: .default(Text("OK")))
            }
        }
        .onAppear {
            network.getProfile()
                .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                .store(in: &cancellables)
        }
    }
    
    @State private var cancellables = Set<AnyCancellable>()
}

// MARK: - Components

struct ProfileField: View {
    let icon: String
    let title: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField(title, text: $text)
                    .font(.body)
            }
            
            Spacer()
            
            Image(systemName: "pencil")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct LinkButton: View {
    let title: String
    let url: String
    
    var body: some View {
        Link(destination: URL(string: url)!) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        }
    }
}
