import Foundation
import FirebaseDatabase

@MainActor
final class ArtistViewModel: ObservableObject {
    @Published var artists: [Artist] = []
    @Published var error: String?

    private let db = Database.database().reference()

    /// Fetch all artists available for bookings
    func fetchArtists() async {
        error = nil
        do {
            let snapshot = try await db.child("artists").getData()
            var loaded: [Artist] = []
            for child in snapshot.children.allObjects as? [DataSnapshot] ?? [] {
                if let value = child.value as? [String: Any] {
                    let name = value["name"] as? String ?? ""
                    let locationId = value["locationId"] as? Int
                    loaded.append(Artist(id: child.key, name: name, locationId: locationId))
                }
            }
            artists = loaded
        } catch {
            if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                self.error = "Unable to fetch artists. Check your internet connection."
            } else {
                self.error = error.localizedDescription
            }
        }
    }

    /// Promote an existing user to artist role using their email.
    func addArtist(email: String) async {
        guard !email.isEmpty else {
            self.error = "Email is required"
            return
        }
        error = nil
        do {
            let usersSnap = try await db.child("users").getData()
            guard let users = usersSnap.children.allObjects as? [DataSnapshot] else {
                self.error = "User not found"
                return
            }
            for userSnap in users {
                if let data = userSnap.value as? [String: Any],
                   let emailValue = data["email"] as? String,
                   emailValue.lowercased() == email.lowercased() {
                    let name = data["name"] as? String ?? ""
                    try await db.child("users").child(userSnap.key).child("role").setValue("artist")
                    try await db.child("artists").child(userSnap.key).setValue([
                        "name": name,
                        "locationId": NSNull()
                    ])
                    await fetchArtists()
                    return
                }
            }
            self.error = "User not found"
        } catch {
            if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                self.error = "Unable to add artist. Check your internet connection."
            } else {
                self.error = error.localizedDescription
            }
        }
    }

    /// Remove artist privileges from a user.
    func removeArtist(_ artist: Artist) async {
        error = nil
        do {
            try await db.child("artists").child(artist.id).removeValue()
            try await db.child("users").child(artist.id).child("role").setValue("user")
            await fetchArtists()
        } catch {
            if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                self.error = "Unable to remove artist. Check your internet connection."
            } else {
                self.error = error.localizedDescription
            }
        }
    }

    /// Assigns an artist to a specific location/branch.
    func assignArtist(_ artistId: String, to locationId: Int) async {
        error = nil
        do {
            try await db.child("artists").child(artistId).child("locationId").setValue(locationId)
            await fetchArtists()
        } catch {
            if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                self.error = "Unable to assign artist. Check your internet connection."
            } else {
                self.error = error.localizedDescription
            }
        }
    }
}
