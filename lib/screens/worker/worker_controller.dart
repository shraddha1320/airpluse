// Central state holder for the Worker Module.
// Deliberately dependency-free (no external state package) so it drops
// into the existing architecture without new pubspec requirements.

import 'package:flutter/foundation.dart';
import '../models/worker_models.dart';

class WorkerController extends ChangeNotifier {
  WorkerController({WorkerProfile? profile, List<WorkerJob>? jobs})
      : profile = profile ?? WorkerMockData.profile(),
        jobs = jobs ?? WorkerMockData.jobs(),
        notifications = WorkerMockData.notifications();

  final WorkerProfile profile;
  final List<WorkerJob> jobs;
  final List<WorkerNotification> notifications;

  List<WorkerJob> get activeJobs => jobs
      .where((j) => j.status != JobStatus.resolved)
      .toList()
    ..sort((a, b) => b.priority.index.compareTo(a.priority.index));

  List<WorkerJob> get historyJobs =>
      jobs.where((j) => j.status == JobStatus.resolved).toList()
        ..sort((a, b) =>
            (b.completionTime ?? b.assignedTime).compareTo(a.completionTime ?? a.assignedTime));

  WorkerJob? get currentActiveAssignment {
    try {
      return jobs.firstWhere((j) => j.status == JobStatus.inProgress);
    } catch (_) {
      return null;
    }
  }

  int get unreadNotificationCount => notifications.where((n) => !n.read).length;

  bool get hasInProgressJob => jobs.any((j) => j.status == JobStatus.inProgress);

  void acceptJob(String jobId) {
    _updateStatus(jobId, JobStatus.accepted);
  }

  /// Returns false if another job is already In Progress — only one
  /// complaint may remain In Progress at a time.
  bool startWork(String jobId) {
    if (hasInProgressJob) return false;
    _updateStatus(jobId, JobStatus.inProgress);
    profile.availability = WorkerAvailability.busy;
    notifyListeners();
    return true;
  }

  void attachCompletionPhoto(String jobId, String path) {
    final job = jobs.firstWhere((j) => j.id == jobId);
    job.completionPhotoPath = path;
    job.status = JobStatus.completed;
    notifyListeners();
  }

  void markResolved(String jobId) {
    final job = jobs.firstWhere((j) => j.id == jobId);
    job.status = JobStatus.resolved;
    job.completionTime = DateTime.now();
    if (!hasInProgressJob) {
      profile.availability = WorkerAvailability.available;
    }
    notifyListeners();
  }

  void setAvailability(WorkerAvailability availability) {
    profile.availability = availability;
    notifyListeners();
  }

  void markAllNotificationsRead() {
    for (final n in notifications) {
      n.read = true;
    }
    notifyListeners();
  }

  void _updateStatus(String jobId, JobStatus status) {
    final job = jobs.firstWhere((j) => j.id == jobId);
    job.status = status;
    notifyListeners();
  }
}
