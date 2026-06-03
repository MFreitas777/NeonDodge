import Foundation

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 1
    static let obstacle: UInt32 = 2
    static let powerUpSlow: UInt32 = 4
    static let powerUpShield: UInt32 = 8
}
