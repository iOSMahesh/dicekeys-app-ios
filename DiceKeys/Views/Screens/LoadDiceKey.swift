//
//  LoadDiceKey.swift
//  DiceKeys
//
//  Created by Stuart Schechter on 2021/01/25.
//

import SwiftUI


struct LoadDiceKey: View {
    @State var useCamera: Bool = true
    
    // Generating the state for manual entry here and pasing it down ensures that if
    // we go back and forth between camera-mode and manual-mode the user won't lose
    // the work they've done entering DiceKey state.
    var editableDiceKeyState: EditableDiceKeyState = EditableDiceKeyState()

    let onDiceKeyLoaded: ((_ diceKey: DiceKey, _ entryMethod: LoadDiceKeyEntryMethod) -> Void)?

    var body: some View {
        let view = VStack(alignment: .center, spacing: 0) {
            if (useCamera) {
                ScanDiceKey(onDiceKeyRead: { diceKey in onDiceKeyLoaded?(diceKey, .byCamera) })
                Button(action: { useCamera = false }, label: { Text("Enter the DiceKey by Hand") })
            } else {
                TypeYourDiceKeyView(
                        onDiceKeyEntered: {diceKey in onDiceKeyLoaded?(diceKey, .manual)},
                        editableDiceKeyState: editableDiceKeyState
                    )
                Button(action: { useCamera = true }, label: { Text("Scan the DiceKey with my Camera") })
            }
        }
        #if os(iOS)
        return view.navigationBarTitleDisplayMode(.inline)
            .navigationBarDiceKeyStyle()
        #else
        return view
        #endif
    }
}


struct LoadDiceKey_Previews: PreviewProvider {
    static var previews: some View {
        LoadDiceKey(onDiceKeyLoaded: { diceKey, _ in print("DiceKey loaded: \(diceKey.toHumanReadableForm())") })
    }
}