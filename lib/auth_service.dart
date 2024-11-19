import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If the user cancels the login
      if (googleUser == null) {
        return null;
      }

      // Obtain the authentication details from Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential for Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      final UserCredential userCredential =
      await _firebaseAuth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      print('Error during Google sign-in: $e');
      return null;
    }
  }

  // Sign out from Google and Firebase
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  // Get the current user
  Future<User?> getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }
}
