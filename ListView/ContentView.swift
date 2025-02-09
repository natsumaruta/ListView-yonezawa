//
//  ContentView.swift
//  ListView
//
//  Created by 米澤菜摘子 on 2025/02/09.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        FirstView() //FirstViewを表示
        //SecondView()
        
    }
}
//　リストのビュー
struct FirstView: View {
    // "TasksData"というキーで保存されたものを監視
    @AppStorage("TasksData") private var tasksData = Data()
    @State var tasksArray: [Task] = []
    
    // FirstVoew生成時に呼ばれる。
    init() {
        // taskDataをデコードできたら、その値をtasksArrayにわたす
        if let decodedTasks = try? JSONDecoder().decode([Task].self, from: tasksData){
            _tasksArray = State(initialValue: decodedTasks)
            print(tasksArray)
        }
    }
    
    
    var body: some View {
        NavigationStack {
            // "Add New Task"をタップするとSecondViewへ画面遷移するようにリンクを設定
            NavigationLink(destination: SecondView(tasksArray: $tasksArray)
                .navigationTitle("Add Task")) {
                Text("Add New Task")
                    .font(.system(size: 20,weight: .bold))
                    .padding()
            }
            
            List {
                //　ExampleTask　の中の　taskListの内側にForEachを使って
                ForEach(tasksArray) { task in
                    Text(task.taskItem)
                }
                // 並び替えが起きたときに実行される
                .onMove { from, to in
                    replaceRow(from, to)
                }
                
                
            }
            .navigationTitle("Take List") //画面上のタイトル
            // ナビゲーションバーに編集ポタンを追加
            .toolbar {
                EditButton()
            }
        }
    }
    // 並び替え処理と　並び替え後の保存
    func replaceRow(_ from: IndexSet, _ to: Int){
        tasksArray.move(fromOffsets: from, toOffset: to)
        if let encodedArray = try? JSONEncoder().encode(tasksData){
            tasksData = encodedArray //　エンコードできたらAppStrageに渡す
        }
    }
    
    
}
// タスク入力用のビュー
struct SecondView: View{
    
    @Environment(\.dismiss) private var dismiss
    
    //テキストフィールドに入力された文字を格納する変数
    @State private var task: String = ""
    @Binding var tasksArray: [Task]
    var body: some View{
        TextField("Enter your task", text:$task)
            .textFieldStyle(.roundedBorder)
            .padding()
        
        Button {
            // ボタンを押したときに実行される
            addTask(newTask: task) //入力されたTaskの保存
            task = "" // テキストフィールドを空に
            print(tasksArray)
            
        } label: {
            Text("Add")
        }
        .buttonStyle(.borderedProminent)
        .tint(.black)
        .padding()

        Spacer()// 下側の余白を埋めた
        
        
    }
    //　タスクの追加と保存　引数は入力されたタスクの文字
    func addTask(newTask: String){
        // テキストフィールドに入力しれた値が空白じゃないとき（何か入力されている）ときだけ処理
        if !newTask.isEmpty{
            let task = Task(taskItem: newTask) //タスクをインスタンス化(実体化)
            var array = tasksArray
            array.append(task) //一時的な配列ArrayにTaskを追加
            // エンコードがうまくいったらUserDefaultsに保存する
            if let encodedData = try? JSONEncoder().encode(array){
                UserDefaults.standard.setValue(encodedData, forKey: "TasksData")
                tasksArray = array //保存ができたときだけ、新しいTaskが追加された配列を反映
                dismiss() // 前の画面に戻る
            }
        }
    }
}


#Preview {
    ContentView()
}

//#Preview("SecondView", body: {
//    SecondView()
//})
