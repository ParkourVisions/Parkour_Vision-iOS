/*
 * Copyright (c) 2011 Parkour Visions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 * LinkedList.h
 * author: emancebo
 * 2/16/11
 */

#import <Foundation/Foundation.h>
#import "LinkedListNode.h"

@interface LinkedList : NSObject {

@private
	LinkedListNode *head;
	LinkedListNode *tail;
	int mCount;
}

- (LinkedListNode*) getHead;
- (LinkedListNode*) getTail;

// add to end of list
- (void) add:(id)element;

// add after specified node
- (void) add:(id)element afterNode:(LinkedListNode*)node;

// remove given LinkedListNode
- (void) remove:(LinkedListNode*)node;

// remove first occurance of given data object id
- (void) removeFirst:(id)element;

// removes all nodes
- (void) clear;

// number of elements
- (int) count;

@end
