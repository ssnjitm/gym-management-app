import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/usecases/get_members_usecase.dart';
import '../../domain/usecases/create_member_usecase.dart';
import '../../domain/usecases/update_member_usecase.dart';
import '../../domain/usecases/delete_member_usecase.dart';
import '../../domain/usecases/search_members_usecase.dart';

// Events
abstract class MembersEvent extends Equatable {
  const MembersEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadMembersEvent extends MembersEvent {
  final String? gymId;
  final String? search;
  final int page;
  final int limit;
  final String? status;
  final String sortBy;
  final bool ascending;

  const LoadMembersEvent({
    this.gymId,
    this.search,
    this.page = 1,
    this.limit = 20,
    this.status,
    this.sortBy = 'full_name',
    this.ascending = true,
  });

  @override
  List<Object?> get props => [gymId, search, page, limit, status, sortBy, ascending];
}

class CreateMemberEvent extends MembersEvent {
  final String gymId;
  final Map<String, dynamic> memberData;

  const CreateMemberEvent({required this.gymId, required this.memberData});

  @override
  List<Object?> get props => [gymId, memberData];
}

class UpdateMemberEvent extends MembersEvent {
  final String memberId;
  final Map<String, dynamic> memberData;

  const UpdateMemberEvent({required this.memberId, required this.memberData});

  @override
  List<Object?> get props => [memberId, memberData];
}

class DeleteMemberEvent extends MembersEvent {
  final String memberId;

  const DeleteMemberEvent({required this.memberId});

  @override
  List<Object?> get props => [memberId];
}

class SearchMembersEvent extends MembersEvent {
  final String query;
  final String? gymId;
  final int limit;

  const SearchMembersEvent({
    required this.query,
    this.gymId,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, gymId, limit];
}

// States
abstract class MembersState extends Equatable {
  const MembersState();
  
  @override
  List<Object?> get props => [];
}

class MembersInitial extends MembersState {}

class MembersLoading extends MembersState {}

class MembersLoaded extends MembersState {
  final List<MemberEntity> members;
  final bool hasMore;
  final int currentPage;

  const MembersLoaded({
    required this.members,
    this.hasMore = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [members, hasMore, currentPage];
}

class MembersError extends MembersState {
  final Failure error;

  const MembersError({required this.error});

  @override
  List<Object?> get props => [error];
}

// BLoC
class MembersBloc extends Bloc<MembersEvent, MembersState> {
  final GetMembersUseCase getMembersUseCase;
  final CreateMemberUseCase createMemberUseCase;
  final UpdateMemberUseCase updateMemberUseCase;
  final DeleteMemberUseCase deleteMemberUseCase;
  final SearchMembersUseCase searchMembersUseCase;

  MembersBloc({
    required this.getMembersUseCase,
    required this.createMemberUseCase,
    required this.updateMemberUseCase,
    required this.deleteMemberUseCase,
    required this.searchMembersUseCase,
  }) : super(MembersInitial()) {
    on<LoadMembersEvent>(_onLoadMembers);
    on<CreateMemberEvent>(_onCreateMember);
    on<UpdateMemberEvent>(_onUpdateMember);
    on<DeleteMemberEvent>(_onDeleteMember);
    on<SearchMembersEvent>(_onSearchMembers);
  }

  Future<void> _onLoadMembers(LoadMembersEvent event, Emitter<MembersState> emit) async {
    emit(MembersLoading());
    
    final result = await getMembersUseCase(
      gymId: event.gymId,
      page: event.page,
      limit: event.limit,
      search: event.search,
      status: event.status,
      sortBy: event.sortBy,
      ascending: event.ascending,
    );

    result.fold(
      (failure) => emit(MembersError(error: failure)),
      (members) => emit(MembersLoaded(
        members: members,
        hasMore: members.length >= event.limit,
        currentPage: event.page,
      )),
    );
  }

  Future<void> _onCreateMember(CreateMemberEvent event, Emitter<MembersState> emit) async {
    emit(MembersLoading());
    
    final result = await createMemberUseCase(
      gymId: event.gymId,
      memberData: event.memberData,
    );

    result.fold(
      (failure) => emit(MembersError(error: failure)),
      (member) {
        add(LoadMembersEvent());
      },
    );
  }

  Future<void> _onUpdateMember(UpdateMemberEvent event, Emitter<MembersState> emit) async {
    emit(MembersLoading());
    
    final result = await updateMemberUseCase(
      memberId: event.memberId,
      memberData: event.memberData,
    );

    result.fold(
      (failure) => emit(MembersError(error: failure)),
      (member) {
        add(LoadMembersEvent());
      },
    );
  }

  Future<void> _onDeleteMember(DeleteMemberEvent event, Emitter<MembersState> emit) async {
    emit(MembersLoading());
    
    final result = await deleteMemberUseCase(memberId: event.memberId);

    result.fold(
      (failure) => emit(MembersError(error: failure)),
      (_) {
        add(LoadMembersEvent());
      },
    );
  }

  Future<void> _onSearchMembers(SearchMembersEvent event, Emitter<MembersState> emit) async {
    emit(MembersLoading());
    
    final result = await searchMembersUseCase(
      query: event.query,
      gymId: event.gymId,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(MembersError(error: failure)),
      (members) => emit(MembersLoaded(
        members: members,
        hasMore: false,
      )),
    );
  }
}