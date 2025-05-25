import 'package:firebase_database/firebase_database.dart';
import 'package:fyp/models/project_model.dart';
import 'package:fyp/models/user_model.dart'; // Your existing user model
import 'package:fyp/models/bid_model.dart';

class ProjectPostingService {
  static final ProjectPostingService _instance = ProjectPostingService._internal();
  factory ProjectPostingService() => _instance;
  ProjectPostingService._internal();

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Project related methods
  Future<String> createProject(Project project) async {
    try {
      // Generate a unique key for the project
      final projectRef = _database.child('projects').push();
      final projectId = projectRef.key!;

      // Create project with the generated ID
      final projectWithId = project.copyWith(id: projectId);

      // Save to Firebase
      await projectRef.set(projectWithId.toMap());

      // Create notification for the client
      await createNotification(
        userId: project.clientId,
        message: 'Your project "${project.title}" was posted successfully!',
      );

      return projectId;
    } catch (e) {
      throw Exception('Failed to create project: $e');
    }
  }

  Future<Project?> getProject(String projectId) async {
    try {
      final snapshot = await _database.child('projects/$projectId').get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return Project.fromMap(data, projectId);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get project: $e');
    }
  }

  Future<List<Project>> getProjectsByClient(String clientId) async {
    try {
      final query = _database
          .child('projects')
          .orderByChild('clientId')
          .equalTo(clientId);

      final snapshot = await query.get();
      final List<Project> projects = [];

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        data.forEach((key, value) {
          projects.add(Project.fromMap(Map<String, dynamic>.from(value), key));
        });
      }

      return projects;
    } catch (e) {
      throw Exception('Failed to get client projects: $e');
    }
  }

  Future<List<Project>> getAllProjects({String? status}) async {
    try {
      Query query = _database.child('projects');

      if (status != null) {
        query = query.orderByChild('status').equalTo(status);
      }

      final snapshot = await query.get();
      final List<Project> projects = [];

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        data.forEach((key, value) {
          projects.add(Project.fromMap(Map<String, dynamic>.from(value), key));
        });
      }

      // Sort by creation date (newest first)
      projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return projects;
    } catch (e) {
      throw Exception('Failed to get projects: $e');
    }
  }

  Future<void> updateProject(String projectId, Map<String, dynamic> updates) async {
    try {
      await _database.child('projects/$projectId').update(updates);
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _database.child('projects/$projectId').remove();
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }

  // Bid related methods
  Future<String> createBid(Bid bid) async {
    try {
      // Add bid to main bids collection with complete data
      final bidRef = _database.child('bids').push();
      final bidId = bidRef.key!;

      final bidWithId = bid.copyWith(id: bidId);
      final completeBidData = bidWithId.toMap();

      await bidRef.set(completeBidData);

      // IMPORTANT: Add COMPLETE bid data to project's bids (not partial)
      await _database
          .child('projects/${bid.projectId}/bids/$bidId')
          .set(completeBidData); // Use complete data, not partial

      // Create notification for the project owner
      final project = await getProject(bid.projectId);
      if (project != null) {
        await createNotification(
          userId: project.clientId,
          message: 'You received a new bid for "${project.title}"',
        );
      }

      return bidId;
    } catch (e) {
      throw Exception('Failed to create bid: $e');
    }
  }

  Future<List<Bid>> getBidsByProject(String projectId) async {
    try {
      final snapshot = await _database
          .child('projects/$projectId/bids')
          .get();

      final List<Bid> bids = [];

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        data.forEach((key, value) {
          bids.add(Bid.fromMap(Map<String, dynamic>.from(value), key));
        });
      }

      return bids;
    } catch (e) {
      throw Exception('Failed to get project bids: $e');
    }
  }

  Future<List<Bid>> getBidsByArchitect(String architectId) async {
    try {
      print('Fetching bids for architect: $architectId');

      final query = _database
          .child('bids')
          .orderByChild('architectId')
          .equalTo(architectId);

      final snapshot = await query.get();
      final List<Bid> bids = [];

      print('Query snapshot exists: ${snapshot.exists}');

      if (snapshot.exists) {
        // Handle the case where snapshot.value might be null
        final value = snapshot.value;
        if (value != null) {
          final data = Map<String, dynamic>.from(value as Map);
          print('Found ${data.length} bid entries');

          data.forEach((key, value) {
            try {
              final bidData = Map<String, dynamic>.from(value as Map);
              print('Processing bid with key: $key, data: $bidData');

              // Ensure all required fields are present with defaults if needed
              final bid = Bid.fromMap(bidData, key);
              bids.add(bid);
              print('Successfully added bid: ${bid.id}');
            } catch (e) {
              print('Error parsing bid with key $key: $e');
              print('Bid data: $value');
            }
          });
        }
      } else {
        print('No bids found for architect: $architectId');
      }

      print('Total bids loaded: ${bids.length}');
      return bids;
    } catch (e) {
      print('Error in getBidsByArchitect: $e');
      throw Exception('Failed to get architect bids: $e');
    }
  }

  // New method to update the status of a bid
  Future<void> updateBidStatus(String bidId, BidStatus newStatus) async {
    try {
      // First, get the bid to find its projectId
      final bidSnapshot = await _database.child('bids/$bidId').get();
      if (!bidSnapshot.exists || bidSnapshot.value == null) {
        throw Exception('Bid with ID $bidId not found.');
      }

      final bidData = Map<String, dynamic>.from(bidSnapshot.value as Map);
      final String projectId = bidData['projectId'];

      // Update status in the main 'bids' collection
      await _database.child('bids/$bidId').update({'status': newStatus.name});

      // Update status in the project's nested 'bids' collection
      await _database.child('projects/$projectId/bids/$bidId').update({'status': newStatus.name});

      // Optional: Create a notification for the architect whose bid status changed
      // You would need to fetch the architect's ID from the bidData
      // and then call createNotification for them.
      // For example:
      // final String architectId = bidData['architectId'];
      // await createNotification(
      //   userId: architectId,
      //   message: 'Your bid for project "$projectId" has been ${newStatus.name}!',
      // );

    } catch (e) {
      throw Exception('Failed to update bid status: $e');
    }
  }


  // User related methods (compatible with your existing UserModel)
  Future<void> createUser(UserModel user) async {
    try {
      // Convert UserModel to the database format
      final userMap = user.toMap();
      // Map userType to role for database compatibility
      userMap['role'] = user.userType.name;

      await _database.child('users/${user.uid}').set(userMap);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final snapshot = await _database.child('users/$userId').get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return UserModel.fromMap(data, userId);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      // If updating userType, also update role field for database consistency
      if (updates.containsKey('userType')) {
        updates['role'] = updates['userType'];
      }

      await _database.child('users/$userId').update(updates);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Check if user is a client (helper method for project posting)
  Future<bool> canUserPostProject(String userId) async {
    try {
      final user = await getUser(userId);
      return user?.userType == UserType.client;
    } catch (e) {
      return false;
    }
  }

  // Check if user is an architect (helper method for bidding)
  Future<bool> isUserArchitect(String userId) async {
    try {
      final user = await getUser(userId);
      return user?.userType == UserType.architect;
    } catch (e) {
      return false;
    }
  }

  // Notification methods
  Future<void> createNotification({
    required String userId,
    required String message,
  }) async {
    try {
      final notificationRef = _database.child('notifications/$userId').push();
      final notification = {
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
        'read': false,
      };

      await notificationRef.set(notification);
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      final snapshot = await _database
          .child('notifications/$userId')
          .orderByChild('timestamp')
          .get();

      final List<Map<String, dynamic>> notifications = [];

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        data.forEach((key, value) {
          final notificationData = Map<String, dynamic>.from(value);
          notificationData['id'] = key;
          notifications.add(notificationData);
        });
      }

      // Sort by timestamp (newest first)
      notifications.sort((a, b) {
        final timestampA = DateTime.parse(a['timestamp']);
        final timestampB = DateTime.parse(b['timestamp']);
        return timestampB.compareTo(timestampA);
      });

      return notifications;
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    try {
      await _database
          .child('notifications/$userId/$notificationId')
          .update({'read': true});
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Stream methods for real-time updates
  Stream<List<Project>> getProjectsStream({String? status}) {
    Query query = _database.child('projects');

    if (status != null) {
      query = query.orderByChild('status').equalTo(status);
    }

    return query.onValue.map((event) {
      final List<Project> projects = [];

      if (event.snapshot.exists) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data.forEach((key, value) {
          projects.add(Project.fromMap(Map<String, dynamic>.from(value), key));
        });
      }

      projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return projects;
    });
  }

  Stream<List<Map<String, dynamic>>> getUserNotificationsStream(String userId) {
    return _database
        .child('notifications/$userId')
        .orderByChild('timestamp')
        .onValue
        .map((event) {
      final List<Map<String, dynamic>> notifications = [];

      if (event.snapshot.exists) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data.forEach((key, value) {
          final notificationData = Map<String, dynamic>.from(value);
          notificationData['id'] = key;
          notifications.add(notificationData);
        });
      }

      notifications.sort((a, b) {
        final timestampA = DateTime.parse(a['timestamp']);
        final timestampB = DateTime.parse(b['timestamp']);
        return timestampB.compareTo(timestampA);
      });

      return notifications;
    });
  }

  // Get projects with user details (for displaying project lists)
  Future<List<Map<String, dynamic>>> getProjectsWithClientInfo({String? status}) async {
    try {
      final projects = await getAllProjects(status: status);
      final List<Map<String, dynamic>> projectsWithClientInfo = [];

      for (final project in projects) {
        final client = await getUser(project.clientId);
        projectsWithClientInfo.add({
          'project': project,
          'client': client,
        });
      }

      return projectsWithClientInfo;
    } catch (e) {
      throw Exception('Failed to get projects with client info: $e');
    }
  }
}
