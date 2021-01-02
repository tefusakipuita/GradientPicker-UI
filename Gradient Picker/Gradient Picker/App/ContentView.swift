//
//  ContentView.swift
//  Gradient Picker
//
//  Created by 中筋淳朗 on 2020/11/12.
//

import SwiftUI
  
struct ContentView : View {
    
    // MARK: - Property
  
    @State var show = false
    @State var search = ""
    @State var gradients : [Gradient] = []
    @State var columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
    @State var filtered : [Gradient] = []
    
    
    // MARK: - Body

    var body: some View{
            VStack{
            HStack(spacing: 15){
                
                // MARK: - TopBar
                if show{
                    
                    // MARK: - Search Mode
                    TextField("Search Gradient", text: $search)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: search) { (value) in
                            if search != "" {
                                searchColor()
                            } else {
                                search = ""
                                filtered = gradients
                            } //: if
                        } //: onChange
                    Button(action: {
                        withAnimation(.easeOut){
                            search = ""
                            filtered = gradients
                            show.toggle()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    } //: Button
                } else {
                     
                    // MARK: - Default Mode
                    Text("Gradients")
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeOut){
                            show.toggle()
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    } //: Button
                    
                    Button(action: {
                        withAnimation(.easeOut){
                            if columns.count == 1 {
                                columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
                            } else {
                                columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 1)
                            } //: if
                        }
                    }) {
                        Image(systemName: columns.count == 1 ? "square.grid.2x2.fill" : "rectangle.grid.1x2.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    } //: Button
                } //: if
            } //: HStack
              .padding(.top,20)
              .padding(.bottom,10)
              .padding(.horizontal)
            
            
              if gradients.isEmpty{
                  
                  // MARK: - Loading View
                  ProgressView()
                      .padding(.top,55)
                  
                  Spacer()
              } else {
                  
                // MARK: - Gradient List
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid (columns: columns, spacing: 20) {
                        ForEach(filtered, id: \.name) { gradient in
                            VStack (spacing: 15) {
                                ZStack {
                                    LinearGradient(gradient: .init(colors: HEXTORGB(colors: gradient.colors)), startPoint: .top, endPoint: .bottom)
                                      .frame(height: 180)
                                      .clipShape(CShape())
                                      .cornerRadius(15)
                                    // context Menu...
                                      .contentShape(CShape())
                                      .contextMenu{
                                          Button(action: {
                                              var colorCode = ""
                                            
                                              for color in gradient.colors {
                                                  colorCode += color + ""
                                              }
                                              UIPasteboard.general.string = colorCode
                                          }) {
                                              Text("Copy")
                                          } //: Button
                                      } //: contextMenu

                                    Text(gradient.name)
                                      .fontWeight(.bold)
                                      .multilineTextAlignment(.center)
                                      .foregroundColor(.white)
                                      .padding(.horizontal)
                                } //: ZStack
                          
                                // MARK: - Hex Code
                                if columns.count == 1{
                                    HStack (spacing: 15) {
                                        ForEach(gradient.colors, id: \.self) { color in
                                            Text(color)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                        } //: ForEach
                                    } //: HStack
                                } //: if
                            } //: VStack
                          } //: ForEach
                      } //: VGrid
                      .padding(.horizontal)
                      .padding(.bottom)
                  } //: Scroll
              } //: if
          } //: VStack
          .onAppear {
              // JSON解析
              getColors()
      }
        }


    // MARK: - Function
      
    // JSON解析
    func getColors(){
      let url = "https://raw.githubusercontent.com/ghosh/uiGradients/master/gradients.json"
      
      let seesion = URLSession(configuration: .default)
      
      seesion.dataTask(with: URL(string: url)!) { (data, _, _) in
          guard let jsonData = data else{return}
          
          do{
              let colors = try JSONDecoder().decode([Gradient].self, from: jsonData)
              
              self.gradients = colors
              self.filtered = colors
          } catch {
              print(error)
          }
      }
      // JSON解析開始
      .resume()
    }
    
    
    // HEX を RGB に変換する
    func HEXTORGB(colors: [String]) -> [Color] {
      var colors1 : [Color] = []
      
      for color in colors{
          var trimmed = color.trimmingCharacters(in: .whitespaces).uppercased()
        
          trimmed.remove(at: trimmed.startIndex)
          
          var hexValue : UInt64 = 0
          Scanner(string: trimmed).scanHexInt64(&hexValue)
          
          let r = CGFloat((hexValue & 0x00FF0000) >> 16) / 255
          let g = CGFloat((hexValue & 0x0000FF00) >> 8) / 255
          let b = CGFloat((hexValue & 0x000000FF)) / 255
          
          colors1.append(Color(UIColor(red: r, green: g, blue: b, alpha: 1.0)))
      }
      
      return colors1
    }
    
    
    // 検索
    func searchColor(){
        let query = search.lowercased()
        
        DispatchQueue.global(qos: .background).async {
            
            let filter = gradients.filter { (gradient) -> Bool in
                
                if gradient.name.lowercased().contains(query){
                    return true
                }
                else{
                    return false
                }
            }
            
            DispatchQueue.main.async {
                withAnimation(.spring()){
                    self.filtered = filter
                }
            } //: DispatchQueue
        } //: DispatchQueue
    }
    
}


// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
