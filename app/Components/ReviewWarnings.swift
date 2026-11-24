import SpectraCore
import SwiftUI

/// What core warns of in a reviewed transaction, one line each, wherever an
/// artifact is reviewed: a send's stages and a staking action's review.
struct ReviewWarnings: View {
    let artifact: SendArtifact

    var body: some View {
        ForEach(Array(artifact.reviewWarningMessages.enumerated()), id: \.offset) { _, reason in
            Label(reason, systemImage: "exclamationmark.triangle")
                .font(.subheadline)
                .foregroundStyle(.spectraWarning)
        }
    }
}
