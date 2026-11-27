import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sqflite/sqflite.dart';

/// Firebase প্রজেক্ট gonti01 (google-services.json থেকে)।
/// এগুলো গোপন নয় — অ্যাপের ভেতরেই থাকে। ডেটার নিরাপত্তা আসে Firestore rules থেকে।
const firebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyAyDQErRy-fuU1C1YdH1u_VXAO9pATfoJM',
  appId: '1:783570563190:android:fc5f7aa7974bdd07ecaf57',
  messagingSenderId: '783570563190',
  projectId: 'gonti01',
  storageBucket: 'gonti01.firebasestorage.app',
);

/// Web client (client_type 3) — Google লগইনে idToken পেতে লাগে।
const _webClientId = '783570563190-tqc4e7hsbk8gkufe1c46vod3p2k2d778.apps.googleusercontent.com';

/// ব্যাকআপের নিয়ম:
/// - ফোনের SQLite ই আসল হিসাব (অফলাইনে চলে)।
/// - লগইন থাকলে পুরো হিসাব Firestore এ কপি হয়: users/{uid} (মেটা) + users/{uid}/chunks/{table}_{n}
/// - রিস্টোর = ক্লাউডের কপি দিয়ে ফোনের হিসাব বদলে দেওয়া।
class Cloud {
  Cloud._();
  static bool ready = false;

  static Future<void> init() async {
    try {
      await Firebase.initializeApp(options: firebaseOptions);
      ready = true;
    } catch (_) {
      ready = false; // Firebase না চললেও অ্যাপ অফলাইনে চলবে
    }
  }

  static final _google = GoogleSignIn(serverClientId: _webClientId, scopes: const ['email']);
  static User? get user => ready ? FirebaseAuth.instance.currentUser : null;

  /// null = ইউজার বাতিল করেছে
  static Future<User?> signIn() async {
    if (!ready) throw Exception('Firebase not ready');
    final acc = await _google.signIn();
    if (acc == null) return null;
    final auth = await acc.authentication;
    final cred = GoogleAuthProvider.credential(idToken: auth.idToken, accessToken: auth.accessToken);
    final r = await FirebaseAuth.instance.signInWithCredential(cred);
    return r.user;
  }

  static Future<void> signOut() async {
    try {
      await _google.signOut();
    } catch (_) {}
    if (ready) await FirebaseAuth.instance.signOut();
  }

  // FK অনুযায়ী ক্রম: আগে মূল টেবিল, পরে যারা তাদের id ধরে রাখে
  static const tables = ['categories', 'debts', 'dps', 'transactions', 'debt_payments', 'dps_payments', 'budget_limits'];
  static const _chunk = 1500;

  static DocumentReference<Map<String, dynamic>> _userDoc(String uid) => FirebaseFirestore.instance.collection('users').doc(uid);

  /// ক্লাউডে ব্যাকআপ থাকলে কখন নেওয়া হয়েছিল, না থাকলে null
  static Future<DateTime?> lastBackup() async {
    final u = user;
    if (u == null) return null;
    final snap = await _userDoc(u.uid).get();
    final ts = snap.data()?['updatedAt'];
    return ts is Timestamp ? ts.toDate() : null;
  }

  static Future<DateTime> backup(Database db, Map<String, Object?> prefs) async {
    final u = user;
    if (u == null) throw Exception('Not signed in');
    final ref = _userDoc(u.uid);
    final chunks = ref.collection('chunks');
    final old = await chunks.get();
    final keep = <String>{};
    var batch = FirebaseFirestore.instance.batch();
    var ops = 0;
    Future<void> flushIfFull() async {
      if (ops >= 400) {
        await batch.commit();
        batch = FirebaseFirestore.instance.batch();
        ops = 0;
      }
    }

    for (final tbl in tables) {
      final rows = await db.query(tbl, orderBy: 'id');
      for (var i = 0; i * _chunk < rows.length || i == 0; i++) {
        final part = rows.skip(i * _chunk).take(_chunk).toList();
        final id = '${tbl}_$i';
        keep.add(id);
        batch.set(chunks.doc(id), {'table': tbl, 'n': i, 'rows': part});
        ops++;
        await flushIfFull();
        if (part.length < _chunk) break;
      }
    }
    for (final d in old.docs) {
      if (!keep.contains(d.id)) {
        batch.delete(d.reference);
        ops++;
        await flushIfFull();
      }
    }
    batch.set(ref, {
      'updatedAt': FieldValue.serverTimestamp(),
      'schema': 1,
      'prefs': prefs,
      'email': u.email,
    });
    await batch.commit();
    return DateTime.now();
  }

  /// ক্লাউডের হিসাব ফোনে বসায়। prefs (মাস শুরু, বাজেট) ফেরত দেয়।
  static Future<Map<String, dynamic>> restore(Database db) async {
    final u = user;
    if (u == null) throw Exception('Not signed in');
    final ref = _userDoc(u.uid);
    final meta = await ref.get();
    if (!meta.exists) throw Exception('No backup');
    final docs = (await ref.collection('chunks').get()).docs;
    final byTable = <String, List<Map<String, dynamic>>>{};
    final sorted = docs.map((d) => d.data()).toList()..sort((a, b) => (a['n'] as num).compareTo(b['n'] as num));
    for (final d in sorted) {
      final rows = (d['rows'] as List).map((r) => Map<String, dynamic>.from(r as Map)).toList();
      byTable.putIfAbsent(d['table'] as String, () => []).addAll(rows);
    }
    await db.transaction((txn) async {
      for (final tbl in tables.reversed) {
        await txn.delete(tbl);
      }
      for (final tbl in tables) {
        for (final r in byTable[tbl] ?? const <Map<String, dynamic>>[]) {
          await txn.insert(tbl, r);
        }
      }
    });
    return Map<String, dynamic>.from((meta.data()?['prefs'] as Map?) ?? const {});
  }
}
