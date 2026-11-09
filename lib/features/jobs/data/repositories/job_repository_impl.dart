import 'package:jobfy/core/config/app_config.dart';
import 'package:jobfy/core/network/api_client.dart';
import '../../domain/entities/job_details_entity.dart';
import '../../domain/entities/job_listing_entity.dart';
import '../../domain/repositories/job_repository.dart';
import '../datasources/job_data_source.dart';
import '../datasources/job_mysql_data_source.dart';
import '../datasources/job_remote_data_source.dart';

class JobRepositoryImpl implements JobRepository {
  final JobDataSource _dataSource;

  JobRepositoryImpl([JobDataSource? dataSource])
      : _dataSource = dataSource ??
            (AppConfig.useMysql
                ? JobMysqlDataSource()
                : JobRemoteDataSource(ApiClient()));

  @override
  Future<List<JobListingEntity>> searchJobs({String? query, String? location}) {
    return _dataSource.searchJobs(query: query, location: location);
  }

  @override
  Future<JobDetailsEntity?> getJobDetails(String jobId, {String? userId}) {
    return _dataSource.getJobDetails(jobId, userId: userId);
  }

  @override
  Future<void> applyToJob(String jobId, String userId) => _dataSource.applyToJob(jobId, userId);
}
