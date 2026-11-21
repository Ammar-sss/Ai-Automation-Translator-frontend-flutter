part of 'folder_cubit.dart';

/// Lightweight info class pairing a folder with its term count.
class FolderInfo {
  final Folder folder;
  final int termCount;

  const FolderInfo({required this.folder, required this.termCount});
}

@immutable
sealed class FolderState {}

final class FolderInitial extends FolderState {}

final class FolderLoading extends FolderState {}

final class FoldersLoaded extends FolderState {
  final List<FolderInfo> folders;

  FoldersLoaded({required this.folders});
}

final class FolderTermsLoading extends FolderState {
  final int folderId;

  FolderTermsLoading({required this.folderId});
}

final class FolderTermsLoaded extends FolderState {
  final int folderId;
  final List<Term> terms;

  FolderTermsLoaded({required this.folderId, required this.terms});
}

final class FolderFailure extends FolderState {
  final String message;

  FolderFailure({required this.message});
}
