import SwiftUI

// Forage palette: forest #344B3B, sage #899B78, cream #F7F3E8,
// clay #B86B47, ink #302F2A. Dynamic surfaces retain dark-mode contrast.
extension Color {
    static let forestGreen = Color(red: 52/255, green: 75/255, blue: 59/255)
    static let forageSage = Color(red: 137/255, green: 155/255, blue: 120/255)
    static let accentOrange = Color(red: 184/255, green: 107/255, blue: 71/255)
    static let accentGold = Color(red: 0.70, green: 0.48, blue: 0.17)
    static let forageInk = Color(red: 48/255, green: 47/255, blue: 42/255)
    static let backgroundSoft = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.10, green: 0.13, blue: 0.11, alpha: 1)
            : UIColor(red: 247/255, green: 243/255, blue: 232/255, alpha: 1)
    })
    static let forageCard = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.16, green: 0.20, blue: 0.17, alpha: 1)
            : UIColor(red: 1.0, green: 0.99, blue: 0.96, alpha: 1)
    })
    static let forageHeading = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.78, green: 0.86, blue: 0.73, alpha: 1)
            : UIColor(red: 52/255, green: 75/255, blue: 59/255, alpha: 1)
    })
    static let forageAction = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.66, green: 0.78, blue: 0.60, alpha: 1)
            : UIColor(red: 52/255, green: 75/255, blue: 59/255, alpha: 1)
    })
}
