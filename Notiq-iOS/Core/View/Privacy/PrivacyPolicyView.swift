import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Privacy Icon
                HStack {
                    Spacer()
                    Image(systemName: "person.3.fill") // Your privacy logo asset
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.accentColor)
                    Spacer()
                }
                .padding(.top, 20)
                
                // App Name & Intro Text
                Text("Notiq cares about your privacy. Your data stays secure and private within the app.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Divider()
                
                // Policy Sections
                Group {
                    Text("1. Introduction")
                        .font(.title3.bold())
                    Text("""
Notiq (“we”, “our”, or “us”) values your privacy. This Privacy Policy explains how we collect, use, and protect your information when you use Notiq.
""")
                    
                    Text("2. Information We Collect")
                        .font(.title3.bold())
                    Text("""
We may collect:
- Device information for analytics
- Optional info you provide (like email)
""")
                    
                    Text("3. How We Use Your Information")
                        .font(.title3.bold())
                    Text("""
Your data is used to:
- Improve the app experience
- Fix bugs and issues
- Analyze trends
""")
                    
                    Text("4. Data Sharing")
                        .font(.title3.bold())
                    Text("""
We do not sell your data. We may share info with third-party services for analytics or cloud sync, with your consent.
""")
                    
                    Text("5. Security")
                        .font(.title3.bold())
                    Text("""
We use reasonable security measures, but no transmission over the Internet is 100% secure.
""")
                    
                    Text("6. Contact Us")
                        .font(.title3.bold())
                    Text("""
Questions? Reach out at support@notiqapp.com
""")
                }
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
        }
        .navigationTitle("Privacy Policy")
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PrivacyPolicyView()
        }
    }
}
