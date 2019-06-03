import Foundation
import Result

// sourcery: name = PreferencesService
protocol PreferencesServicing: Mockable {
    func save(_ preferences: Preferences) -> Result<Void>
    func load() -> Result<Preferences>
}

// TODO: use bool for key etc, not data
final class PreferencesService: PreferencesServicing {
    private enum Key: String, Keyable {
        case preferences
    }

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let dataManager: DataManaging

    init(dataManager: DataManaging) {
        self.dataManager = dataManager
    }

    func save(_ preferences: Preferences) -> Result<Void> {
        do {
            let data = try encoder.encode(preferences)
            dataManager.save(data, key: Key.preferences)
            return .success(())
        } catch {
            return .failure(PreferencesError.encodeError(error))
        }
    }

    func load() -> Result<Preferences> {
        guard let data = dataManager.load(key: Key.preferences) else {
            return .success(Preferences())
        }
        do {
            let preferences = try decoder.decode(Preferences.self, from: data)
            return .success(preferences)
        } catch {
            return .failure(PreferencesError.decodeError(error))
        }
    }
}
