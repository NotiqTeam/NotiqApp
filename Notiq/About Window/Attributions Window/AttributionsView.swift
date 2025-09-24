import SwiftUI

struct AttributionsView: View {
    let licenseText = """
    Apache License
    Version 2.0, January 2004
    http://www.apache.org/licenses/

    Copyright 2025 Kilian Balaguer

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    """

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Attributions")
                    .font(.title)
                    .bold()
                
                Text(licenseText)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
            }
            .padding()
        }
    }
}

struct AttributionsView_Previews: PreviewProvider {
    static var previews: some View {
        AttributionsView()
    }
}
