import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

//: Band-pass filters allow audio above a specified frequency range and
//: bandwidth to pass through to an output. The center frequency is the starting point
//: from where the frequency limit is set. Adjusting the bandwidth sets how far out
//: above and below the center frequency the frequency band should be.
//: Anything above that band should pass through.

class BandPassButterworthFilterConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let filter: BandPassButterworthFilter
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        filter = BandPassButterworthFilter(player)
        dryWetMixer = DryWetMixer(player, filter)
        engine.output = dryWetMixer
    }

    func start() {
        do { try engine.start() } catch let err { Log(err) }
    }

    func stop() {
        engine.stop()
    }
}

struct BandPassButterworthFilterView: View {
    @StateObject var conductor = BandPassButterworthFilterConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack(spacing: 50) {
                ForEach(conductor.filter.parameters) {
                    ParameterEditor2(param: $0)
                }
                ParameterEditor2(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.filter,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Band Pass Butterworth Filter")
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct BandPassButterworthFilter_Previews: PreviewProvider {
    static var previews: some View {
        BandPassButterworthFilterView()
    }
}
