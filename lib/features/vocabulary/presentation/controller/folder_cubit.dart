import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator_test/core/storage/app_database.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term.dart';

part 'folder_state.dart';

class FolderCubit extends Cubit<FolderState> {
  final AppDatabase _db;

  FolderCubit({AppDatabase? db})
    : _db = db ?? AppDatabase.instance,
      super(FolderInitial());

  // ---------------------------------------------------------------------------
  // Folder operations
  // ---------------------------------------------------------------------------

  Future<void> loadFolders() async {
    if (state is! FoldersLoaded) {
      emit(FolderLoading());
    }
    try {
      final folderData = await _db.getAllFoldersWithTermCount();
      final folderInfos = folderData
          .map((d) => FolderInfo(folder: d.folder, termCount: d.termCount))
          .toList();
      emit(FoldersLoaded(folders: folderInfos));
    } catch (e) {
      if (state is! FoldersLoaded) {
        emit(FolderFailure(message: e.toString()));
      }
    }
  }

  Future<void> createFolder(String name) async {
    try {
      final trimmed = name.trim();
      if (trimmed.isEmpty) return;
      await _db.createFolder(trimmed);
      await loadFolders();
    } catch (e) {
      emit(FolderFailure(message: 'Failed to create folder: ${e.toString()}'));
    }
  }

  Future<void> renameFolder(int folderId, String newName) async {
    try {
      final trimmed = newName.trim();
      if (trimmed.isEmpty) return;
      await _db.renameFolder(folderId, trimmed);
      await loadFolders();
    } catch (e) {
      emit(FolderFailure(message: 'Failed to rename folder: ${e.toString()}'));
    }
  }

  Future<void> deleteFolder(int folderId) async {
    try {
      await _db.deleteFolder(folderId);
      await loadFolders();
    } catch (e) {
      emit(FolderFailure(message: 'Failed to delete folder: ${e.toString()}'));
    }
  }

  // ---------------------------------------------------------------------------
  // Term-in-folder operations
  // ---------------------------------------------------------------------------

  Future<void> loadTermsInFolder(int folderId) async {
    emit(FolderTermsLoading(folderId: folderId));
    try {
      final terms = await _db.getTermsByFolderId(folderId);
      emit(FolderTermsLoaded(folderId: folderId, terms: terms));
    } catch (e) {
      emit(FolderFailure(message: e.toString()));
    }
  }

  Future<void> saveTermToFolder({
    required Term term,
    required int folderId,
  }) async {
    try {
      await _db.saveTermToFolder(term: term, folderId: folderId);
      // Reload the folder's terms
      await loadTermsInFolder(folderId);
    } catch (e) {
      emit(
        FolderFailure(
          message: 'Failed to save term to folder: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> removeTermFromFolder({
    required int termId,
    required int folderId,
    String? termWord,
  }) async {
    try {
      await _db.removeTermFromFolder(
        termId: termId,
        folderId: folderId,
        termWord: termWord,
      );
      await loadTermsInFolder(folderId);
    } catch (e) {
      emit(FolderFailure(message: 'Failed to remove term: ${e.toString()}'));
    }
  }
}
