// ignore_for_file: camel_case_types

import 'package:get_it/get_it.dart';
import 'package:kyuser/data/Brand/DataSource/GetBrandBySearchRemotoData.dart';
import 'package:kyuser/data/Brand/DataSource/GetBrandRemotoData.dart';
import 'package:kyuser/data/Brand/DataSourceRepositery/BrandBySearchRepository.dart';
import 'package:kyuser/data/BrandDetails/DataSource/GetBrandDetailsRemotoData.dart';
import 'package:kyuser/data/Reservation/DataSource/SendResevationRemotoData.dart';
import 'package:kyuser/data/Reservation/DataSourceRepositery/SendReservationRepositpry.dart';
import 'package:kyuser/data/SuccessPartners/DataSource/GetSuccessPartnerRemotoData.dart';
import 'package:kyuser/data/SuccessPartners/DataSourceRepositery/SuccessPartnerRepositey.dart';
import 'package:kyuser/domain/Brand/DominRepositery/BaseBrandGettingBySearchRepositery.dart';
import 'package:kyuser/domain/Brand/DominRepositery/BaseBrandRepositery.dart';
import 'package:kyuser/domain/Brand/UseCase/GetAllBrandsBySearchUseCase.dart';
import 'package:kyuser/domain/Brand/UseCase/GetAllBrandsUseCase.dart';
import 'package:kyuser/domain/BrandDetails/DominRepositery/BaseBrandDetailsRepositery.dart';
import 'package:kyuser/domain/BrandDetails/UseCase/GetBrandsDetailsUseCase.dart';
import 'package:kyuser/domain/Request/DominRepositery/BaseRequestRepositery.dart';
import 'package:kyuser/domain/Reservation/UseCase/PostReservationUseCase.dart';
import 'package:kyuser/domain/SuccessPartenrs/DominRepositery/BaseSuccessPartnersRepository.dart';
import 'package:kyuser/domain/SuccessPartenrs/UseCase/GetSuccessPartnersUseCase.dart';
import '../data/Brand/DataSourceRepositery/BrandRepositpry.dart';
import '../data/BrandDetails/DataSourceRepositery/BrandDetailsRepositpry.dart';
import '../data/Company/DataSource/GetCompanyRemoteData.dart';
import '../data/Company/DataSourceRepositery/CompanyRepository.dart';
import '../data/Request/DataSource/SendRequestRemotoData.dart';
import '../data/Request/DataSourceRepositery/SendRequestRepositpry.dart';
import '../data/userData/DataSource/GetUserDataRemotoData.dart';
import '../data/userData/DataSourceRepositery/UserDataRepository.dart';
import '../domain/Company/DominRepositery/BaseCompanyRepositery.dart';
import '../domain/Company/UseCase/GetAllCompaniesUseCase.dart';
import '../domain/Request/UseCase/PostRequestUseCase.dart';
import '../domain/Reservation/DominRepositery/BaseReservationRepositery.dart';
import '../domain/User/DominRepositery/BaseUserRepositery.dart';
import '../presentation/Controllar/GetCompanyProvider.dart';
final sl = GetIt.instance;
class Services_locator {
  void init() {
    /// REPOSITORY
    sl.registerLazySingleton<BaseBrandRepository>(() => BrandRepository(baseGetBrandRemoteData: sl()));
    sl.registerLazySingleton<BaseReservationRepository>(() => SendReservationRepository(baseSendResevationRemotoData: sl()));
    sl.registerLazySingleton<BaseRequestRepository>(() => SendRequestRepository(baseSendRequestRemotoData: sl()));
    sl.registerLazySingleton<BaseBrandDetailsRepository>(() => BrandDetailsRepository(baseGetBrandDetailsRemoteData: sl()));
    sl.registerLazySingleton<BaseBrandGettingBySearchRepository>(() => BrandBySearchRepository(baseGetBrandBySearchRemoteData: sl()));
    sl.registerLazySingleton<BaseSuccessPartnersRepository>(() => SuccessPartnerRepositey(baseGetSuccessPartnerRemoteData: sl()));
    sl.registerLazySingleton<BaseUserRepository>(() => UserRepository(baseGetUserRemoteData: sl()));

    sl.registerLazySingleton<BaseGetCompanyRemoteData>(() => GetCompanyRemoteData());
    sl.registerLazySingleton<BaseCompanyRepository>(() => CompanyRepository(baseGetCompanyRemoteData: sl()));
    sl.registerLazySingleton(() => GetAllCompaniesUseCase(sl()));
    sl.registerFactory(() => GetCompanyProvider());
    ///DATA SOURCE
    sl.registerLazySingleton<BaseGetBrandRemoteData>(() => GetBrandRemoteData());
    sl.registerLazySingleton<BaseGetBrandDetailsRemoteData>(() => GetBrandDetailsRemoteData());
    sl.registerLazySingleton<BaseGetBrandBySearchRemoteData>(() => GetBrandBySearchRemoteData());
    sl.registerLazySingleton<BaseSendResevationRemotoData>(() => SendReservationToRemoteData());
    sl.registerLazySingleton<BaseSendRequestRemotoData>(() => SendRequestToRemoteData());
    sl.registerLazySingleton<BaseGetSuccessPartnerRemoteData>(() => GetSuccessPartnerRemotoData());
    sl.registerLazySingleton<BaseGetUserRemoteData>(() => GetUserRemoteData());
    /// USECASE
    sl.registerLazySingleton(() => GetAllBrandsUseCase(sl()));
    sl.registerLazySingleton(() => GetSuccessPartnersUseCase(sl()));
    sl.registerLazySingleton(() => GetBrandsDetailsUseCase(sl()));
    sl.registerLazySingleton(() => GetAllBrandsBySearchUseCase(sl()));
    sl.registerLazySingleton(() => PostReservationUseCase(sl()));
    sl.registerLazySingleton(() => PostRequestUseCase(sl()));
  }
}
