import SwiftUI

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

/// An address, key or list of addresses being typed: it wraps between its
/// actual characters, and layout never adds a hyphen that would read as part
/// of it. The platform's text view retains the original editable string,
/// including copy and selection. One address takes Return as done; a list
/// takes it as a line.
@MainActor
struct AddressInput: View {
    @Binding var text: String
    @Binding var isFocused: Bool
    let prompt: String
    var allowsNewlines = false
    #if os(macOS)
        /// A Mac has no Dynamic Type: the system's own subheadline size.
        private let fontSize = NSFont.preferredFont(forTextStyle: .subheadline).pointSize
    #else
        @ScaledMetric(relativeTo: .subheadline) private var fontSize: CGFloat = 15
    #endif

    var body: some View {
        AddressTextView(text: $text, isFocused: $isFocused, prompt: prompt, fontSize: fontSize, allowsNewlines: allowsNewlines)
            .overlay(alignment: .topLeading) {
                if text.isEmpty {
                    Text(verbatim: prompt)
                        .font(.subheadline.monospaced())
                        .foregroundStyle(.tertiary)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
    }
}

#if os(iOS)
    @MainActor
    private struct AddressTextView: UIViewRepresentable {
        @Binding var text: String
        @Binding var isFocused: Bool
        let prompt: String
        let fontSize: CGFloat
        let allowsNewlines: Bool

        func makeCoordinator() -> Coordinator { Coordinator(input: self) }

        func makeUIView(context: Context) -> UITextView {
            // The paragraph style below explicitly disables system hyphenation;
            // TextKit lays out the raw address by characters instead of words.
            let view = UITextView(usingTextLayoutManager: true)
            view.delegate = context.coordinator
            view.backgroundColor = .clear
            view.isScrollEnabled = false
            view.textContainerInset = .zero
            view.textContainer.lineFragmentPadding = 0
            view.textContainer.lineBreakMode = .byCharWrapping
            view.autocapitalizationType = .none
            view.autocorrectionType = .no
            view.spellCheckingType = .no
            view.smartDashesType = .no
            view.smartQuotesType = .no
            view.smartInsertDeleteType = .no
            view.returnKeyType = allowsNewlines ? .default : .done
            view.adjustsFontForContentSizeCategory = false
            view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            applyText(to: view)
            return view
        }

        func updateUIView(_ view: UITextView, context: Context) {
            context.coordinator.input = self
            applyText(to: view)
            if isFocused && !view.isFirstResponder {
                view.becomeFirstResponder()
            } else if !isFocused && view.isFirstResponder {
                view.resignFirstResponder()
            }
        }

        func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
            guard let width = proposal.width, width > 0 else { return nil }
            let size = uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
            return CGSize(width: width, height: ceil(size.height))
        }

        private func applyText(to view: UITextView) {
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineBreakMode = .byCharWrapping
            paragraph.hyphenationFactor = 0
            paragraph.usesDefaultHyphenation = false
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
                .foregroundColor: UIColor.label,
                .paragraphStyle: paragraph,
            ]
            // Replacing attributedText on every keystroke resets the selection and
            // marked text. Only outside edits and Dynamic Type changes need it.
            if view.text != text || view.font?.pointSize != fontSize {
                let selection = view.selectedRange
                view.attributedText = NSAttributedString(string: text, attributes: attributes)
                let length = (text as NSString).length
                let location = min(selection.location, length)
                view.selectedRange = NSRange(location: location, length: min(selection.length, length - location))
                view.invalidateIntrinsicContentSize()
            }
            view.typingAttributes = attributes
            view.accessibilityLabel = prompt
        }

        @MainActor
        final class Coordinator: NSObject, UITextViewDelegate {
            var input: AddressTextView

            init(input: AddressTextView) { self.input = input }

            func textViewDidChange(_ textView: UITextView) {
                input.text = textView.text
                textView.invalidateIntrinsicContentSize()
            }

            func textViewDidBeginEditing(_ textView: UITextView) {
                if !input.isFocused { input.isFocused = true }
            }

            func textViewDidEndEditing(_ textView: UITextView) {
                if input.isFocused { input.isFocused = false }
            }
        }
    }
#else
    @MainActor
    private struct AddressTextView: NSViewRepresentable {
        @Binding var text: String
        @Binding var isFocused: Bool
        let prompt: String
        let fontSize: CGFloat
        let allowsNewlines: Bool

        func makeCoordinator() -> Coordinator { Coordinator(input: self) }

        func makeNSView(context: Context) -> FocusReportingTextView {
            // TextKit lays out the raw address by characters instead of
            // words; the paragraph style below disables system hyphenation.
            let view = FocusReportingTextView(usingTextLayoutManager: false)
            view.delegate = context.coordinator
            view.drawsBackground = false
            view.isRichText = false
            view.allowsUndo = true
            view.textContainerInset = .zero
            view.textContainer?.lineFragmentPadding = 0
            view.textContainer?.lineBreakMode = .byCharWrapping
            view.textContainer?.widthTracksTextView = true
            view.isHorizontallyResizable = false
            view.isContinuousSpellCheckingEnabled = false
            view.isGrammarCheckingEnabled = false
            view.isAutomaticSpellingCorrectionEnabled = false
            view.isAutomaticTextReplacementEnabled = false
            view.isAutomaticTextCompletionEnabled = false
            view.isAutomaticQuoteSubstitutionEnabled = false
            view.isAutomaticDashSubstitutionEnabled = false
            view.isAutomaticDataDetectionEnabled = false
            view.isAutomaticLinkDetectionEnabled = false
            view.inlinePredictionType = .no
            view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            view.onFocusChange = { [coordinator = context.coordinator] focused in coordinator.focusChanged(focused) }
            applyText(to: view)
            return view
        }

        func updateNSView(_ view: FocusReportingTextView, context: Context) {
            let coordinator = context.coordinator
            coordinator.input = self
            applyText(to: view)
            // Only a change of the binding moves the focus. A click reaches
            // the view before it reaches the binding, and an update between
            // the two must not take the focus the click just gave.
            guard isFocused != coordinator.appliedFocus else { return }
            coordinator.appliedFocus = isFocused
            let isFirstResponder = view.window?.firstResponder === view
            if isFocused && !isFirstResponder {
                view.window?.makeFirstResponder(view)
            } else if !isFocused && isFirstResponder {
                view.window?.makeFirstResponder(nil)
            }
        }

        func sizeThatFits(_ proposal: ProposedViewSize, nsView: FocusReportingTextView, context: Context) -> CGSize? {
            guard let width = proposal.width, width > 0, width.isFinite,
                let container = nsView.textContainer, let layout = nsView.layoutManager
            else { return nil }
            container.size = CGSize(width: width, height: .greatestFiniteMagnitude)
            layout.ensureLayout(for: container)
            // An empty view still has the height of the line to be typed.
            let line = layout.defaultLineHeight(for: .monospacedSystemFont(ofSize: fontSize, weight: .regular))
            return CGSize(width: width, height: ceil(max(layout.usedRect(for: container).height, line)))
        }

        private func applyText(to view: NSTextView) {
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineBreakMode = .byCharWrapping
            paragraph.hyphenationFactor = 0
            paragraph.usesDefaultHyphenation = false
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
                .foregroundColor: NSColor.labelColor,
                .paragraphStyle: paragraph,
            ]
            // Replacing the text on every keystroke resets the selection and
            // marked text. Only outside edits need it.
            if view.string != text {
                let selection = view.selectedRange()
                view.textStorage?.setAttributedString(NSAttributedString(string: text, attributes: attributes))
                let length = (text as NSString).length
                let location = min(selection.location, length)
                view.setSelectedRange(NSRange(location: location, length: min(selection.length, length - location)))
                view.invalidateIntrinsicContentSize()
            }
            view.typingAttributes = attributes
            view.setAccessibilityLabel(prompt)
        }

        @MainActor
        final class Coordinator: NSObject, NSTextViewDelegate {
            var input: AddressTextView
            /// The binding's value the view's focus was last matched to.
            var appliedFocus = false

            init(input: AddressTextView) { self.input = input }

            func textDidChange(_ notification: Notification) {
                guard let view = notification.object as? NSTextView else { return }
                input.text = view.string
                view.invalidateIntrinsicContentSize()
            }

            /// Tab leaves the field as it does any other; Return ends a
            /// single address and is a line in a list.
            func textView(_ textView: NSTextView, doCommandBy selector: Selector) -> Bool {
                switch selector {
                case #selector(NSResponder.insertTab(_:)):
                    textView.window?.selectNextKeyView(nil)
                    return true
                case #selector(NSResponder.insertBacktab(_:)):
                    textView.window?.selectPreviousKeyView(nil)
                    return true
                case #selector(NSResponder.insertNewline(_:)) where !input.allowsNewlines:
                    textView.window?.makeFirstResponder(nil)
                    return true
                default:
                    return false
                }
            }

            /// The responder chain reports a focus change in the middle of
            /// whatever caused it, which may be a view update; the binding is
            /// written after it.
            func focusChanged(_ focused: Bool) {
                appliedFocus = focused
                Task { @MainActor in
                    if input.isFocused != focused { input.isFocused = focused }
                }
            }
        }
    }

    /// Says when it starts and stops being the view typed in: a text view's
    /// delegate hears of the first change, not of the focus.
    private final class FocusReportingTextView: NSTextView {
        var onFocusChange: ((Bool) -> Void)?

        override func becomeFirstResponder() -> Bool {
            let became = super.becomeFirstResponder()
            if became { onFocusChange?(true) }
            return became
        }

        override func resignFirstResponder() -> Bool {
            let resigned = super.resignFirstResponder()
            if resigned { onFocusChange?(false) }
            return resigned
        }
    }
#endif
