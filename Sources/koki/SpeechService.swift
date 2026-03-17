import AppKit

@MainActor
final class SpeechService {
    private let synthesizer = NSSpeechSynthesizer()

    func read(_ text: String, voiceIdentifier: String, rate: Double) {
        guard text.isEmpty == false else { return }

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking()
        }

        if voiceIdentifier.isEmpty == false {
            let voice = NSSpeechSynthesizer.VoiceName(rawValue: voiceIdentifier)
            _ = synthesizer.setVoice(voice)
        }

        let clampedRate = Float(min(max(rate, 120), 320))
        synthesizer.rate = clampedRate
        synthesizer.startSpeaking(text)
    }

    func stop() {
        synthesizer.stopSpeaking()
    }
}
