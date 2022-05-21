import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/shared/cubit/states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../modules/archived_tasks/archived_tasks_screen.dart';
import '../../modules/done_tasks/done_tasks_screen.dart';
import '../../modules/new_tasks/new_tasks_screen.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  Database? database;

  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen()
  ];
  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];
  void updateData({required String status, required int id}) async {
    database?.rawUpdate('UPDATE tasks SET status = ? WHERE id = ?',
        ['$status', id]).then((value) {
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  void deleteData({required int id}) async {
    database?.rawDelete('DELETE FROM tasks WHERE id = ?',
        [id]).then((value) {
      getDataFromDatabase(database);
      emit(AppDeleteDatabaseState());
    });
  }

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  void createDatabase() {
    openDatabase('todo.db', version: 1, onCreate: (database, version) {
      print('db created');
      database
          .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
          .then((value) {
        print('table created');
      }).catchError((onError) {
        print(onError);
      });
    }, onOpen: (database) {
      getDataFromDatabase(database);
      print('db opened');
    }).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  insertToDatabase(
      {required String? title,
      required String? time,
      required String? date}) async {
    await database?.transaction((txn) => txn
            .rawInsert(
                'INSERT INTO tasks(title , date, time, status) VALUES("${title}","${date}","${time}","new")')
            .then((value) {
          if (kDebugMode) {
            print('$value inserted successfully');
          }
          emit(AppInsertDatabaseState());

          getDataFromDatabase(database);
        }).catchError((error) {
          if (kDebugMode) {
            print('Error');
          }
        }));
  }

  void getDataFromDatabase(database) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    emit(AppGetDatabaseLoadingState());
    database?.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        switch (element['status']) {
          case "new":
            {
              newTasks.add(element);
            }
            break;
          case 'done':
            {
              doneTasks.add(element);
            }
            break;
          case 'archive':
            {
              archivedTasks.add(element);
            }
            break;
          default:
            {}
            break;
        }
      });
      emit(AppGetDatabaseState());
    });
  }

  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheetState({required bool isShow, required IconData icon}) {
    isBottomSheetShown = isShow;
    fabIcon = icon;
    emit(AppChangeBottomSheetState());
  }
}
