#if os(macOS)
    import SwiftUI

    // What iOS asks of its software keyboard: which keys it shows and what it
    // capitalizes. A Mac types on hardware, so SwiftUI has neither modifier
    // there. They are declared here doing nothing, so a field says what it
    // holds once, for both platforms.

    /// The software keyboard a field asks for on iOS.
    enum UIKeyboardType {
        case `default`, decimalPad, numberPad, URL
    }

    /// What the software keyboard capitalizes on iOS.
    enum TextInputAutocapitalization {
        case never, words, sentences, characters
    }

    extension View {
        func keyboardType(_ type: UIKeyboardType) -> some View { self }
        func textInputAutocapitalization(_ autocapitalization: TextInputAutocapitalization?) -> some View { self }
    }
#endif
