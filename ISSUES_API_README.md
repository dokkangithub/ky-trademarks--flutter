# Issues API Integration

تم إنشاء نظام كامل لإدارة القضايا (Issues) في التطبيق باستخدام Clean Architecture.

## الـ Endpoints المتاحة

### 1. جلب قائمة القضايا
```
GET /api/issues?customer_id=123&page=1&per_page=10
```

### 2. جلب تفاصيل قضية محددة
```
GET /api/issues/{issue_id}?customer_id=123
```

### 3. جلب ملخص القضايا للعميل
```
GET /api/issues/summary?customer_id=123
```

### 4. البحث في القضايا
```
GET /api/issues/search?query=TechBrand&customer_id=123&page=1&per_page=15
```

## بنية الملفات المنشأة

### Domain Layer
- `lib/domain/Issues/Entities/IssuesEntity.dart` - Business entities
- `lib/domain/Issues/DominRepositery/BaseIssuesRepository.dart` - Repository interface
- `lib/domain/Issues/UseCase/` - Use cases للـ business logic

### Data Layer
- `lib/data/Issues/models/IssuesDataModel.dart` - Data models
- `lib/data/Issues/DataSource/GetIssuesRemoteData.dart` - API calls
- `lib/data/Issues/DataSourceRepositery/IssuesRepository.dart` - Repository implementation

### Presentation Layer
- `lib/presentation/Controllar/Issues/` - State management providers

## كيفية الاستخدام

### 1. في حالة وجود UI

```dart
// جلب قائمة القضايا
final issuesProvider = Provider.of<GetIssuesProvider>(context);
await issuesProvider.getIssues(customerId: 244);

// جلب تفاصيل قضية
final detailsProvider = Provider.of<GetIssueDetailsProvider>(context);
await detailsProvider.getIssueDetails(issueId: 2, customerId: 244);

// جلب ملخص القضايا
final summaryProvider = Provider.of<GetIssuesSummaryProvider>(context);
await summaryProvider.getIssuesSummary(customerId: 244);

// البحث في القضايا
final searchProvider = Provider.of<SearchIssuesProvider>(context);
await searchProvider.searchIssues(query: "Dokkan", customerId: 244);
```

### 2. للاختبار بدون UI

استخدم `IssuesTestProvider` لاختبار جميع الـ APIs:

```dart
final testProvider = IssuesTestProvider();

// اختبار جميع الـ APIs
await testProvider.testAllAPIs(customerId: 244);

// أو اختبار API واحد
await testProvider.testGetIssues(customerId: 244);
await testProvider.testGetIssueDetails(issueId: 2, customerId: 244);
await testProvider.testGetIssuesSummary(customerId: 244);
await testProvider.testSearchIssues(query: "Dokkan", customerId: 244);
```

## التحديثات في Services Locator

تم إضافة جميع dependencies الجديدة في `lib/core/Services_locator.dart`:

- Repository registrations
- DataSource registrations  
- UseCase registrations
- Provider registrations

## مثال على البيانات المستردة

### قائمة القضايا
```json
{
  "status": 1,
  "message": "Issues retrieved successfully",
  "data": [
    {
      "id": 2,
      "refused_type": "opposition",
      "customer": {...},
      "company": {...},
      "brand": {...},
      "refused_details": {...}
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 10,
    "total": 2
  }
}
```

### تفاصيل القضية
```json
{
  "status": 1,
  "message": "Issue details retrieved successfully",
  "data": {
    "id": 2,
    "refused_type": "opposition",
    "statistics": {
      "sessions_count": 0,
      "reminders_count": 0
    }
  }
}
```

## الميزات المضافة

- ✅ Clean Architecture
- ✅ Error handling
- ✅ Pagination support
- ✅ Search functionality
- ✅ State management
- ✅ Loading states
- ✅ Type safety
- ✅ Code reusability

## ملاحظات مهمة

1. استبدل `customer_id=244` بـ ID العميل الصحيح
2. تأكد من إعداد الـ base URL الصحيح في `Api_Constant.dart`
3. جميع الـ APIs تستخدم GET requests فقط
4. البيانات محمية بـ customer_id parameter
5. يمكن استخدام نفس الـ pattern لإضافة features جديدة

## في حالة إضافة UI لاحقاً

يمكن بسهولة إنشاء صفحات UI باستخدام الـ providers الموجودة:

```dart
// مثال لصفحة قائمة القضايا
class IssuesListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GetIssuesProvider>(
      builder: (context, provider, child) {
        if (provider.state == RequestState.loading) {
          return CircularProgressIndicator();
        } else if (provider.state == RequestState.loaded) {
          return ListView.builder(
            itemCount: provider.allIssues.length,
            itemBuilder: (context, index) {
              final issue = provider.allIssues[index];
              return ListTile(
                title: Text(issue.brand.brandName),
                subtitle: Text(issue.refusedType),
                onTap: () => _goToIssueDetails(issue.id),
              );
            },
          );
        } else {
          return Text('Error loading issues');
        }
      },
    );
  }
}
```

التطبيق الآن جاهز للتعامل مع جميع عمليات القضايا بشكل كامل! 