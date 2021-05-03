//
//  ContentView.swift
//  ListLikeCustomSwipeGesture
//
//  Created by ramil on 03.05.2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        SwipeItem(content: {
            Text("SwiftUI")
        }, left: {
            ZStack {
                Rectangle()
                    .fill(Color.green)
                Image(systemName: "pencil.circle")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }
        }, right: {
            ZStack {
                Rectangle()
                    .fill(Color.red)
                Image(systemName: "trash.circle")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }
        }, itemHeight: 77)
    }
}

struct SwipeItem<Content: View, Left: View, Right: View>: View {
    var content: () -> Content
    var left: () -> Left
    var right: () -> Right
    var itemHeight: CGFloat
    
    init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder left: @escaping () -> Left,
        @ViewBuilder right: @escaping () -> Right,
        itemHeight: CGFloat
    ) {
        self.content = content
        self.left = left
        self.right = right
        self.itemHeight = itemHeight
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation {
                    hoffset = anchor + value.translation.width
                    
                    if abs(hoffset) > anchorWidth {
                        if leftPast {
                            hoffset = anchorWidth
                        } else if rightPast {
                            hoffset = -anchorWidth
                        }
                    }
                    
                    
                    if anchor > 0 {
                        leftPast = hoffset > anchorWidth - swipeTreshold
                    } else {
                        leftPast = hoffset > swipeTreshold
                    }
                    
                    if anchor < 0 {
                        rightPast = hoffset < -anchorWidth + swipeTreshold
                    } else {
                        rightPast = hoffset < -swipeTreshold
                    }
                }
            }
            .onEnded { value in
                withAnimation {
                    if rightPast {
                        anchor = -anchorWidth
                    } else if leftPast {
                        anchor = anchorWidth
                    } else {
                        anchor = 0
                    }
                }
                
                hoffset = anchor
            }
    }
    
    @State var hoffset: CGFloat = 0
    @State var anchor: CGFloat = 0
    
    let screenWidth = UIScreen.main.bounds.width
    var anchorWidth: CGFloat { screenWidth / 3 }
    var swipeTreshold: CGFloat { screenWidth / 15 }
    
    @State var rightPast = false
    @State var leftPast = false
    
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                left()
                    .frame(width: anchorWidth)
                    .zIndex(1)
                    .clipped()
                
                content()
                    .frame(width: geo.size.width)
                
                right()
                    .frame(width: anchorWidth)
                    .zIndex(1)
                    .clipped()
            }
        }
        .offset(x: -anchorWidth + hoffset)
        .frame(maxHeight: itemHeight)
        .contentShape(Rectangle())
        .gesture(drag)
        .clipped()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
