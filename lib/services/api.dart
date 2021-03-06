import 'dart:async';
import 'package:catbox/models/cat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CatApi {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static GoogleSignIn _googleSignIn = new GoogleSignIn();

  FirebaseUser firebaseUser;

  CatApi(FirebaseUser user) {
    this.firebaseUser = user;
  }

  static Future<CatApi> signInWithGoogle() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final AuthResult authResult = await auth.signInWithCredential(credential);
    FirebaseUser user = authResult.user;
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    FirebaseUser currentUser = await auth.currentUser();
    assert(user.uid == currentUser.uid);

    return new CatApi(user);
  }

  Cat _fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data;

    return new Cat(
        documentId: snapshot.documentID,
        externalId: data['id'],
        name: data['name'],
        description: data['description'],
        avatarUrl: data['image_url'],
        location: data['location'],
        likeCounter: data['like_counter'],
        isAdopted: data['adopted'],
        pictures: new List<String>.from(data['pictures']),
        cattributes: new List<String>.from(data['cattributes']));
  }

  Future likeCat(Cat cat) async {
    await Firestore.instance
        .collection('users')
        .document('${this.firebaseUser.uid}')
        .collection('liked')
        .document('${cat.documentId}')
        .setData({'name':cat.name, 'description':cat.description, 'image_url':cat.avatarUrl});
  }

  Future unlikeCat(Cat cat) async {
    await Firestore.instance
        .collection('users')
        .document('${this.firebaseUser.uid}')
        .collection('liked')
        .document('${cat.documentId}')
        .delete();
  }

  Future<bool> hasLikedCat(Cat cat) async {
    final like = await Firestore.instance
        .collection('users')
        .document('${this.firebaseUser.uid}')
        .collection('liked')
        .document('${cat.documentId}')
        .get();

    return like.exists;
  }

  Future<List<Cat>> getAllCats() async {
    return (await Firestore.instance.collection('cats').getDocuments())
        .documents
        .map((snapshot) => _fromDocumentSnapshot(snapshot))
        .toList();
  }

  StreamSubscription watch(Cat cat, void onChange(Cat cat)) {
    return Firestore.instance
        .collection('cats')
        .document(cat.documentId)
        .snapshots()
        .listen((snapshot) => onChange(_fromDocumentSnapshot(snapshot)));
  }

  Cat _fromDocumentSnapshotCart(DocumentSnapshot snapshot) {
    final data = snapshot.data;

    return new Cat(
        documentId: snapshot.documentID,
        externalId: null,
        name: data['name'],
        description: data['description'],
        avatarUrl: data['image_url'],
        location: null,
        likeCounter: null,
        isAdopted: null,
        pictures: null,
        cattributes: null);
  }

  Future<bool> inCart(Cat cat) async {
    final hank = await Firestore.instance
        .collection('users')
        .document('${this.firebaseUser.uid}')
        .collection('cart')
        .document(cat.documentId)
        .get();

    return hank.exists;
  }

  Future addToCart(Cat cat) async {
    await Firestore.instance
        .collection('users')
        .document('${this.firebaseUser.uid}')
        .collection('cart')
        .document('${cat.documentId}')
        .setData({'name':cat.name, 'description':cat.description, 'image_url':cat.avatarUrl});
  }

  Future removeFromCart(Cat cat) async {
    await Firestore.instance
        .collection('users')
        .document('${this.firebaseUser.uid}')
        .collection('cart')
        .document('${cat.documentId}')
        .delete();
  }

  Future<List<Cat>> getCartItems() async {
    return (await Firestore.instance.collection('users').document('${this.firebaseUser.uid}').collection('cart').getDocuments())
        .documents
        .map((snapshot) => _fromDocumentSnapshotCart(snapshot))
        .toList();
  }

  StreamSubscription watchCart(Cat cat, void onChange(Cat cat)) {
    return Firestore.instance
        .collection('cats')
        .document(cat.documentId)
        .snapshots()
        .listen((snapshot) => onChange(_fromDocumentSnapshot(snapshot)));
  }

  Future<Cat> getCartCat(Cat snap) async {
     return _fromDocumentSnapshot(await Firestore.instance
        .collection('cats')
        .document(snap.documentId)
        .get());
  }

  Future<List<Cat>> getLikedCats() async {
    return (await Firestore.instance.collection('users').document('${this.firebaseUser.uid}').collection('liked').getDocuments())
        .documents
        .map((snapshot) => _fromDocumentSnapshotCart(snapshot))
        .toList();
  }
}