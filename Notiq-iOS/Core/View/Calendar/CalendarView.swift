import SwiftUI

struct CalendarView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.blue)
            
            Text("Calendar")
                .font(.largeTitle)
                .bold()
            
            Text("This feature is coming soon!\nWork in progress...")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .navigationTitle("Calendar")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
