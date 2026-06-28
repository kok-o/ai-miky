import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/message.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save a message to Firestore
  Future<void> saveMessage(String userId, Message message) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('messages')
          .add(message.toMap());
    } catch (e) {
      // Handle error implicitly or rethrow. 
      // For now, logging to console usually suffices in dev, 
      // but in production consider a crash reporting service.
      debugPrint('Error saving message: $e'); 
    }
  }

  // Get stream of messages for a user
  Stream<List<Message>> getMessages(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Message.fromMap(doc.data());
      }).toList();
    });
  }

  // Clear chat history
  Future<void> clearChat(String userId) async {
    final collection = _db
        .collection('users')
        .doc(userId)
        .collection('messages');
    
    final snapshot = await collection.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Get count of user messages (not AI messages)
  Future<int> getUserMessageCount(String userId) async {
    try {
      // Use get() instead of count() for better web compatibility
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('messages')
          .where('isUser', isEqualTo: true)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error getting message count: $e');
      return 0;
    }
  }

  // Get stream of user message count
  Stream<int> getUserMessageCountStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('messages')
        .where('isUser', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Update consecutive login days
  Future<int> updateConsecutiveDays(String userId) async {
    try {
      final userDoc = _db.collection('users').doc(userId);
      final doc = await userDoc.get();
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      if (!doc.exists) {
        // First login
        await userDoc.set({
          'lastLoginDate': Timestamp.fromDate(today),
          'consecutiveDays': 1,
        });
        return 1;
      }
      
      final data = doc.data()!;
      final lastLoginTimestamp = data['lastLoginDate'] as Timestamp?;
      final consecutiveDays = data['consecutiveDays'] as int? ?? 0;
      
      if (lastLoginTimestamp == null) {
        await userDoc.update({
          'lastLoginDate': Timestamp.fromDate(today),
          'consecutiveDays': 1,
        });
        return 1;
      }
      
      final lastLoginDate = lastLoginTimestamp.toDate();
      final lastLoginDay = DateTime(lastLoginDate.year, lastLoginDate.month, lastLoginDate.day);
      
      if (today.isAtSameMomentAs(lastLoginDay)) {
        // Already logged in today
        return consecutiveDays;
      }
      
      final yesterday = today.subtract(const Duration(days: 1));
      int newConsecutiveDays;
      
      if (lastLoginDay.isAtSameMomentAs(yesterday)) {
        // Consecutive day
        newConsecutiveDays = consecutiveDays + 1;
      } else {
        // Streak broken, reset to 1
        newConsecutiveDays = 1;
      }
      
      await userDoc.update({
        'lastLoginDate': Timestamp.fromDate(today),
        'consecutiveDays': newConsecutiveDays,
      });
      
      return newConsecutiveDays;
    } catch (e) {
      debugPrint('Error updating consecutive days: $e');
      return 0;
    }
  }

  // Get consecutive days
  Future<int> getConsecutiveDays(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (!doc.exists) {
        return 0;
      }
      final data = doc.data()!;
      return data['consecutiveDays'] as int? ?? 0;
    } catch (e) {
      debugPrint('Error getting consecutive days: $e');
      return 0;
    }
  }

  // Get stream of consecutive days
  Stream<int> getConsecutiveDaysStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return 0;
      }
      final data = snapshot.data()!;
      return data['consecutiveDays'] as int? ?? 0;
    });
  }

  // Save profile photo URL
  Future<void> saveProfilePhotoUrl(String userId, String photoUrl) async {
    try {
      if (photoUrl.isEmpty) {
        await _db.collection('users').doc(userId).update({
          'profilePhotoUrl': FieldValue.delete(),
        });
      } else {
        await _db.collection('users').doc(userId).set({
          'profilePhotoUrl': photoUrl,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error saving profile photo URL: $e');
    }
  }

  // Update user profile (name and bio)
  Future<void> updateUserProfile(String userId, String displayName, String bio) async {
    try {
      await _db.collection('users').doc(userId).set({
        'displayName': displayName,
        'bio': bio,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (!doc.exists) {
        // Create initial profile if it doesn't exist
        await _db.collection('users').doc(userId).set({
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });
        final newDoc = await _db.collection('users').doc(userId).get();
        return newDoc.data();
      }
      return doc.data();
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  // Send an error report
  Future<void> sendErrorReport(String userId, String userEmail, String description) async {
    try {
      await _db.collection('reports').add({
        'userId': userId,
        'userEmail': userEmail,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'new',
      });
    } catch (e) {
      debugPrint('Error sending error report: $e');
      rethrow;
    }
  }

  // Get stream of all error reports (for admins)
  Stream<QuerySnapshot<Map<String, dynamic>>> getErrorReports() {
    return _db
        .collection('reports')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get profile photo URL
  Future<String?> getProfilePhotoUrl(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (!doc.exists) {
        return null;
      }
      final data = doc.data()!;
      return data['profilePhotoUrl'] as String?;
    } catch (e) {
      debugPrint('Error getting profile photo URL: $e');
      return null;
    }
  }

  // Get stream of profile photo URL
  Stream<String?> getProfilePhotoUrlStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      final data = snapshot.data()!;
      return data['profilePhotoUrl'] as String?;
    });
  }
}
