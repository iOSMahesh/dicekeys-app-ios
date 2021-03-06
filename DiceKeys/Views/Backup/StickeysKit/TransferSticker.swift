//
//  TransferSticker.swift
//  DiceKeys
//
//  Created by Stuart Schechter on 2020/12/02.
//

import SwiftUI

struct TransferStickerInstructions: View {
    let diceKey: DiceKey
    var faceIndex: Int

    var face: Face {
        diceKey.faces[faceIndex]
    }

    var stickerSheet: StickerSheetForFace {
        StickerSheetForFace(face: face)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Remove the \(face.letterAndDigit) sticker from the sheet with letters \(stickerSheet.firstLetter.rawValue) through \(stickerSheet.lastLetter.rawValue).")
                .font(.title)
                .minimumScaleFactor(0.5)
            if face.orientationAsLowercaseLetterTrbl != .Top {
                Text("Rotate it so the top faces to the \(face.orientationAsLowercaseLetterTrbl.asFacingString).")
                    .font(.title)
                    .minimumScaleFactor(0.5)
            }
            Text("Place it squarely covering the target rectangle\( faceIndex == 0 ? " at the top left of the target sheet" : "").")
            .font(.title)
            .minimumScaleFactor(0.5)
        }
    }
}

struct TransferSticker: View {
    @State var bounds: CGSize = .zero
    let diceKey: DiceKey
    var faceIndex: Int

    let sideMarginFraction: CGFloat = 0
    let centerMarginFraction: CGFloat = 0.05
    var aspectRatio: CGFloat {
        2 * StickerTargetSheetSpecification.shortSideOverLongSide +
        2 * sideMarginFraction +
        2 * centerMarginFraction
    }

    var fractionalWidthOfPortraitSheet: CGFloat {
        ( CGFloat(1) - (2 * sideMarginFraction + centerMarginFraction) ) / 2
    }
    var totalHeight: CGFloat {
        min(
            bounds.height,
            (bounds.width * fractionalWidthOfPortraitSheet) * StickerTargetSheetSpecification.longSideOverShortSide
        )
    }
    var portraitSheetSize: CGSize {
        CGSize(width: totalHeight * StickerTargetSheetSpecification.shortSideOverLongSide, height: totalHeight)
    }
    var totalWidth: CGFloat {
        portraitSheetSize.width / fractionalWidthOfPortraitSheet
    }

    var faceSizeModel: DiceKeySizeModel { DiceKeySizeModel(portraitSheetSize.width) }
    var faceSize: CGFloat { faceSizeModel.faceSize }
    var faceStepSize: CGFloat { faceSizeModel.stepSize }

    var face: Face {
        diceKey.faces[faceIndex]
    }

    private var stickerSheet: StickerSheetForFace {
        StickerSheetForFace(face: face)
    }

    var keyColumn: Int {
        Int(faceIndex % 5)
    }
    var keyRow: Int {
        Int(faceIndex / 5)
    }

    var lineStart: CGPoint {
        return CGPoint(
        x:
            // Start at left side of left sheet
            (sideMarginFraction * totalWidth) +
            // Move to center of left sheet
            (portraitSheetSize.width / 2) +
            // Move the the center of the face
            ( (stickerSheet.column - 2) * faceSizeModel.stepSize ) +
            // Move closer to the right edge of the face
            faceSizeModel.faceSize * 0.4,
        y:
            // Move to center height
            (portraitSheetSize.height / 2) +
            // Move to the center of the die
            ( stickerSheet.row - 2.5) * faceSizeModel.stepSize
        )
    }

    var lineEnd: CGPoint {
        return CGPoint(
        x:
            // Start at right side of right sheet
            ((CGFloat(1) - sideMarginFraction) * totalWidth) -
            // Move to center of left sheet
            (portraitSheetSize.width / 2) +
            // Move the the center of the face
            ( CGFloat(keyColumn) - 2 ) * faceSizeModel.stepSize -
            // Move closer to the left edge of the face
            faceSizeModel.faceSize * 0.4,
        y:
            // Move to center height
            (portraitSheetSize.height / 2) +
            // Move to the center of the die
            ( CGFloat(keyRow) - 2) * faceSizeModel.stepSize
        )
    }

    var body: some View {
        ChildSizeReader(size: $bounds) {
            HStack(alignment: .center, spacing: 0) {
                StickerSheet(showLetter: face.letter, highlightFaceWithDigit: face.digit)//.frame(width: portraitSheetSize.width, height: portraitSheetSize.height)
                Spacer().frame(maxWidth: bounds.width * centerMarginFraction)
                StickerTargetSheet(diceKey: diceKey, showLettersBeforeIndex: faceIndex, atDieIndex: faceIndex)//.frame(width: portraitSheetSize.width, height: portraitSheetSize.height)
            }.overlay(
                Path { path in
                    path.move(to: lineStart)
                    path.addLine(to: lineEnd)
                }.stroke(Color.blue, lineWidth: 2.0)
            )
        }.aspectRatio(aspectRatio, contentMode: .fit)
    }
}

struct TransferSticker_Previews: PreviewProvider {
    static var previews: some View {
        TransferSticker(diceKey: DiceKey.createFromRandom(), faceIndex: 24)
            .previewDevice(PreviewDevice(rawValue: "iPhone 8"))

        TransferSticker(diceKey: DiceKey.createFromRandom(), faceIndex: 0)
            .previewDevice(PreviewDevice(rawValue: "iPhone 8"))

        TransferSticker(diceKey: DiceKey.createFromRandom(), faceIndex: 13)
            .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
    }
}
