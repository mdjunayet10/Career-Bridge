import 'package:career_bridge/core/services/push_route_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('notification routes accept only a job identifier', () {
    expect(jobRouteFromPayload('/jobs/job-123'), '/jobs/job-123');
    for (final route in [
      null,
      'https://evil.test/jobs/x',
      '/admin/users',
      '/jobs/x/edit',
      '/jobs/x?next=/admin',
      '/jobs/..',
      '/jobs/%2Fadmin',
      '//evil/jobs/x'
    ]) {
      expect(jobRouteFromPayload(route), isNull, reason: route);
    }
  });
}
