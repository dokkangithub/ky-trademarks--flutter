import 'package:flutter/material.dart';
import 'package:kyuser/app/RequestState/RequestState.dart';
import 'package:kyuser/presentation/Controllar/Issues/GetIssueDetailsProvider.dart';
import 'package:kyuser/presentation/Controllar/Issues/GetIssuesProvider.dart';
import 'package:kyuser/presentation/Controllar/Issues/GetIssuesSummaryProvider.dart';
import 'package:kyuser/presentation/Controllar/Issues/SearchIssuesProvider.dart';
import '../../../core/Services_locator.dart';

/// This is a test provider to demonstrate how to use the Issues API
/// Use this for testing the new Issues endpoints
class IssuesTestProvider extends ChangeNotifier {
  final GetIssuesProvider _issuesProvider = sl<GetIssuesProvider>();
  final GetIssueDetailsProvider _issueDetailsProvider = sl<GetIssueDetailsProvider>();
  final GetIssuesSummaryProvider _issuesSummaryProvider = sl<GetIssuesSummaryProvider>();
  final SearchIssuesProvider _searchIssuesProvider = sl<SearchIssuesProvider>();

  // Getters to access provider states
  GetIssuesProvider get issuesProvider => _issuesProvider;
  GetIssueDetailsProvider get issueDetailsProvider => _issueDetailsProvider;
  GetIssuesSummaryProvider get issuesSummaryProvider => _issuesSummaryProvider;
  SearchIssuesProvider get searchIssuesProvider => _searchIssuesProvider;

  /// Example usage of Issues API endpoints
  /// Replace customerId with actual customer ID (244 is from the example)
  
  /// 1. Get Issues List
  /// curl -X GET "https://yourdomain.com/api/issues?customer_id=123&page=1&per_page=10"
  Future<void> testGetIssues({int customerId = 244}) async {
    print('Testing Get Issues API...');
    await _issuesProvider.getIssues(
      customerId: customerId,
      page: 1,
      perPage: 10,
    );
    
    if (_issuesProvider.state == RequestState.loaded) {
      print('✅ Get Issues API Success!');
      print('Total Issues: ${_issuesProvider.totalIssues}');
      print('Issues Count: ${_issuesProvider.allIssues.length}');
      _issuesProvider.allIssues.forEach((issue) {
        print('- Issue ID: ${issue.id}, Type: ${issue.refusedType}, Brand: ${issue.brand.brandName}');
      });
    } else if (_issuesProvider.state == RequestState.failed) {
      print('❌ Get Issues API Failed');
    }
  }

  /// 2. Get Issue Details
  /// curl -X GET "https://yourdomain.com/api/issues/1?customer_id=123"
  Future<void> testGetIssueDetails({int issueId = 2, int customerId = 244}) async {
    print('Testing Get Issue Details API...');
    await _issueDetailsProvider.getIssueDetails(
      issueId: issueId,
      customerId: customerId,
    );
    
    if (_issueDetailsProvider.state == RequestState.loaded) {
      print('✅ Get Issue Details API Success!');
      final issue = _issueDetailsProvider.issueDetails!;
      print('Issue ID: ${issue.id}');
      print('Type: ${issue.refusedType}');
      print('Customer: ${issue.customer.name}');
      print('Brand: ${issue.brand.brandName}');
      print('Sessions Count: ${issue.statistics.sessionsCount}');
      print('Reminders Count: ${issue.statistics.remindersCount}');
    } else if (_issueDetailsProvider.state == RequestState.failed) {
      print('❌ Get Issue Details API Failed');
    }
  }

  /// 3. Get Customer Summary
  /// curl -X GET "https://yourdomain.com/api/issues/summary?customer_id=123"
  Future<void> testGetIssuesSummary({int customerId = 244}) async {
    print('Testing Get Issues Summary API...');
    await _issuesSummaryProvider.getIssuesSummary(customerId: customerId);
    
    if (_issuesSummaryProvider.state == RequestState.loaded) {
      print('✅ Get Issues Summary API Success!');
      final summary = _issuesSummaryProvider.issuesSummary!;
      print('Customer: ${summary.customerInfo.name}');
      print('Total Issues: ${summary.statistics.totalIssues}');
      print('Normal Issues: ${summary.statistics.normalIssues}');
      print('Opposition Issues: ${summary.statistics.oppositionIssues}');
      print('Recent Issues Count: ${summary.recentIssues.length}');
    } else if (_issuesSummaryProvider.state == RequestState.failed) {
      print('❌ Get Issues Summary API Failed');
    }
  }

  /// 4. Search Issues
  /// curl -X GET "https://yourdomain.com/api/issues/search?query=TechBrand&customer_id=123"
  Future<void> testSearchIssues({
    String query = 'Dokkan',
    int customerId = 244,
  }) async {
    print('Testing Search Issues API...');
    await _searchIssuesProvider.searchIssues(
      query: query,
      customerId: customerId,
      page: 1,
      perPage: 15,
    );
    
    if (_searchIssuesProvider.state == RequestState.loaded) {
      print('✅ Search Issues API Success!');
      print('Search Query: ${query}');
      print('Total Results: ${_searchIssuesProvider.totalResults}');
      print('Results Count: ${_searchIssuesProvider.searchResults.length}');
      _searchIssuesProvider.searchResults.forEach((issue) {
        print('- Issue ID: ${issue.id}, Type: ${issue.refusedType}, Brand: ${issue.brandName}');
      });
    } else if (_searchIssuesProvider.state == RequestState.failed) {
      print('❌ Search Issues API Failed');
    }
  }

  /// Test all APIs in sequence
  Future<void> testAllAPIs({int customerId = 244}) async {
    print('========================================');
    print('🧪 Testing All Issues API Endpoints');
    print('========================================');
    
    // Test 1: Get Issues List
    await testGetIssues(customerId: customerId);
    await Future.delayed(Duration(seconds: 1));
    
    // Test 2: Get Issue Details (using issue ID 2 from the example)
    await testGetIssueDetails(issueId: 2, customerId: customerId);
    await Future.delayed(Duration(seconds: 1));
    
    // Test 3: Get Issues Summary
    await testGetIssuesSummary(customerId: customerId);
    await Future.delayed(Duration(seconds: 1));
    
    // Test 4: Search Issues
    await testSearchIssues(query: 'Dokkan', customerId: customerId);
    
    print('========================================');
    print('✅ All Tests Completed!');
    print('========================================');
  }

  /// Clear all data
  void clearAllData() {
    _issuesProvider.resetData();
    _issueDetailsProvider.clearIssueDetails();
    _issuesSummaryProvider.clearSummary();
    _searchIssuesProvider.clearSearch();
    notifyListeners();
  }
} 